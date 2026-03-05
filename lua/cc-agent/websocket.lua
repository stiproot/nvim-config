local M = {}

M.client = {
  job_id = nil,
  state = "disconnected", -- disconnected | connecting | connected
  config = nil,
  callbacks = nil,
  reconnect_timer = nil,
  reconnect_attempts = 0,
  message_queue = {},
  intentional_disconnect = false,
  stdout_buffer = "",
}

local function get_full_url(config)
  return config.websocket.url
    .. (config.websocket.path or "/ws")
    .. "?fingerprint=" .. (config.websocket.fingerprint or "")
end

local function flush_queue()
  if M.client.state ~= "connected" or not M.client.job_id then
    return
  end

  for _, message in ipairs(M.client.message_queue) do
    local encoded = vim.json.encode(message)
    vim.fn.chansend(M.client.job_id, encoded .. "\n")
  end
  M.client.message_queue = {}
end

local function cancel_reconnect_timer()
  if M.client.reconnect_timer then
    vim.fn.timer_stop(M.client.reconnect_timer)
    M.client.reconnect_timer = nil
  end
end

local function schedule_reconnect()
  if not M.client.config then
    return
  end

  local reconnect_cfg = M.client.config.websocket.reconnect
  if not reconnect_cfg.enabled then
    return
  end

  if M.client.reconnect_attempts >= reconnect_cfg.max_attempts then
    vim.schedule(function()
      vim.notify("Claude Agent: max reconnection attempts reached", vim.log.levels.ERROR)
    end)
    return
  end

  local delay = math.min(
    reconnect_cfg.initial_delay_ms * (reconnect_cfg.backoff_multiplier ^ M.client.reconnect_attempts),
    reconnect_cfg.max_delay_ms
  )

  M.client.reconnect_attempts = M.client.reconnect_attempts + 1

  vim.schedule(function()
    vim.notify(
      string.format("Claude Agent: reconnecting in %ds (attempt %d/%d)",
        delay / 1000,
        M.client.reconnect_attempts,
        reconnect_cfg.max_attempts
      ),
      vim.log.levels.INFO
    )
  end)

  M.client.reconnect_timer = vim.fn.timer_start(delay, function()
    M.client.reconnect_timer = nil
    vim.schedule(function()
      M.connect(M.client.config, M.client.callbacks)
    end)
  end)
end

function M.connect(config, callbacks)
  -- Store for reconnection
  M.client.config = config
  M.client.callbacks = callbacks
  M.client.intentional_disconnect = false
  M.client.stdout_buffer = ""

  if M.client.state == "connecting" then
    return
  end

  if M.client.state == "connected" then
    vim.notify("Claude Agent already connected", vim.log.levels.WARN)
    return
  end

  cancel_reconnect_timer()
  M.client.state = "connecting"

  if callbacks.on_state_change then
    callbacks.on_state_change("connecting")
  end

  local full_url = get_full_url(config)
  local first_message_received = false

  M.client.job_id = vim.fn.jobstart({ config.websocket.websocat_path, "-t", full_url }, {
    on_stdout = function(_, data, _)
      -- data is a list of lines; last element may be partial
      if not data then return end

      for i, line in ipairs(data) do
        if i == #data then
          -- Last element: might be partial, buffer it
          M.client.stdout_buffer = M.client.stdout_buffer .. line
        else
          -- Complete line
          local full_line = M.client.stdout_buffer .. line
          M.client.stdout_buffer = ""

          if #full_line > 0 then
            -- First successful message means we're connected
            if not first_message_received then
              first_message_received = true
              M.client.state = "connected"
              M.client.reconnect_attempts = 0

              if callbacks.on_state_change then
                callbacks.on_state_change("connected")
              end

              flush_queue()
            end

            local ok, msg = pcall(vim.json.decode, full_line)
            if ok and callbacks.on_message then
              callbacks.on_message(msg)
            end
          end
        end
      end
    end,
    on_stderr = function(_, data, _)
      if data then
        for _, line in ipairs(data) do
          if line and #line > 0 then
            vim.notify("Claude Agent WebSocket error: " .. line, vim.log.levels.ERROR)
          end
        end
      end
    end,
    on_exit = function(_, code, _)
      M.client.state = "disconnected"
      M.client.job_id = nil

      if callbacks.on_state_change then
        callbacks.on_state_change("disconnected")
      end

      if callbacks.on_close then
        callbacks.on_close(code)
      end

      -- Auto-reconnect if not intentional
      if not M.client.intentional_disconnect then
        schedule_reconnect()
      end
    end,
    stdout_buffered = false,
    stderr_buffered = false,
  })

  if M.client.job_id <= 0 then
    vim.notify("Claude Agent: failed to start websocat", vim.log.levels.ERROR)
    M.client.state = "disconnected"
    return
  end

  -- If no message received within 5 seconds, consider connected anyway
  -- (server might not send initial message)
  vim.defer_fn(function()
    if M.client.state == "connecting" and M.client.job_id then
      M.client.state = "connected"
      M.client.reconnect_attempts = 0

      if callbacks.on_state_change then
        callbacks.on_state_change("connected")
      end

      flush_queue()
    end
  end, 5000)
end

function M.send(message)
  -- Queue message if not connected
  if M.client.state ~= "connected" then
    table.insert(M.client.message_queue, message)

    -- Trigger connection if disconnected
    if M.client.state == "disconnected" and M.client.config then
      M.connect(M.client.config, M.client.callbacks)
    end
    return
  end

  if not M.client.job_id then
    table.insert(M.client.message_queue, message)
    return
  end

  local encoded = vim.json.encode(message)
  vim.fn.chansend(M.client.job_id, encoded .. "\n")
end

function M.disconnect()
  M.client.intentional_disconnect = true
  cancel_reconnect_timer()

  if M.client.job_id then
    vim.fn.jobstop(M.client.job_id)
    M.client.job_id = nil
  end

  M.client.state = "disconnected"
  M.client.message_queue = {}
end

function M.get_state()
  return M.client.state
end

function M.is_connected()
  return M.client.state == "connected"
end

return M
