# Implementation Plan: Claude Agent WebSocket Plugin

## Overview

Build a Neovim plugin (`cc-agent`) to communicate with an external Claude agent server via WebSocket. The plugin will:
1. Send messages to the server via a command
2. Display task progress in a floating overlay (Telescope-style)
3. Maintain state representing current task status (received from server)

**Location**: `~/.config/nvim/lua/cc-agent/` (structured for future extraction to standalone repo)

---

## Architecture

### WebSocket Strategy: External Binary (websocat)

Using `websocat` via `plenary.job` for Phase 1:
- Handles WebSocket protocol complexity (handshake, framing, masking)
- Well-tested Rust binary, installable via `brew install websocat`
- `plenary.job` provides async process management with stdout/stderr callbacks

### Message Protocol (JSON)

**Client to Server:**
```json
{ "type": "message", "content": "User's message" }
```

**Server to Client:**
```json
{ "type": "status", "task_status": "thinking", "current_task": "..." }
{ "type": "message", "role": "assistant", "content": "..." }
{ "type": "error", "message": "..." }
```

---

## File Structure

```
lua/cc-agent/
  init.lua           -- Main module, setup(), public API
  config.lua         -- Configuration defaults
  websocket.lua      -- WebSocket client (websocat wrapper)
  state.lua          -- Task state management with subscribers
  ui/
    init.lua         -- UI module entry point
    overlay.lua      -- Floating window overlay
  commands.lua       -- User command registration
```

---

## Implementation Steps

### Step 1: Create Plugin Structure

**Files to create:**
- `lua/cc-agent/init.lua`
- `lua/cc-agent/config.lua`

**config.lua** - Default configuration:
```lua
M.defaults = {
  websocket = {
    url = "ws://localhost:8080",
    websocat_path = "websocat",
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
```

**init.lua** - Main module structure:
```lua
local M = {}
M.config = {}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", require("cc-agent.config").defaults, opts or {})
  require("cc-agent.commands").register(M)
end

function M.connect() ... end
function M.disconnect() ... end
function M.send(message) ... end
function M.toggle_overlay() ... end
function M.get_state() ... end

return M
```

---

### Step 2: Implement WebSocket Client

**File**: `lua/cc-agent/websocket.lua`

Uses `plenary.job` to spawn websocat process:

```lua
local Job = require('plenary.job')
local M = {}

M.client = { job = nil, connected = false }

function M.connect(config, callbacks)
  M.client.job = Job:new({
    command = config.websocket.websocat_path,
    args = { "-t", config.websocket.url },
    on_stdout = function(_, data)
      vim.schedule(function()
        local ok, msg = pcall(vim.json.decode, data)
        if ok and callbacks.on_message then
          callbacks.on_message(msg)
        end
      end)
    end,
    on_exit = function(_, code)
      M.client.connected = false
      vim.schedule(function()
        if callbacks.on_close then callbacks.on_close(code) end
      end)
    end,
  })
  M.client.job:start()
  M.client.connected = true
end

function M.send(message)
  if M.client.job then
    M.client.job:send(vim.json.encode(message) .. "\n")
  end
end

function M.disconnect()
  if M.client.job then
    M.client.job:shutdown()
  end
end
```

---

### Step 3: Implement State Management

**File**: `lua/cc-agent/state.lua`

Simple reactive state with subscriber pattern:

```lua
local M = {}

M.state = {
  connected = false,
  task_status = "idle",  -- idle, thinking, executing, completed, error
  current_task = nil,
  messages = {},         -- { role, content, timestamp }
}

local subscribers = {}

function M.update(partial)
  M.state = vim.tbl_deep_extend("force", M.state, partial)
  for _, cb in pairs(subscribers) do
    vim.schedule(function() cb(M.state) end)
  end
end

function M.subscribe(callback)
  table.insert(subscribers, callback)
  return #subscribers
end

function M.add_message(role, content)
  table.insert(M.state.messages, {
    role = role,
    content = content,
    timestamp = os.time(),
  })
  M.update({})  -- Trigger subscribers
end
```

---

### Step 4: Build Floating Overlay UI

**File**: `lua/cc-agent/ui/overlay.lua`

Pattern from `claude-code.nvim` terminal.lua:

```lua
local M = {}
local win_state = { bufnr = nil, win_id = nil, visible = false }

function M.show(config)
  if win_state.visible then return end

  win_state.bufnr = win_state.bufnr or vim.api.nvim_create_buf(false, true)

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
  })
  win_state.visible = true

  -- Set keymaps for closing
  vim.keymap.set("n", "q", function() M.hide() end, { buffer = win_state.bufnr })
  vim.keymap.set("n", "<Esc>", function() M.hide() end, { buffer = win_state.bufnr })
end

function M.hide()
  if win_state.win_id and vim.api.nvim_win_is_valid(win_state.win_id) then
    vim.api.nvim_win_close(win_state.win_id, true)
  end
  win_state.win_id = nil
  win_state.visible = false
end

function M.toggle(config)
  if win_state.visible then M.hide() else M.show(config) end
end

function M.update_content(state)
  if not win_state.bufnr then return end

  local lines = {}
  -- Status header
  table.insert(lines, " Status: " .. state.task_status)
  table.insert(lines, string.rep("─", 40))
  table.insert(lines, "")

  -- Messages
  for _, msg in ipairs(state.messages) do
    local prefix = msg.role == "user" and " You:" or " Agent:"
    table.insert(lines, prefix)
    for line in msg.content:gmatch("[^\n]+") do
      table.insert(lines, "  " .. line)
    end
    table.insert(lines, "")
  end

  vim.api.nvim_buf_set_lines(win_state.bufnr, 0, -1, false, lines)
end
```

---

### Step 5: Register Commands

**File**: `lua/cc-agent/commands.lua`

```lua
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
        if input then cc_agent.send({ type = "message", content = input }) end
      end)
    end
  end, { nargs = "?", desc = "Send message to Claude Agent" })

  vim.api.nvim_create_user_command("CCAgentConnect", function()
    cc_agent.connect()
  end, { desc = "Connect to Claude Agent server" })

  vim.api.nvim_create_user_command("CCAgentDisconnect", function()
    cc_agent.disconnect()
  end, { desc = "Disconnect from Claude Agent server" })
end
```

---

### Step 6: Wire Up Main Module

**File**: `lua/cc-agent/init.lua` (complete)

Connect websocket events to state and UI:

```lua
function M.connect()
  local ws = require("cc-agent.websocket")
  local state = require("cc-agent.state")

  ws.connect(M.config, {
    on_message = function(msg)
      if msg.type == "status" then
        state.update({ task_status = msg.task_status, current_task = msg.current_task })
      elseif msg.type == "message" then
        state.add_message(msg.role, msg.content)
      elseif msg.type == "error" then
        vim.notify("Claude Agent Error: " .. msg.message, vim.log.levels.ERROR)
      end
    end,
    on_close = function()
      state.update({ connected = false })
      vim.notify("Claude Agent disconnected", vim.log.levels.WARN)
    end,
  })

  state.update({ connected = true })
  vim.notify("Claude Agent connected")
end
```

---

### Step 7: Add Plugin Registration

**File**: `lua/plugins/init.lua` (add entry)

```lua
{
  dir = vim.fn.stdpath("config") .. "/lua/cc-agent",
  name = "cc-agent",
  lazy = false,
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("cc-agent").setup({
      websocket = { url = "ws://localhost:8080" },
    })
  end,
},
```

---

## Commands & Keymaps

| Command | Keymap | Description |
|---------|--------|-------------|
| `:CCAgentToggle` | `<leader>ca` | Toggle overlay window |
| `:CCAgentSend [msg]` | `<leader>cs` | Send message (prompts if no arg) |
| `:CCAgentConnect` | - | Connect to server |
| `:CCAgentDisconnect` | - | Disconnect from server |

---

## Dependencies

- **plenary.nvim** - Already installed (async job management)
- **websocat** - Install via: `brew install websocat`

---

## Critical Files to Create

1. `lua/cc-agent/init.lua` - Main module
2. `lua/cc-agent/config.lua` - Configuration
3. `lua/cc-agent/websocket.lua` - WebSocket client
4. `lua/cc-agent/state.lua` - State management
5. `lua/cc-agent/ui/overlay.lua` - Floating window
6. `lua/cc-agent/commands.lua` - Command registration

**Modify:**
- `lua/plugins/init.lua` - Add plugin entry

---

## Testing

Test with a simple WebSocket echo server:
```bash
# Terminal 1: Start echo server
websocat -s 8080

# Terminal 2: Open Neovim
nvim
:CCAgentConnect
:CCAgentSend Hello
:CCAgentToggle  -- Should show the message
```

---

## Future Extensions (Phase 2+)

- Pure Lua WebSocket (replace websocat)
- Conversation persistence
- Markdown rendering in overlay
- Multiple server connections
- Telescope picker for history
