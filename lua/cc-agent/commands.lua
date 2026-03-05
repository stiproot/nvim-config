local M = {}

function M.register(cc_agent)
  vim.api.nvim_create_user_command("CCAgentToggle", function()
    cc_agent.toggle_overlay()
  end, { desc = "Toggle Claude Agent overlay" })

  vim.api.nvim_create_user_command("CCAgentSend", function(opts)
    if opts.args and #opts.args > 0 then
      cc_agent.send({ type = "message", content = opts.args })
    else
      vim.ui.input({ prompt = "Message: " }, function(input)
        if input then
          cc_agent.send({ type = "message", content = input })
        end
      end)
    end
  end, { nargs = "?", desc = "Send message to Claude Agent" })

  vim.api.nvim_create_user_command("CCAgentConnect", function()
    cc_agent.connect()
  end, { desc = "Connect to Claude Agent server" })

  vim.api.nvim_create_user_command("CCAgentDisconnect", function()
    cc_agent.disconnect()
  end, { desc = "Disconnect from Claude Agent server" })

  vim.api.nvim_create_user_command("CCAgentClear", function()
    require("cc-agent.state").clear_messages()
  end, { desc = "Clear Claude Agent messages" })

  vim.api.nvim_create_user_command("CCAgentStatus", function()
    local state = require("cc-agent.state").state
    local ws = require("cc-agent.websocket")
    local status = string.format(
      "Connection: %s\nStatus: %s\nMessages: %d\nQueued: %d",
      state.connection_state or "disconnected",
      state.task_status,
      #state.messages,
      #ws.client.message_queue
    )
    vim.notify(status, vim.log.levels.INFO)
  end, { desc = "Show Claude Agent status" })
end

return M
