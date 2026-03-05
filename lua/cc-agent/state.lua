local M = {}

M.state = {
  connection_state = "disconnected", -- disconnected | connecting | connected
  task_status = "idle", -- idle, thinking, executing, completed, error
  current_task = nil,
  messages = {}, -- { role, content, timestamp }
}

local subscribers = {}

function M.update(partial)
  M.state = vim.tbl_deep_extend("force", M.state, partial)
  for _, cb in pairs(subscribers) do
    vim.schedule(function()
      cb(M.state)
    end)
  end
end

function M.subscribe(callback)
  table.insert(subscribers, callback)
  return #subscribers
end

function M.unsubscribe(id)
  subscribers[id] = nil
end

function M.add_message(role, content)
  table.insert(M.state.messages, {
    role = role,
    content = content,
    timestamp = os.time(),
  })
  M.update({}) -- Trigger subscribers
end

function M.clear_messages()
  M.state.messages = {}
  M.update({})
end

function M.reset()
  M.state = {
    connection_state = "disconnected",
    task_status = "idle",
    current_task = nil,
    messages = {},
  }
  M.update({})
end

return M
