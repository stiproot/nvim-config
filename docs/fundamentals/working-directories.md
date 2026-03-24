# Working Directories in Neovim

Understanding the difference between buffer paths and working directories.

## The Lore: Why Working Directories Exist

### Historical Context

The concept of "current working directory" comes from Unix philosophy (1970s):

**The Unix Mental Model:**
- Programs operate on files
- Files are referenced by paths (absolute or relative)
- Every process has a "current working directory" (cwd)
- Relative paths resolve from cwd

When you open a terminal and type `cd /home/user/project`, you're changing the shell's working directory. Any program you launch inherits this directory.

**Vim inherited this model:**
```bash
$ cd /home/user/myproject
$ vim src/main.c

# Inside Vim:
:pwd
# → /home/user/myproject (inherited from shell)

:edit utils.c
# → Opens /home/user/myproject/utils.c (relative to cwd)
```

### The Fundamental Principle

**Working directory is the "context" for your work.**

Think of it as answering: "What project am I currently working on?"

- Your shell has a cwd
- Neovim has a cwd
- LSP servers have a cwd
- Git commands use a cwd
- Build tools use a cwd

Everything that resolves relative paths or "knows where it is" uses a working directory.

### The Evolution: `:lcd` and `:tcd`

**Original Vim (1991):** Only had `:cd` (global)
- Problem: Opening a file in a different project changed cwd for everything
- Example: You're editing `/proj1/main.c`, you `:edit /proj2/test.c`, now `:!make` runs in the wrong project!

**Vim 7.0 (2006):** Added `:lcd` (local to window)
- Philosophy: Different windows can work in different contexts
- Use case: Split between frontend/backend, each with its own build system

**Vim 7.3 (2010):** Added `:tcd` (tab-local)
- Philosophy: Tabs represent different projects/contexts
- Use case: Tab 1 = Project A, Tab 2 = Project B

### The Mental Model

```
┌─────────────────────────────────────────────────────┐
│ Operating System                                    │
│ - File system exists here                           │
│ - Absolute paths: /home/user/project/src/main.c     │
└─────────────────────────────────────────────────────┘
                        ▲
                        │
┌───────────────────────┴─────────────────────────────┐
│ Neovim Process                                      │
│ - Needs a "starting point" for relative paths       │
│ - Working directory = "Where am I working?"         │
│                                                     │
│ ┌─────────────────────────────────────────────────┐ │
│ │ Global CWD (:cd)                                │ │
│ │ Default: "My main project"                      │ │
│ │ /home/user/myproject                            │ │
│ └─────────────────────────────────────────────────┘ │
│                        ▲                            │
│         Can be overridden per-tab                   │
│                        │                            │
│ ┌─────────────────────┴─────────────────────────┐   │
│ │ Tab 1 CWD (:tcd)                              │   │
│ │ "This tab is for project B"                   │   │
│ │ /home/user/other-project                      │   │
│ └───────────────────────────────────────────────┘   │
│                        ▲                            │
│         Can be overridden per-window                │
│                        │                            │
│ ┌─────────────────────┴─────────────────────────┐   │
│ │ Window 1 CWD (:lcd)                           │   │
│ │ "This window is working in the frontend"      │   │
│ │ /home/user/other-project/frontend             │   │
│ └───────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

## What Operations Are Affected by Working Directory?

### 1. Relative Path Resolution

**The most fundamental effect:**

```vim
:pwd
" → /home/user/project

:edit src/main.c
" Resolves to: /home/user/project/src/main.c

:edit ../other-project/test.c
" Resolves to: /home/user/other-project/test.c

" With lcd:
:lcd /home/user/different-place
:edit src/main.c
" Now resolves to: /home/user/different-place/src/main.c
```

**Everything using relative paths is affected:**
- `:edit`, `:split`, `:vsplit`, `:tabedit`
- `:read`, `:write`, `:saveas`
- `:source`
- File globbing (`:args **/*.lua`)

### 2. Shell Commands (`:!` and `:terminal`)

**Every shell command inherits the working directory:**

```vim
:pwd
" → /home/user/myproject

:!git status
" Runs git in: /home/user/myproject

:!npm test
" Runs npm in: /home/user/myproject

:!ls
" Lists files in: /home/user/myproject
```

**With `:lcd`, each window runs commands in different places:**

```vim
" Window 1:
:lcd ~/project/frontend
:!npm run dev
" → Starts frontend dev server

" Window 2 (split):
:lcd ~/project/backend
:!cargo run
" → Starts backend server

" Both servers running, controlled from different windows!
```

### 3. File Finding (`:find`, `gf`, etc.)

Vim's file searching uses `path` option + working directory:

```vim
:set path=.,src,include
:pwd
" → /home/user/project

" Press 'gf' on "utils.h"
" Searches:
" 1. /home/user/project/utils.h (.)
" 2. /home/user/project/src/utils.h
" 3. /home/user/project/include/utils.h

:find main.c
" Searches in path, starting from cwd
```

### 4. Language Server Protocol (LSP)

**Most LSP servers use the working directory as the "project root":**

```vim
:pwd
" → /home/user/myproject

" Start LSP server (e.g., rust-analyzer, typescript-language-server)
" LSP inherits cwd: /home/user/myproject
" LSP considers this the "workspace root"
```

**What LSP uses cwd for:**
- Finding `package.json`, `Cargo.toml`, `tsconfig.json`
- Resolving imports (`import { foo } from './utils'`)
- Finding project dependencies
- Setting up build configurations

**Important gotcha:**

```vim
" Start Neovim from home directory
:pwd
" → /home/user

:edit ~/myproject/src/main.ts
" LSP starts, but cwd is /home/user (wrong!)
" LSP can't find package.json
" Auto-imports break, type checking fails

" Solution: Change to project root
:cd ~/myproject
:LspRestart  " Restart with correct cwd
```

### 5. Telescope and Fuzzy Finders

**Default behavior: search from working directory**

```lua
require('telescope.builtin').find_files()
-- Searches from vim.fn.getcwd()

require('telescope.builtin').live_grep()
-- Greps from vim.fn.getcwd()
```

**With `:lcd`, you can have different search contexts per window:**

```vim
" Window 1: Search in frontend
:lcd ~/monorepo/frontend
:Telescope find_files
" → Searches only frontend/

" Window 2: Search in backend
:lcd ~/monorepo/backend
:Telescope find_files
" → Searches only backend/
```

### 6. Git Operations

Git commands use working directory to find `.git`:

```vim
:pwd
" → /home/user/project/src/utils

:!git status
" Git walks up from /home/user/project/src/utils
" Finds .git in /home/user/project
" Shows status of entire repo

:lcd /tmp
:!git status
" → Error: not a git repository (pwd is /tmp)
```

**Our git utilities do the same:**

```lua
-- From utils/git.lua
function M.get_git_root()
  -- Searches upward from getcwd() for .git
  local dot_git_path = vim.fn.finddir(".git", ".;")
  return vim.fn.fnamemodify(dot_git_path, ":h")
end
```

### 7. Build Systems and Task Runners

**Make, npm, cargo, etc. all use working directory:**

```vim
:pwd
" → /home/user/project

:!make
" Looks for Makefile in /home/user/project

:!npm test
" Looks for package.json in /home/user/project

:!cargo build
" Looks for Cargo.toml in /home/user/project
```

**Multi-window builds:**

```vim
" Window 1: Frontend build
:lcd ~/project/frontend
:terminal
$ npm run build

" Window 2: Backend build
:lcd ~/project/backend
:terminal
$ cargo build --release

" Different terminals in different contexts!
```

### 8. Plugin Behavior

**Many plugins respect working directory:**

- **NERDTree/nvim-tree**: Opens at cwd by default
- **Fugitive**: Runs git commands in cwd
- **FZF**: Searches from cwd
- **Linters**: Run in cwd (affects which config files are loaded)
- **Formatters**: Run in cwd (affects which config files are found)

### 9. What's NOT Affected

These things work independently of cwd:

- **Buffer file paths** - Absolute, doesn't change
- **Marks** - Stored with absolute paths
- **Registers** - Content is independent
- **Most Vim settings** - Not path-related
- **Plugin installations** - Stored in fixed locations

## The Philosophy: When to Use Each

### Use `:cd` (Global) When...

**Philosophy:** "I'm working on one project for this entire session"

**Use cases:**
```vim
" Single project development
$ cd ~/myproject
$ nvim

# Everything in this session is about myproject
:!git status    # myproject git
:!npm test      # myproject tests
:Telescope      # myproject files
```

**Advantages:**
- Simple, predictable
- All operations in same context
- Good for focused work

**Disadvantages:**
- Opening files from other projects changes global context
- All windows/tabs share same context

**Best for:**
- Single-project work sessions
- Beginners
- Simple workflows

### Use `:tcd` (Tab-local) When...

**Philosophy:** "Each tab is a different project/context"

**Use cases:**
```vim
" Tab 1: Working on project A
:tcd ~/projectA
:edit src/main.c

" Tab 2: Working on project B
:tabnew
:tcd ~/projectB
:edit src/server.js

" Tab 3: Editing config files
:tabnew
:tcd ~/.config

# Each tab is a separate workspace
```

**Mental model:**
```
Tab 1: Project A    Tab 2: Project B    Tab 3: Dotfiles
├─ Window 1         ├─ Window 1         ├─ Window 1
├─ Window 2         └─ Window 2         └─ Window 2
└─ Window 3
All use ~/projectA  All use ~/projectB  All use ~/.config
```

**Advantages:**
- Organize work by project
- All windows in tab share context
- Easy to switch projects (just switch tabs)

**Disadvantages:**
- Need to remember which tab is which project
- All windows in tab must share same context

**Best for:**
- Multi-project workflows
- Keeping different contexts separate
- Project-based organization

### Use `:lcd` (Window-local) When...

**Philosophy:** "This specific window needs its own context"

**Use cases:**

#### 1. Monorepo with Multiple Services
```vim
" You have: /monorepo/{frontend,backend,mobile}

" Window 1: Frontend
:lcd ~/monorepo/frontend
:edit src/App.tsx
:!npm run dev

" Window 2: Backend
:split
:lcd ~/monorepo/backend
:edit src/main.rs
:!cargo run

" Window 3: Mobile
:vsplit
:lcd ~/monorepo/mobile
:edit src/App.kt
:!./gradlew run

" Each window operates in its own service!
```

#### 2. Source + Build Directory
```vim
" Window 1: Source files
:lcd ~/project/src
:edit main.cpp

" Window 2: Build directory
:split
:lcd ~/project/build
:terminal
$ make && ./myapp
```

#### 3. Code + Test Directories
```vim
" Window 1: Implementation
:lcd ~/project/src
:edit user.ts

" Window 2: Tests
:split
:lcd ~/project/__tests__
:edit user.test.ts
:!npm test user
```

#### 4. Different Git Worktrees
```vim
" You have git worktrees:
" ~/project/main (main branch)
" ~/project/feature-x (feature branch)

" Window 1: Main branch
:lcd ~/project/main
:edit src/core.ts
:!git status    # Shows main branch

" Window 2: Feature branch
:split
:lcd ~/project/feature-x
:edit src/core.ts
:!git status    # Shows feature-x branch

" Compare implementations side-by-side!
```

**Advantages:**
- Maximum flexibility
- Each window is independent
- Perfect for complex layouts

**Disadvantages:**
- Can be confusing (which window is where?)
- Easy to forget which window has which lcd
- More cognitive overhead

**Best for:**
- Advanced users
- Complex multi-context workflows
- Monorepo development
- Build/test/run workflows

## Real-World Workflow Examples

### Workflow 1: Simple Single Project

**Setup:**
```bash
$ cd ~/myproject
$ nvim
```

**Inside Neovim:**
```vim
:pwd
" → ~/myproject

" Never use :cd/:lcd/:tcd
" Everything works from ~/myproject
" Simple and predictable
```

**When to use:** Solo projects, focused work, learning

---

### Workflow 2: Multi-Project Tabs

**Setup:**
```bash
$ nvim
```

**Inside Neovim:**
```vim
" Tab 1: Work project
:tcd ~/work/api-server
:edit src/main.go
:!go test ./...

" Tab 2: Personal project
:tabnew
:tcd ~/personal/blog
:edit posts/new-post.md
:!hugo serve

" Tab 3: Open source contribution
:tabnew
:tcd ~/oss/neovim
:edit src/nvim/api/vim.c
:!make

" Switch tabs = switch projects
```

**When to use:** Frequent context switching, multiple active projects

---

### Workflow 3: Monorepo Mastery

**Project structure:**
```
/monorepo
├── packages/
│   ├── web/      (React app)
│   ├── api/      (Node backend)
│   └── shared/   (Shared code)
└── tools/        (Build scripts)
```

**Inside Neovim:**
```vim
" Global: Set to monorepo root
:cd ~/monorepo

" Window 1: Web package (upper left)
:lcd packages/web
:edit src/App.tsx
:!npm run dev    # Runs in packages/web

" Window 2: API package (lower left)
:split
:lcd packages/api
:edit src/server.ts
:!npm test       # Runs in packages/api

" Window 3: Shared (upper right)
:vsplit
:lcd packages/shared
:edit src/utils.ts

" Window 4: Root terminal (lower right)
:split
:lcd .           # Back to root
:terminal
$ npm run build-all

" Layout:
" ┌─────────┬─────────┐
" │ Web     │ Shared  │
" ├─────────┼─────────┤
" │ API     │ Root    │
" └─────────┴─────────┘
```

**When to use:** Monorepos, microservices, complex projects

---

### Workflow 4: The LSP-Aware Setup

**Problem:** LSP needs correct project root

**Solution:**
```vim
" Start Neovim anywhere
$ nvim ~/projects/myapp/src/nested/deep/file.ts

" Inside Neovim - file is open but LSP might be wrong
:pwd
" → /home/user (wrong!)

" Fix: Change to project root
:cd ~/projects/myapp
:LspRestart

" Now LSP works correctly
" Auto-imports, type checking, etc. all work
```

**Better: Auto-detect project root**
```lua
-- In your config
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    -- Find project root (has package.json, .git, etc.)
    local root = vim.fs.dirname(vim.fs.find({
      'package.json', 'Cargo.toml', '.git'
    }, { upward = true })[1])

    if root then
      vim.cmd('lcd ' .. vim.fn.fnameescape(root))
    end
  end,
})
```

**When to use:** Projects with LSP, auto-imports, type checking

## Practical Rules of Thumb

1. **Default to `:cd` at start of session**
   ```bash
   $ cd ~/myproject && nvim
   ```

2. **Use `:tcd` when you have multiple distinct projects**
   - One tab per project
   - Easy mental model

3. **Use `:lcd` when you need fine-grained control**
   - Monorepos
   - Build systems
   - Side-by-side comparisons

4. **Always check `:pwd` when things break**
   - LSP not working? Check `:pwd`
   - Git commands failing? Check `:pwd`
   - Files not found? Check `:pwd`

5. **Set lcd to buffer's directory when needed**
   ```vim
   :lcd %:p:h
   ```

6. **Create keymap for common operations**
   ```lua
   vim.keymap.set('n', '<leader>cd', ':lcd %:p:h<CR>:pwd<CR>')
   ```

## The Three Types of Working Directories

Neovim has three scopes for the current working directory (cwd):

### 1. Global Directory (`:cd`)
```vim
:cd /path/to/project
```
- Sets working directory for **all windows and tabs**
- Check with: `:pwd`
- This is the default - affects everything

### 2. Tab Directory (`:tcd`)
```vim
:tcd /path/to/other-project
```
- Sets working directory for **current tab only**
- All windows in this tab use this directory
- Overrides global `:cd` for this tab
- Check with: `:pwd`

### 3. Local Directory (`:lcd`)
```vim
:lcd /path/to/specific-dir
```
- Sets working directory for **current window only**
- Overrides both `:tcd` and `:cd`
- Each window can have its own `lcd`
- Check with: `:pwd`

## Priority Order

When Neovim resolves the current working directory:

```
1. Window local directory (:lcd)     ← Highest priority
2. Tab local directory (:tcd)
3. Global directory (:cd)            ← Lowest priority (default)
```

## Important: Buffer Path ≠ Working Directory

**Buffer path**: Where the file lives
```vim
:edit /home/user/project/src/main.lua
" Buffer contains: /home/user/project/src/main.lua
```

**Working directory**: Where relative paths resolve from
```vim
:pwd
" Shows: /home/user/different-place
```

These are **independent**! The working directory does NOT automatically change when you open a file.

## Practical Example

```vim
" Start Neovim in home directory
$ nvim
:pwd
" → /home/user

" Open a file from a project
:edit /home/user/projects/myapp/src/main.lua
:pwd
" → Still /home/user (working directory didn't change!)

" The buffer knows its file path
:echo expand('%:p')
" → /home/user/projects/myapp/src/main.lua

" But working directory is still home
:!ls
" → Lists files in /home/user (NOT /home/user/projects/myapp/src/)

" Now change local directory for this window
:lcd %:p:h
" %:p:h means: current file (%), full path (:p), head/directory (:h)
:pwd
" → /home/user/projects/myapp/src

" Now relative operations use this directory
:!ls
" → Lists files in /home/user/projects/myapp/src/
```

## Why This Matters

Working directory affects:

1. **Relative file paths**
   ```vim
   :lcd /home/user/project
   :edit src/main.lua  " → Opens /home/user/project/src/main.lua
   ```

2. **Shell commands**
   ```vim
   :lcd /home/user/project
   :!git status  " → Runs in /home/user/project
   ```

3. **File finding**
   ```vim
   :lcd /home/user/project
   :find **/*.lua  " → Searches from /home/user/project
   ```

4. **Telescope and other plugins**
   ```lua
   -- Most pickers respect working directory by default
   require('telescope.builtin').find_files()
   -- Searches from current working directory
   ```

## Multi-Window Workflow

This is where `:lcd` shines:

```vim
" Window 1: Working on frontend
:lcd ~/projects/myapp/frontend
:edit src/App.tsx

" Split to Window 2: Working on backend
:split
:lcd ~/projects/myapp/backend
:edit src/main.rs

" Split to Window 3: Working on docs
:vsplit
:lcd ~/projects/myapp/docs
:edit README.md

" Each window now has its own working directory!
" File operations in each window resolve relative paths differently
```

**Visualization:**
```
┌─────────────────────────┬────────────────────────┐
│ Window 1                │ Window 3               │
│ :lcd ~/proj/frontend    │ :lcd ~/proj/docs       │
│ App.tsx                 │ README.md              │
│                         │                        │
│ :!npm test              │ :!mdbook build         │
│ (runs in frontend/)     │ (runs in docs/)        │
├─────────────────────────┴────────────────────────┤
│ Window 2                                         │
│ :lcd ~/proj/backend                              │
│ main.rs                                          │
│                                                  │
│ :!cargo test                                     │
│ (runs in backend/)                               │
└──────────────────────────────────────────────────┘
```

## Checking Current Directory

```vim
" Show working directory for current window
:pwd

" In Lua
:lua print(vim.fn.getcwd())

" Get window-specific directory
:lua print(vim.fn.getcwd(0))    -- Current window (respects :lcd)

" Get tab-specific directory
:lua print(vim.fn.getcwd(-1, 0)) -- Current tab (respects :tcd)

" Get global directory
:lua print(vim.fn.getcwd(-1, -1)) -- Global (from :cd)
```

## Auto-changing Directory

Some people want the working directory to automatically follow the buffer:

### Option 1: `autochdir` (Simple, Global)
```vim
set autochdir
```
- Automatically changes global directory to match current buffer
- Affects all windows
- Can break plugins that expect stable working directory
- **Generally not recommended**

### Option 2: Autocmd (More Control)
```lua
-- Auto-set lcd to buffer's directory
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    local bufpath = vim.api.nvim_buf_get_name(0)
    if bufpath ~= "" then
      local dir = vim.fn.fnamemodify(bufpath, ":h")
      vim.cmd("lcd " .. vim.fn.fnameescape(dir))
    end
  end,
})
```
- Uses `:lcd` so only affects current window
- More predictable than `autochdir`

### Option 3: Manual (Recommended)
```lua
-- Keymap to set lcd to current buffer's directory
vim.keymap.set('n', '<leader>cd', function()
  local dir = vim.fn.expand('%:p:h')
  vim.cmd('lcd ' .. vim.fn.fnameescape(dir))
  print('lcd: ' .. dir)
end, { desc = "Set lcd to buffer directory" })
```
- Full control over when to change
- Most predictable
- **Best practice for most users**

## Common Use Cases

### 1. Monorepo with Multiple Services
```vim
" Working in a monorepo
" /project/services/auth/
" /project/services/api/
" /project/services/web/

" Window 1: Auth service
:lcd ~/project/services/auth
:edit src/main.ts
:!npm test  " → Runs in auth/

" Window 2: API service
:split
:lcd ~/project/services/api
:edit src/server.ts
:!npm test  " → Runs in api/
```

### 2. Multiple Projects
```vim
" Tab 1: Project A
:tcd ~/projects/projectA
:Telescope find_files  " → Searches projectA

" Tab 2: Project B
:tabnew
:tcd ~/projects/projectB
:Telescope find_files  " → Searches projectB
```

### 3. Separate Build Directories
```vim
" Window 1: Source code
:lcd ~/project/src
:edit main.cpp

" Window 2: Build directory
:split
:lcd ~/project/build
:terminal
" cmake .. && make
```

## How Our Git Utils Handle This

In our config, `git.get_workspace_root()` finds the git root:

```lua
-- From lua/utils/git.lua
function M.get_git_root()
  local dot_git_path = vim.fn.finddir(".git", ".;")
  return vim.fn.fnamemodify(dot_git_path, ":h")
end
```

This searches **upward from the current working directory** for `.git`:

```vim
:pwd
" → /home/user/project/src/utils

:lua print(require('utils.git').get_git_root())
" → /home/user/project  (found .git here)
```

**Important**: `get_git_root()` starts searching from `:pwd`, not from buffer location!

```lua
-- If you're in the wrong directory:
:cd /tmp
:edit ~/myproject/src/main.lua

-- This will fail to find git root:
:lua print(require('utils.git').get_git_root())
-- → /tmp (no .git found)

-- Solution: Set working directory to project
:lcd %:p:h  -- Change to buffer's directory
-- Or better:
:lcd ~/myproject  -- Change to project root
```

## Best Practices

1. **Use `:lcd` for window-specific contexts** (different services, build dirs)
2. **Use `:tcd` for tab-specific projects** (different git repos)
3. **Use `:cd` sparingly** (affects everything)
4. **Avoid `autochdir`** (breaks plugins, unpredictable)
5. **Use keymap for manual lcd** (`<leader>cd` to change to buffer dir)
6. **Be aware plugins use cwd** (Telescope, LSP, etc. often start from `:pwd`)

## Checking What Directory Will Be Used

```lua
-- See what directory a command will use
:lua print(vim.fn.getcwd())  -- Window's effective working directory

-- Debug all three levels
:lua print("Global:", vim.fn.getcwd(-1, -1))
:lua print("Tab:", vim.fn.getcwd(-1, 0))
:lua print("Window:", vim.fn.getcwd(0))
```

## Summary

| Concept | Description | How to Set | Scope |
|---------|-------------|------------|-------|
| **Buffer path** | Where the file lives | `:edit /path/to/file` | Per buffer |
| **Global cwd** | Default working dir | `:cd /path` | All windows/tabs |
| **Tab cwd** | Tab's working dir | `:tcd /path` | Current tab |
| **Window cwd** | Window's working dir | `:lcd /path` | Current window |

**Key Takeaway**: Buffer location and working directory are completely separate. Working directory affects where relative paths resolve, shell commands run, and where plugins search - it does NOT automatically follow the buffer!
