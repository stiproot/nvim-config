# cc-agent

A Neovim plugin for communicating with an external Claude agent server via WebSocket.

## Features

- WebSocket communication via `websocat`
- Floating overlay UI for viewing task progress and messages
- Reactive state management with subscriber pattern
- User commands and configurable keymaps

## Requirements

- Neovim 0.9+
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [websocat](https://github.com/vi/websocat) - `brew install websocat`

## Installation

The plugin is configured as a local plugin in `lua/plugins/init.lua`:

```lua
{
  dir = vim.fn.stdpath("config") .. "/lua/cc-agent",
  name = "cc-agent",
  lazy = false,
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("cc-agent").setup({})
  end,
},
```

## Usage

| Command              | Keymap       | Description                     |
|----------------------|--------------|---------------------------------|
| `:CCAgentToggle`     | `<leader>ca` | Toggle overlay window           |
| `:CCAgentSend [msg]` | `<leader>cs` | Send message (prompts if empty) |
| `:CCAgentConnect`    |              | Connect to server               |
| `:CCAgentDisconnect` |              | Disconnect from server          |
| `:CCAgentClear`      |              | Clear messages                  |
| `:CCAgentStatus`     |              | Show connection status          |

## Configuration

```lua
require("cc-agent").setup({
  websocket = {
    url = "ws://localhost:3001",
    path = "/ws",
    fingerprint = "stiproot",
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
})
```

## Message Protocol

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

# Architecture Deep Dive

This section explains the design decisions and Lua/Neovim fundamentals used in this plugin.

## File Structure & Module System

```
lua/cc-agent/
├── init.lua        -- Entry point, public API
├── config.lua      -- Configuration defaults
├── websocket.lua   -- WebSocket client
├── state.lua       -- State management
├── commands.lua    -- Command registration
└── ui/
    ├── init.lua    -- UI submodule entry
    └── overlay.lua -- Floating window
```

### How Lua Modules Work in Neovim

Neovim uses Lua's `require()` to load modules. When you call:

```lua
require("cc-agent")
```

Neovim searches `runtimepath` for `lua/cc-agent.lua` or `lua/cc-agent/init.lua`. The `init.lua` convention (borrowed from Node.js) lets you create a directory-based module.

**Key concept:** Each `require()` caches its result. Subsequent calls return the cached table, not a fresh execution. This is why module state persists:

```lua
-- state.lua
local M = {}
M.state = { connected = false }  -- This persists across requires
return M
```

### The `local M = {}` Pattern

Every module follows this pattern:

```lua
local M = {}

function M.some_function()
  -- ...
end

return M
```

**Why `local`?** Without `local`, `M` would be global, polluting the global namespace and causing conflicts. Lua's scoping rules:

- `local` = scoped to current file/block
- No keyword = global (stored in `_G` table)

**Why return a table?** Lua modules return a single value. A table lets you expose multiple functions/values. The caller receives this table:

```lua
local state = require("cc-agent.state")
state.update({ connected = true })  -- Call function on returned table
```

## The Setup Pattern

```lua
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", require("cc-agent.config").defaults, opts or {})
  require("cc-agent.commands").register(M)
end
```

### Why `setup()`?

This is the standard Neovim plugin convention. It:

1. Defers initialization until explicitly called
2. Allows user configuration via `opts`
3. Enables lazy loading (plugin code loads, but doesn't execute until `setup()`)

### `vim.tbl_deep_extend`

```lua
vim.tbl_deep_extend("force", defaults, user_opts)
```

This merges tables recursively. The `"force"` behavior means later tables override earlier ones:

```lua
-- defaults
{ websocket = { url = "ws://localhost:3001", path = "/ws", fingerprint = "stiproot" } }

-- user passes
{ websocket = { url = "ws://myserver:9000" } }

-- result (path and fingerprint preserved, url overridden)
{ websocket = { url = "ws://myserver:9000", path = "/ws", fingerprint = "stiproot" } }
```

Other behaviors: `"keep"` (first value wins), `"error"` (throw on conflict).

## Neovim API Fundamentals

### Buffers vs Windows

Understanding this distinction is crucial:

- **Buffer**: The in-memory text content. Has a `bufnr` (buffer number).
- **Window**: A viewport into a buffer. Has a `win_id` (window ID).

One buffer can be displayed in multiple windows. Closing a window doesn't delete the buffer.

```lua
-- Create a buffer (not displayed anywhere yet)
local bufnr = vim.api.nvim_create_buf(false, true)
-- Args: (listed, scratch)
--   listed = false: won't show in :ls
--   scratch = true: no file association, no swap

-- Create a window displaying that buffer
local win_id = vim.api.nvim_open_win(bufnr, true, { ... })
-- Args: (buffer, enter, config)
--   enter = true: cursor moves to new window
```

### Floating Windows

```lua
vim.api.nvim_open_win(bufnr, true, {
  relative = "editor",  -- Position relative to editor, not cursor/window
  width = 80,
  height = 20,
  row = 5,              -- From top
  col = 10,             -- From left
  border = "rounded",   -- none, single, double, rounded, solid, shadow
  style = "minimal",    -- No line numbers, statusline, etc.
  zindex = 50,          -- Stacking order (higher = on top)
})
```

**`relative` options:**
- `"editor"`: Coordinates relative to entire editor
- `"win"`: Relative to current window
- `"cursor"`: Relative to cursor position

### Buffer Options vs Window Options

```lua
-- Buffer options (persist with the buffer)
vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
vim.api.nvim_buf_set_option(bufnr, "modifiable", false)

-- Window options (specific to this window's view)
vim.api.nvim_win_set_option(win_id, "wrap", true)
vim.api.nvim_win_set_option(win_id, "cursorline", false)
```

Common buffer options:
- `buftype`: `""` (normal), `"nofile"` (no file), `"terminal"`, `"prompt"`
- `bufhidden`: What happens when buffer is no longer in a window
- `swapfile`: Whether to create a swap file

### Setting Buffer Content

```lua
vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
-- Args: (buffer, start_line, end_line, strict_indexing, lines)
--   0, -1 = entire buffer (0 = first line, -1 = past last line)
--   strict_indexing = false: allow out-of-bounds (won't error)
--   lines = table of strings (one per line)
```

## Keymaps

### Global Keymaps

```lua
vim.keymap.set("n", "<leader>ca", function()
  M.toggle_overlay()
end, { desc = "Toggle Claude Agent overlay" })
```

**Arguments:**
1. Mode: `"n"` (normal), `"i"` (insert), `"v"` (visual), `"x"` (visual block), `"t"` (terminal)
2. Key sequence: `"<leader>ca"`
3. Action: string (vim command) or function
4. Options table

**Common options:**
- `desc`: Description (shows in which-key, :map)
- `silent`: Don't echo command
- `noremap`: Non-recursive (default true for `vim.keymap.set`)
- `buffer`: Restrict to specific buffer

### Buffer-Local Keymaps

```lua
vim.keymap.set("n", "q", function()
  M.hide()
end, { buffer = bufnr, nowait = true })
```

`buffer = bufnr` makes this keymap only active in that buffer. `nowait = true` executes immediately without waiting to see if it's part of a longer mapping.

## User Commands

```lua
vim.api.nvim_create_user_command("CCAgentSend", function(opts)
  -- opts.args = string of arguments
  -- opts.fargs = table of arguments (split by whitespace)
  -- opts.bang = true if called with !
  -- opts.range = line range if applicable
end, {
  nargs = "?",  -- Argument count
  desc = "Send message to Claude Agent",
})
```

**`nargs` values:**
- `"0"`: No arguments
- `"1"`: Exactly one
- `"?"`: Zero or one
- `"*"`: Any number
- `"+"`: One or more

## Async & Scheduling

### Why `vim.schedule()`?

```lua
on_stdout = function(_, data)
  vim.schedule(function()
    -- Safe to call Neovim APIs here
  end)
end
```

Neovim's API is not thread-safe. When `plenary.job` receives data, the callback runs in a libuv thread, not the main loop. Calling `vim.api.*` from there causes undefined behavior.

`vim.schedule()` queues a function to run on the next main loop iteration, where API calls are safe.

**Rule:** Any callback from async operations (jobs, timers, network) must wrap Neovim API calls in `vim.schedule()`.

### plenary.job

```lua
local Job = require("plenary.job")

Job:new({
  command = "websocat",
  args = { "-t", "ws://localhost:3001/ws?fingerprint=stiproot" },
  on_stdout = function(_, data)
    -- Called for each line of stdout
  end,
  on_stderr = function(_, data)
    -- Called for each line of stderr
  end,
  on_exit = function(_, code)
    -- Called when process exits
  end,
}):start()
```

This wraps libuv's `spawn` with a nicer API. The job runs asynchronously; callbacks fire as data arrives.

**Sending input:**
```lua
job:send("input string\n")
```

**Stopping:**
```lua
job:shutdown()
```

## State Management Pattern

### The Subscriber Pattern

```lua
local subscribers = {}

function M.subscribe(callback)
  table.insert(subscribers, callback)
  return #subscribers  -- Return ID for unsubscribing
end

function M.update(partial)
  M.state = vim.tbl_deep_extend("force", M.state, partial)
  for _, cb in pairs(subscribers) do
    vim.schedule(function()
      cb(M.state)
    end)
  end
end
```

This is a simple reactive pattern:

1. Components subscribe to state changes
2. When state updates, all subscribers are notified
3. Subscribers receive the full state and can react

**Why this approach?**
- Decouples state from UI
- Multiple components can react to same state
- State changes are centralized

### Wiring It Up

```lua
-- In setup()
local state = require("cc-agent.state")
local overlay = require("cc-agent.ui.overlay")

state.subscribe(function(s)
  overlay.update_content(s)
end)
```

Now whenever `state.update()` is called anywhere, the overlay automatically refreshes.

## JSON Handling

```lua
-- Encode Lua table to JSON string
local json_str = vim.json.encode({ type = "message", content = "hello" })
-- Result: '{"type":"message","content":"hello"}'

-- Decode JSON string to Lua table
local ok, tbl = pcall(vim.json.decode, json_str)
if ok then
  print(tbl.type)  -- "message"
end
```

**Why `pcall`?** `vim.json.decode` throws on invalid JSON. `pcall` (protected call) catches errors:

```lua
local ok, result = pcall(some_function, arg1, arg2)
if ok then
  -- result is return value
else
  -- result is error message
end
```

## Error Handling with vim.notify

```lua
vim.notify("Message", vim.log.levels.INFO)
vim.notify("Warning", vim.log.levels.WARN)
vim.notify("Error", vim.log.levels.ERROR)
```

`vim.notify` is the standard way to show messages. Plugins like `nvim-notify` can override it for better UX.

## Testing

Start a simple echo server:

```bash
websocat -s 3001
```

Then in Neovim:

```vim
:CCAgentConnect
:CCAgentSend Hello world
:CCAgentToggle
```

Messages you send will echo back from the server and appear in the overlay.

## Future Improvements

- Pure Lua WebSocket implementation (remove websocat dependency)
- Message persistence across sessions
- Markdown rendering in overlay
- Telescope picker for message history
- Multiple server connections
