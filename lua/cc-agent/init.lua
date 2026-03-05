local M = {}

M.config = {}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", require("cc-agent.config").defaults, opts or {})
  require("cc-agent.commands").register(M)

  -- Set up keymaps
  if M.config.keymaps.toggle_overlay then
    vim.keymap.set("n", M.config.keymaps.toggle_overlay, function()
      M.toggle_overlay()
    end, { desc = "Toggle Claude Agent overlay" })
  end

  if M.config.keymaps.send_message then
    vim.keymap.set("n", M.config.keymaps.send_message, function()
      vim.ui.input({ prompt = "Message: " }, function(input)
        if input then
          M.send({ type = "message", content = input })
        end
      end)
    end, { desc = "Send message to Claude Agent" })
  end

  -- Subscribe UI to state changes
  local state = require("cc-agent.state")
  local overlay = require("cc-agent.ui.overlay")
  state.subscribe(function(s)
    overlay.update_content(s)
  end)

  -- Auto-connect if enabled
  if M.config.auto_connect then
    M.connect()
  end
end

function M.connect()
  local ws = require("cc-agent.websocket")
  local state = require("cc-agent.state")

  ws.connect(M.config, {
    on_state_change = function(connection_state)
      state.update({ connection_state = connection_state })
      if connection_state == "connected" then
        vim.notify("Claude Agent connected", vim.log.levels.INFO)
      end
    end,
    on_message = function(msg)
      local data_str = msg.data and vim.json.encode(msg.data) or "{}"

      if msg.type == "status" then
        -- Status updates (including connected state)
        local task_status = msg.data and msg.data.status or nil
        local current_task = msg.data and msg.data.task or nil
        state.update({ task_status = task_status, current_task = current_task })
        state.add_message("system", data_str)
      elseif msg.type == "message" then
        local role = msg.data and msg.data.role or "assistant"
        state.add_message(role, data_str)
      elseif msg.type == "error" then
        vim.notify("Claude Agent Error: " .. data_str, vim.log.levels.ERROR)
        state.add_message("error", data_str)
      else
        -- Log unknown message types
        state.add_message("system", msg.type .. ": " .. data_str)
      end
    end,
    on_close = function(code)
      -- Notification handled by websocket module during reconnection
    end,
  })
end

function M.disconnect()
  local ws = require("cc-agent.websocket")
  local state = require("cc-agent.state")

  ws.disconnect()
  state.update({ connection_state = "disconnected" })
end

function M.send(message)
  local ws = require("cc-agent.websocket")
  local state = require("cc-agent.state")

  ws.send(message)

  -- Add user message to state
  if message.type == "message" and message.content then
    state.add_message("user", message.content)
  end
end

function M.toggle_overlay()
  local overlay = require("cc-agent.ui.overlay")
  overlay.toggle(M.config)
end

function M.get_state()
  return require("cc-agent.state").state
end

return M
