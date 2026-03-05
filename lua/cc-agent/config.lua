local M = {}

M.defaults = {
  auto_connect = false,
  websocket = {
    url = "ws://localhost:3001",
    path = "/ws",
    fingerprint = "stiproot",
    websocat_path = "websocat",
    reconnect = {
      enabled = true,
      max_attempts = 10,
      initial_delay_ms = 1000,
      max_delay_ms = 30000,
      backoff_multiplier = 2,
    },
  },
  overlay = {
    width = "60%",
    height = "40%",
    row = "10%",
    col = "center",
    border = "rounded",
    title = " Claude Agent ",
  },
  keymaps = {
    toggle_overlay = "<leader>ca",
    send_message = "<leader>cs",
  },
}

return M
