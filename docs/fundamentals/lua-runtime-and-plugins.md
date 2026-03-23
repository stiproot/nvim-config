# Neovim Lua Runtime & Plugin Architecture

## Table of Contents
1. [The Lua Runtime in Neovim](#the-lua-runtime-in-neovim)
2. [How Neovim Embeds Lua](#how-neovim-embeds-lua)
3. [Module System & Loading](#module-system--loading)
4. [Process Management](#process-management)
5. [The Event Loop](#the-event-loop)
6. [Plugin Architecture](#plugin-architecture)

---

## The Lua Runtime in Neovim

Neovim embeds **LuaJIT** (a Just-In-Time compiler for Lua) directly into its core, providing:

- **High performance**: LuaJIT compiles Lua bytecode to machine code at runtime
- **First-class integration**: Lua isn't a plugin - it's part of Neovim's architecture
- **Shared memory space**: Lua runs in the same process as Neovim (no IPC overhead)
- **Direct API access**: Lua can call Neovim's C functions directly via FFI

### Why LuaJIT over Standard Lua?

```
Standard Lua 5.1    →  Interpreted bytecode
LuaJIT              →  Bytecode → JIT → Native machine code
```

**Performance characteristics:**
- LuaJIT is 50-100x faster than interpreted Lua for computational tasks
- Near C-level performance for tight loops and numeric operations
- Built-in FFI (Foreign Function Interface) for calling C libraries

### The Lua-Neovim Bridge

Neovim exposes its functionality through the `vim` global table:

```lua
vim.api.*       -- Core Neovim API (buffer, window, commands)
vim.fn.*        -- VimScript functions accessible from Lua
vim.cmd()       -- Execute VimScript/Ex commands
vim.loop       -- libuv event loop bindings (async I/O)
vim.treesitter -- Tree-sitter parser integration
```

**Under the hood:**
```
┌─────────────────┐
│   Lua Code      │
│   vim.api.nvim_buf_set_lines()
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  LuaJIT VM      │  ← Embedded in Neovim process
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Neovim Core    │  ← C code
│  (nvim_buf_set_lines_impl)
└─────────────────┘
```

---

## How Neovim Embeds Lua

### Process Architecture

When you launch Neovim:

```
1. Neovim starts (C process)
2. LuaJIT VM initialized within same process
3. Core Lua runtime loaded (~/.config/nvim/init.lua)
4. Plugins loaded (via lazy.nvim or other plugin managers)
```

**Single process model:**
```
┌──────────────────────────────────────┐
│  Neovim Process (PID: 12345)         │
│  ┌────────────────────────────────┐  │
│  │  Neovim Core (C)               │  │
│  │  - Event loop (libuv)          │  │
│  │  - Buffer management           │  │
│  │  - UI rendering                │  │
│  └───────────┬────────────────────┘  │
│              │                       │
│  ┌───────────▼────────────────────┐  │
│  │  LuaJIT VM                     │  │
│  │  - Your config (init.lua)      │  │
│  │  - Plugins (telescope, etc.)   │  │
│  │  - Runtime modules             │  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘
```

**Key insight**: Lua code runs in the **same process** as Neovim. This means:
- No serialization/deserialization overhead
- Direct memory access (fast!)
- But: blocking Lua code blocks the entire editor

---

## Module System & Loading

### The `require()` Function

Lua's `require()` is the module loading mechanism:

```lua
local telescope = require("telescope")
```

**What happens:**

1. **Check cache**: Look in `package.loaded` table
   ```lua
   if package.loaded["telescope"] then
     return package.loaded["telescope"]
   end
   ```

2. **Search runtime path**: Look for file in `runtimepath`
   ```
   ~/.config/nvim/lua/telescope.lua
   ~/.config/nvim/lua/telescope/init.lua
   ~/.local/share/nvim/lazy/telescope.nvim/lua/telescope.lua  ← Found!
   ```

3. **Load & execute**: Run the file's code

4. **Cache result**: Store return value in `package.loaded["telescope"]`

5. **Return module**: Return the cached value

### Runtime Path Resolution

Neovim searches in order (`:h runtimepath`):

```
1. ~/.config/nvim/lua/
2. /usr/share/nvim/runtime/lua/
3. Plugin directories (added by plugin manager)
   ~/.local/share/nvim/lazy/*/lua/
```

**Example module resolution:**
```lua
require("utils.telescope")

-- Searches:
1. ~/.config/nvim/lua/utils/telescope.lua       ← Found!
2. ~/.config/nvim/lua/utils/telescope/init.lua
3. (plugin dirs)/lua/utils/telescope.lua
...
```

### Module Caching Implications

**Modules load once per session:**
```lua
-- First time: loads and executes file
local utils = require("utils.telescope")

-- Second time: returns cached version (no file I/O)
local utils2 = require("utils.telescope")

-- utils and utils2 are the SAME table reference
assert(utils == utils2)  -- true
```

**Clearing cache (useful during development):**
```lua
:lua package.loaded["utils.telescope"] = nil
:lua require("utils.telescope")  -- Reloads from disk
```

---

## Process Management

### The Event Loop (libuv)

Neovim uses **libuv** for async I/O and process management. This is the same event loop used by Node.js.

```
┌────────────────────────────┐
│    Neovim Event Loop       │
│    (libuv)                 │
│                            │
│  ┌──────────────────────┐  │
│  │  File System Events  │  │
│  └──────────────────────┘  │
│  ┌──────────────────────┐  │
│  │  Timers/Callbacks    │  │
│  └──────────────────────┘  │
│  ┌──────────────────────┐  │
│  │  Child Processes     │  │
│  └──────────────────────┘  │
│  ┌──────────────────────┐  │
│  │  Network I/O         │  │
│  └──────────────────────┘  │
└────────────────────────────┘
```

### Async Operations with vim.loop

`vim.loop` exposes libuv bindings to Lua:

```lua
-- Example: Read a file asynchronously
vim.loop.fs_open("/path/to/file", "r", 438, function(err, fd)
  if err then
    print("Error:", err)
    return
  end

  vim.loop.fs_read(fd, 1024, 0, function(err, data)
    print("File contents:", data)
    vim.loop.fs_close(fd)
  end)
end)

-- Neovim remains responsive while file is being read!
```

**Event loop phases:**
```
1. Poll for I/O (non-blocking)
2. Execute I/O callbacks
3. Execute timer callbacks
4. Execute idle/prepare callbacks
5. Poll for I/O again
6. Execute check callbacks
7. Execute close callbacks
8. Repeat
```

### Spawning Processes

Neovim provides multiple ways to spawn external processes:

#### 1. **vim.fn.jobstart()** (High-level API)

```lua
local job_id = vim.fn.jobstart({'find', '.', '-type', 'f'}, {
  on_stdout = function(job_id, data, event)
    -- Called when process writes to stdout
    -- Runs asynchronously, doesn't block Neovim
    print("Received:", vim.inspect(data))
  end,
  on_stderr = function(job_id, data, event)
    -- Called when process writes to stderr
    print("Error:", vim.inspect(data))
  end,
  on_exit = function(job_id, exit_code, event)
    -- Called when process terminates
    print("Process exited with code:", exit_code)
  end,
  stdout_buffered = false,  -- Stream output line-by-line
  stderr_buffered = false,
})

-- job_id is used to interact with the running job
vim.fn.jobstop(job_id)  -- Kill the job
```

**Process lifecycle:**
```
jobstart()
    │
    ├─→ Process spawned (non-blocking)
    │
    ├─→ on_stdout called for each line
    │
    ├─→ on_stderr called for errors
    │
    └─→ on_exit called when done

Your Lua code continues executing immediately!
```

#### 2. **vim.loop.spawn()** (Low-level libuv API)

```lua
local handle, pid

handle = vim.loop.spawn('ls', {
  args = {'-la'},
  stdio = {nil, pipe_out, pipe_err},  -- stdin, stdout, stderr
}, function(code, signal)
  -- on_exit callback
  print("Process exited:", code, signal)
  handle:close()
end)

pid = handle:get_pid()
```

#### 3. **vim.system()** (Modern async API - Neovim 0.10+)

```lua
vim.system({'git', 'status'}, {
  text = true,  -- Treat output as text (not bytes)
}, function(obj)
  print("Exit code:", obj.code)
  print("Stdout:", obj.stdout)
  print("Stderr:", obj.stderr)
end)
```

### Understanding stdio and libuv

When spawning a process, you're managing **three standard streams**:

```
┌─────────────────────────────────────┐
│  Parent Process (Neovim)            │
│                                     │
│  ┌──────────────────────────────┐  │
│  │  stdin  (write to child)     │──┼─→ Write data to process
│  └──────────────────────────────┘  │
│  ┌──────────────────────────────┐  │
│  │  stdout (read from child)    │←─┼── Read normal output
│  └──────────────────────────────┘  │
│  ┌──────────────────────────────┐  │
│  │  stderr (read from child)    │←─┼── Read error output
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘
         │
         │ spawns
         ▼
┌─────────────────────────────────────┐
│  Child Process (e.g., find)         │
│                                     │
│  - Reads from stdin                 │
│  - Writes to stdout                 │
│  - Writes to stderr                 │
└─────────────────────────────────────┘
```

**libuv handles these streams asynchronously:**
- Creates **pipes** between parent and child processes
- Monitors pipes for data using the event loop
- Invokes callbacks when data is available
- All without blocking the main thread

### vim.fn vs vim.loop: When to Use Each

Both APIs can spawn processes, but they serve different purposes:

#### **vim.fn.jobstart()** - High-Level, Convenient

**Use when:**
- ✅ You want simple, line-based output handling
- ✅ You need automatic line buffering
- ✅ You're okay with Neovim managing the details
- ✅ You want idiomatic Neovim code

**Characteristics:**
```lua
local job_id = vim.fn.jobstart({'ls', '-la'}, {
  on_stdout = function(job_id, data, event)
    -- data is already split by newlines: {"line1", "line2", ...}
    -- Automatic buffering and line parsing
    for _, line in ipairs(data) do
      print(line)
    end
  end
})
```

**What vim.fn.jobstart() does for you:**
1. Splits output by newlines automatically
2. Buffers partial lines (if line doesn't end with `\n`)
3. Converts job_id to a Neovim job handle
4. Integrates with `:terminal` and other Neovim features
5. Simpler error handling

**Under the hood:**
```
vim.fn.jobstart()
    ↓
Neovim job API (C code)
    ↓
vim.loop.spawn() (libuv)
    ↓
Operating system process creation
```

#### **vim.loop.spawn()** - Low-Level, Powerful

**Use when:**
- ✅ You need fine-grained control over stdio
- ✅ You want to handle raw byte streams (not lines)
- ✅ You need to write to stdin (bidirectional communication)
- ✅ You're building a low-level abstraction
- ✅ You need direct libuv features (pipes, streams, etc.)

**Characteristics:**
```lua
-- Create pipes for communication
local stdin = vim.loop.new_pipe(false)
local stdout = vim.loop.new_pipe(false)
local stderr = vim.loop.new_pipe(false)

local handle
handle = vim.loop.spawn('cat', {
  args = {},
  stdio = {stdin, stdout, stderr},  -- Explicit pipe setup
}, function(code, signal)
  print("Process exited:", code)
  handle:close()
  stdin:close()
  stdout:close()
  stderr:close()
end)

-- Read stdout (raw bytes, not lines)
stdout:read_start(function(err, data)
  if err then
    print("Error:", err)
  elseif data then
    print("Raw data:", data)  -- May be partial lines!
  else
    -- Stream ended
    stdout:read_stop()
  end
end)

-- Write to stdin
stdin:write("Hello, process!\n")
stdin:shutdown()  -- Close stdin (signal EOF)
```

**What you must handle yourself:**
1. Line splitting (data may be partial lines)
2. Buffer management
3. Pipe creation and cleanup
4. Manual resource management (close handles!)

**Direct libuv access:**
```
Your Lua code
    ↓
vim.loop.spawn() (libuv binding)
    ↓
libuv (C library)
    ↓
Operating system process creation
```

### Detailed stdio Handling

#### How vim.fn.jobstart() Handles Lines

```lua
-- Example: Process outputs "Hello\nWor" then "ld\nBye\n"

local buffer = ""  -- Neovim maintains this internally

-- First chunk: "Hello\nWor"
on_stdout called with: {"Hello", "Wor"}
-- "Hello" is complete (has \n)
-- "Wor" is incomplete (no \n yet), buffered internally

-- Second chunk: "ld\nBye\n"
on_stdout called with: {"ld", "Bye", ""}
-- "ld" completes previous "Wor" → "World"
-- "Bye" is complete
-- "" indicates stream ended with \n
```

**Key insight:** You receive **complete lines** automatically.

#### How vim.loop.spawn() Handles Bytes

```lua
local buffer = ""  -- YOU must maintain this

stdout:read_start(function(err, data)
  if data then
    buffer = buffer .. data  -- Might be: "Hello\nWor"

    -- YOU must split by newlines
    local lines = {}
    for line in buffer:gmatch("([^\n]*)\n") do
      table.insert(lines, line)
    end

    -- Keep incomplete line in buffer
    buffer = buffer:match("[^\n]+$") or ""
  end
end)
```

**Key insight:** You receive **raw bytes**, must handle buffering yourself.

### Writing to stdin

Only `vim.loop.spawn()` gives you easy stdin access:

```lua
local stdin = vim.loop.new_pipe(false)
local stdout = vim.loop.new_pipe(false)

local handle = vim.loop.spawn('grep', {
  args = {'pattern'},
  stdio = {stdin, stdout, nil},  -- stdin pipe, stdout pipe, no stderr
}, function(code, signal)
  handle:close()
  stdin:close()
  stdout:close()
end)

-- Write data to grep's stdin
stdin:write("line1: has pattern\n")
stdin:write("line2: no match\n")
stdin:write("line3: another pattern\n")
stdin:shutdown()  -- Signal EOF to grep

-- Read filtered results from stdout
stdout:read_start(function(err, data)
  if data then
    print("Grep output:", data)
  else
    stdout:read_stop()
  end
end)
```

**With vim.fn.jobstart(), stdin is possible but awkward:**
```lua
local job_id = vim.fn.jobstart({'grep', 'pattern'}, {
  on_stdout = function(_, data)
    print(vim.inspect(data))
  end
})

-- Write to stdin using chansend
vim.fn.chansend(job_id, "line1: has pattern\n")
vim.fn.chansend(job_id, "line2: no match\n")
vim.fn.chanclose(job_id, 'stdin')  -- Close stdin
```

### Decision Tree: Which API to Use?

```
Need to spawn a process?
│
├─ Just need output as lines?
│  └─ Use vim.fn.jobstart()
│     ✓ Simpler
│     ✓ Automatic line buffering
│     ✓ Less code
│
├─ Need bidirectional communication (stdin + stdout)?
│  │
│  ├─ Simple line-based communication?
│  │  └─ Use vim.fn.jobstart() + chansend()
│  │     ✓ Easier for simple cases
│  │
│  └─ Complex binary protocol or streaming?
│     └─ Use vim.loop.spawn()
│        ✓ Full control over pipes
│        ✓ Binary data support
│        ✓ Fine-grained flow control
│
├─ Need raw byte access (not lines)?
│  └─ Use vim.loop.spawn()
│     ✓ No automatic line splitting
│     ✓ Binary-safe
│
├─ Building a language server or complex IPC?
│  └─ Use vim.loop.spawn()
│     ✓ Full pipe control
│     ✓ Multiplexing multiple streams
│     ✓ Advanced libuv features
│
└─ Want synchronous output (blocking is OK)?
   └─ Use vim.fn.system() or vim.system()
      ⚠ Blocks editor
      ✓ Simple for one-shot commands
```

### Real-World Examples

#### Example 1: Simple Command Output (vim.fn.jobstart)

```lua
-- Get list of files, process each line
local files = {}

vim.fn.jobstart({'find', '.', '-type', 'f'}, {
  on_stdout = function(_, data)
    for _, line in ipairs(data) do
      if line ~= "" then
        table.insert(files, line)
      end
    end
  end,
  on_exit = function()
    print("Found " .. #files .. " files")
  end,
  stdout_buffered = true,  -- Collect all output, then call callback once
})
```

#### Example 2: Interactive Process (vim.loop.spawn)

```lua
-- Interactive Python REPL
local stdin = vim.loop.new_pipe(false)
local stdout = vim.loop.new_pipe(false)

local handle = vim.loop.spawn('python3', {
  args = {'-i'},  -- Interactive mode
  stdio = {stdin, stdout, nil},
}, function(code, signal)
  print("Python exited")
  handle:close()
  stdin:close()
  stdout:close()
end)

-- Read output
stdout:read_start(function(err, data)
  if data then
    print("Python says:", data)
  end
end)

-- Send commands
function eval_python(code)
  stdin:write(code .. "\n")
end

eval_python("print('Hello from Python')")
eval_python("2 + 2")
```

#### Example 3: Language Server Protocol (vim.loop.spawn)

```lua
-- Simplified LSP client using vim.loop for full control
local stdin = vim.loop.new_pipe(false)
local stdout = vim.loop.new_pipe(false)

local handle = vim.loop.spawn('rust-analyzer', {
  args = {},
  stdio = {stdin, stdout, nil},
}, function(code, signal)
  -- Language server exited
  handle:close()
  stdin:close()
  stdout:close()
end)

local buffer = ""

stdout:read_start(function(err, chunk)
  if chunk then
    buffer = buffer .. chunk

    -- LSP uses Content-Length header, must parse manually
    while true do
      local content_length = buffer:match("Content%-Length: (%d+)\r\n")
      if not content_length then break end

      local msg_start = buffer:find("\r\n\r\n")
      if not msg_start then break end

      local msg = buffer:sub(msg_start + 4, msg_start + 3 + tonumber(content_length))
      if #msg < tonumber(content_length) then break end

      -- Process LSP message
      local json = vim.json.decode(msg)
      handle_lsp_message(json)

      buffer = buffer:sub(msg_start + 4 + tonumber(content_length))
    end
  end
end)

-- Send LSP request
function send_lsp_request(method, params)
  local msg = vim.json.encode({
    jsonrpc = "2.0",
    id = 1,
    method = method,
    params = params,
  })

  local header = "Content-Length: " .. #msg .. "\r\n\r\n"
  stdin:write(header .. msg)
end
```

**Why vim.loop here?**
- LSP uses Content-Length headers (not line-based)
- Need to parse binary protocol
- Bidirectional communication required
- Must handle partial messages

#### Example 4: Our Telescope Finder (Hybrid Approach)

```lua
-- Telescope uses its own wrapper around vim.loop
finders.new_oneshot_job({'fd', '.', '--type', 'd'}, {
  entry_maker = function(line)
    -- Each line is a complete path
    -- Telescope handles the async job spawning
    return { value = line, display = line, ordinal = line }
  end
})
```

**What Telescope does internally:**
1. Uses `vim.loop.spawn()` for process management
2. Pipes stdout to entry_maker
3. Handles line buffering automatically
4. Provides cancellation, streaming, etc.

### Performance Comparison

```lua
-- Benchmark: Read 10,000 lines

-- vim.fn.jobstart (automatic line splitting)
-- Time: ~50ms
-- Memory: Low (incremental processing)

-- vim.loop.spawn (manual line splitting)
-- Time: ~45ms (slightly faster, less overhead)
-- Memory: Low (you control buffering)

-- io.popen (blocking)
-- Time: ~200ms (same work, but blocks editor)
-- Memory: High (stores entire output in memory)
```

**Recommendation:**
- **Default to vim.fn.jobstart()** for 90% of cases
- **Use vim.loop.spawn()** when you need the extra control
- **Avoid io.popen()** unless you truly need synchronous behavior

### Blocking vs Non-Blocking

**Blocking (BAD in most cases):**
```lua
-- io.popen blocks the entire editor until command completes
local handle = io.popen("find . -type f")
local result = handle:read("*a")  -- BLOCKS HERE for 4 seconds!
handle:close()
-- Editor is frozen during this time
```

**Non-blocking (GOOD):**
```lua
-- Telescope uses async job - returns immediately
local job_id = vim.fn.jobstart({'find', '.', '-type', 'f'}, {
  on_stdout = function(_, data)
    -- Results stream in, editor stays responsive
  end
})
-- Code continues immediately, editor stays responsive
```

### Our Telescope Optimization Explained

**Before (blocking):**
```lua
-- OLD CODE
local handle = io.popen(find_cmd)
local result = handle:read("*a")  -- ← Blocks for 4 seconds
handle:close()
-- Only now can we open picker
```

**After (async):**
```lua
-- NEW CODE
finder = finders.new_oneshot_job(find_command, {
  entry_maker = function(line)
    -- Called for each result as it arrives
    -- Picker already open, stays responsive
  end
})
-- Picker opens instantly!
```

**Process flow:**
```
Old (Blocking):
User presses <leader>fd
   → Execute find command (4 seconds)
   → Parse all results
   → Open picker
   → User can interact

New (Async):
User presses <leader>fd
   → Spawn find job (returns immediately)
   → Open picker (instant!)
   → User can interact
   → Results stream in as found
```

---

## The Event Loop

### How Neovim Processes Events

Neovim's main loop:

```c
// Simplified Neovim main loop (C code)
while (running) {
  // 1. Process input events (keystrokes, mouse)
  input_poll();

  // 2. Run libuv event loop iteration
  uv_run(loop, UV_RUN_NOWAIT);  // Non-blocking!

  // 3. Process Lua callbacks from async operations
  lua_process_callbacks();

  // 4. Update UI if needed
  ui_flush();

  // 5. Run scheduled Lua code (vim.schedule)
  lua_run_scheduled();
}
```

### vim.schedule() - Deferring to Event Loop

Sometimes you need to defer code to the next event loop iteration:

```lua
-- BAD: Modifying buffer from async callback
vim.fn.jobstart({'ls'}, {
  on_stdout = function(_, data)
    -- This might crash! Buffer modifications in async context
    vim.api.nvim_buf_set_lines(0, 0, -1, false, data)
  end
})

-- GOOD: Schedule for next event loop tick
vim.fn.jobstart({'ls'}, {
  on_stdout = function(_, data)
    vim.schedule(function()
      -- Safe: runs in main event loop context
      vim.api.nvim_buf_set_lines(0, 0, -1, false, data)
    end)
  end
})
```

**Why schedule is needed:**

```
Async callback thread     Main event loop thread
      │                          │
      │ on_stdout triggered      │
      │                          │
      ├─ Call vim.schedule()     │
      │                          │
      │                          ├─ Queue callback
      │                          │
      │ Returns                  │
      │                          │
      │                          ├─ Process queue
      │                          │
      │                          └─ Execute callback (SAFE)
```

### Timers

Create periodic or one-shot timers:

```lua
-- Create a timer
local timer = vim.loop.new_timer()

-- Run every 1000ms
timer:start(1000, 1000, function()
  print("Tick")
end)

-- Run once after 5000ms
timer:start(5000, 0, function()
  print("One-shot")
  timer:close()  -- Clean up
end)

-- Stop timer
timer:stop()
```

---

## Plugin Architecture

### Plugin Lifecycle

Modern plugin managers (lazy.nvim) load plugins on-demand:

```lua
{
  "nvim-telescope/telescope.nvim",

  -- Lazy loading triggers:
  cmd = "Telescope",          -- Load on :Telescope command
  keys = "<leader>ff",        -- Load on keypress
  ft = "python",              -- Load on filetype
  event = "VeryLazy",         -- Load after startup

  -- Plugin lifecycle hooks:
  init = function()
    -- Runs BEFORE plugin loads (for setting options)
  end,

  config = function()
    -- Runs AFTER plugin loads (for setup)
    require("telescope").setup({ ... })
  end,
}
```

**Loading sequence:**
```
1. Neovim starts
2. lazy.nvim loads core plugins
3. User presses <leader>ff (lazy-loaded key)
4. lazy.nvim:
   a. Loads telescope.nvim files
   b. Runs config() function
   c. Executes the keymap
```

### Plugin Structure

Well-structured plugins follow this pattern:

```
telescope.nvim/
├── lua/
│   └── telescope/
│       ├── init.lua           -- Main entry point, setup()
│       ├── pickers/
│       │   ├── init.lua
│       │   └── file_pickers.lua
│       ├── finders/
│       │   ├── init.lua
│       │   └── async_job_finder.lua
│       └── actions/
│           └── init.lua
├── plugin/
│   └── telescope.vim          -- Auto-loaded on startup
└── doc/
    └── telescope.txt          -- Help documentation
```

**Module pattern:**
```lua
-- telescope/init.lua
local M = {}

M.setup = function(opts)
  -- Plugin initialization
  M.config = vim.tbl_deep_extend("force", M.config, opts)
end

M.some_function = function()
  -- Plugin functionality
end

return M  -- Export module table
```

### Our Custom Module Design

Our `utils/telescope.lua` follows the same pattern:

```lua
local M = {}  -- Module table

-- Public function
function M.find_directory(opts)
  -- Implementation
end

-- Could add more functions:
function M.find_git_files(opts)
  -- ...
end

return M  -- Export module
```

**Usage:**
```lua
-- Lazy loads on first require()
local telescope_utils = require("utils.telescope")

-- Call functions
telescope_utils.find_directory()
telescope_utils.find_git_files()
```

### Performance Best Practices

1. **Lazy-load everything possible**
   ```lua
   -- BAD: Loads telescope on startup
   local telescope = require("telescope")

   -- GOOD: Only loads when function is called
   function find_files()
     local telescope = require("telescope")
     -- ...
   end
   ```

2. **Use async APIs for I/O**
   ```lua
   -- BAD: Blocks editor
   os.execute("sleep 5")

   -- GOOD: Non-blocking
   vim.defer_fn(function()
     print("5 seconds later")
   end, 5000)
   ```

3. **Debounce expensive operations**
   ```lua
   -- BAD: Runs on every keystroke
   vim.api.nvim_create_autocmd("TextChanged", {
     callback = function()
       expensive_linter()  -- Runs constantly
     end
   })

   -- GOOD: Debounced
   local timer = vim.loop.new_timer()
   vim.api.nvim_create_autocmd("TextChanged", {
     callback = function()
       timer:start(500, 0, vim.schedule_wrap(function()
         expensive_linter()  -- Runs 500ms after typing stops
       end))
     end
   })
   ```

4. **Cache expensive computations**
   ```lua
   local cache = {}

   function get_git_root()
     if cache.git_root then
       return cache.git_root  -- Return cached value
     end

     cache.git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
     return cache.git_root
   end
   ```

---

## Summary

**Key Takeaways:**

1. **LuaJIT is embedded** - Runs in same process as Neovim, provides JIT compilation
2. **Module system** - `require()` with caching, follows runtimepath
3. **Event loop** - libuv provides async I/O, process management, timers
4. **Async is critical** - Use jobstart/vim.system, avoid blocking io.popen
5. **vim.schedule()** - Bridge async callbacks to main thread
6. **Plugin architecture** - Modular design, lazy loading, lifecycle hooks

**Performance hierarchy:**
```
Fastest:  Native Neovim API (vim.api)
Fast:     Cached Lua tables
Medium:   Async I/O (vim.loop, jobstart)
Slow:     Blocking I/O (io.popen, os.execute)
Slowest:  VimScript (use Lua instead!)
```

The directory finder optimization we built demonstrates these principles:
- Async process spawning (new_oneshot_job)
- Streaming results (entry_maker called per-line)
- Non-blocking operation (picker opens instantly)
- Modular design (reusable function)
