local M = {}

local win_state = { bufnr = nil, win_id = nil, visible = false }

local function parse_dimension(value, total)
  if type(value) == "number" then
    return value
  end
  if type(value) == "string" then
    if value == "center" then
      return nil -- Handle separately
    end
    local percent = value:match("(%d+)%%")
    if percent then
      return math.floor(total * tonumber(percent) / 100)
    end
  end
  return total
end

function M.calculate_dimensions(config)
  local editor_width = vim.o.columns
  local editor_height = vim.o.lines

  local width = parse_dimension(config.overlay.width, editor_width)
  local height = parse_dimension(config.overlay.height, editor_height)

  local row = parse_dimension(config.overlay.row, editor_height)
  local col
  if config.overlay.col == "center" then
    col = math.floor((editor_width - width) / 2)
  else
    col = parse_dimension(config.overlay.col, editor_width)
  end

  return {
    width = width,
    height = height,
    row = row,
    col = col,
  }
end

function M.show(config)
  if win_state.visible then
    return
  end

  -- Create buffer if it doesn't exist
  if not win_state.bufnr or not vim.api.nvim_buf_is_valid(win_state.bufnr) then
    win_state.bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(win_state.bufnr, "buftype", "nofile")
    vim.api.nvim_buf_set_option(win_state.bufnr, "bufhidden", "hide")
    vim.api.nvim_buf_set_option(win_state.bufnr, "swapfile", false)
    vim.api.nvim_buf_set_name(win_state.bufnr, "claude-agent")
  end

  local dims = M.calculate_dimensions(config)

  win_state.win_id = vim.api.nvim_open_win(win_state.bufnr, true, {
    relative = "editor",
    width = dims.width,
    height = dims.height,
    row = dims.row,
    col = dims.col,
    border = config.overlay.border,
    title = config.overlay.title,
    title_pos = "center",
    style = "minimal",
    zindex = 50,
  })

  win_state.visible = true

  -- Set window options
  vim.api.nvim_win_set_option(win_state.win_id, "wrap", true)
  vim.api.nvim_win_set_option(win_state.win_id, "cursorline", false)

  -- Set keymaps for closing
  vim.keymap.set("n", "q", function()
    M.hide()
  end, { buffer = win_state.bufnr, nowait = true })
  vim.keymap.set("n", "<Esc>", function()
    M.hide()
  end, { buffer = win_state.bufnr, nowait = true })

  -- Update content with current state
  local state = require("cc-agent.state")
  M.update_content(state.state)
end

function M.hide()
  if win_state.win_id and vim.api.nvim_win_is_valid(win_state.win_id) then
    vim.api.nvim_win_close(win_state.win_id, true)
  end
  win_state.win_id = nil
  win_state.visible = false
end

function M.toggle(config)
  if win_state.visible then
    M.hide()
  else
    M.show(config)
  end
end

function M.update_content(state)
  if not win_state.bufnr or not vim.api.nvim_buf_is_valid(win_state.bufnr) then
    return
  end

  -- Only update if visible
  if not win_state.visible then
    return
  end

  local lines = {}

  -- Connection status with icon
  local conn_icons = {
    disconnected = "○",
    connecting = "◐",
    connected = "●",
  }
  local conn_state = state.connection_state or "disconnected"
  local conn_icon = conn_icons[conn_state] or "?"
  table.insert(lines, " Connection: " .. conn_icon .. " " .. conn_state)

  -- Task status header
  table.insert(lines, " Status: " .. (state.task_status or "idle"))

  -- Current task if any
  if state.current_task then
    table.insert(lines, " Task: " .. state.current_task)
  end

  table.insert(lines, string.rep("-", 50))
  table.insert(lines, "")

  -- Messages
  if #state.messages == 0 then
    table.insert(lines, " No messages yet.")
    table.insert(lines, " Use :CCAgentSend to send a message.")
  else
    for _, msg in ipairs(state.messages) do
      local prefix
      if msg.role == "user" then
        prefix = " You:"
      elseif msg.role == "system" then
        prefix = " System:"
      elseif msg.role == "error" then
        prefix = " Error:"
      else
        prefix = " Agent:"
      end
      table.insert(lines, prefix)
      local content = msg.content or ""
      -- Handle both single-line and multi-line content
      if #content > 0 then
        for line in content:gmatch("[^\n]+") do
          table.insert(lines, "  " .. line)
        end
      end
      table.insert(lines, "")
    end
  end

  vim.api.nvim_buf_set_lines(win_state.bufnr, 0, -1, false, lines)
end

function M.is_visible()
  return win_state.visible
end

return M
