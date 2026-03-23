# Vim/Neovim View Primitives

A comprehensive guide to understanding buffers, windows, tabs, and working directories in Vim/Neovim.

## The Three Main Primitives

### 1. Buffers

**What**: In-memory representation of a file
**Think**: The actual file content loaded into memory
**Key point**: A buffer exists even when not visible

#### Commands
```vim
:ls                    " List all buffers
:bnext or :bn          " Next buffer
:bprev or :bp          " Previous buffer
:buffer 3 or :b3       " Switch to buffer 3
:bdelete or :bd        " Delete/close buffer
```

**Example**: Open 5 files = 5 buffers in memory, but you might only see 1 at a time.

### 2. Windows

**What**: A viewport that displays a buffer
**Think**: A frame/pane showing content
**Key point**: Multiple windows can show the same buffer

#### Commands
```vim
:split or :sp          " Horizontal split (new window)
:vsplit or :vsp        " Vertical split (new window)
<C-w>w                 " Cycle through windows
<C-w>q                 " Close current window
<C-w>o                 " Close all other windows
<C-w>h/j/k/l          " Navigate windows
```

#### Visual Example
```
┌─────────┬─────────┐
│ Window1 │ Window2 │  ← 2 windows
│ Buffer1 │ Buffer2 │  ← Each showing different buffer
└─────────┴─────────┘
```

### 3. Tabs (Tab Pages)

**What**: A collection of windows
**Think**: A workspace/layout container
**Key point**: Each tab has its own window layout

#### Commands
```vim
:tabnew                " New tab
:tabnext or gt         " Next tab
:tabprev or gT         " Previous tab
:tabclose              " Close current tab
:tabonly               " Close all other tabs
```

#### Visual Example
```
Tab 1:                    Tab 2:
┌─────────┬─────────┐    ┌─────────────────┐
│ Window1 │ Window2 │    │    Window1      │
│ Buffer1 │ Buffer2 │    │    Buffer3      │
├─────────┴─────────┤    ├─────────────────┤
│     Window3       │    │    Window2      │
│     Buffer4       │    │    Buffer5      │
└───────────────────┘    └─────────────────┘
```

## Relationship Between Primitives

```
Neovim Instance
├── Tab 1 (window layout)
│   ├── Window 1 → Buffer 3
│   └── Window 2 → Buffer 7
├── Tab 2 (different layout)
│   ├── Window 1 → Buffer 3  (same buffer as Tab 1!)
│   ├── Window 2 → Buffer 1
│   └── Window 3 → Buffer 5
└── Tab 3
    └── Window 1 → Buffer 2

All buffers (1-7) exist in memory regardless of visibility
```

## Working Directory Context

Each primitive can have its own working directory, creating a hierarchy of scope.

### Global (`:cd`)
- Affects entire Neovim instance
- All new windows/tabs use this directory

### Tab-local (`:tcd`)
- Affects only the current tab
- New windows in this tab use this directory
- **Perfect for git worktrees!**

### Window-local (`:lcd`)
- Affects only the current window
- Most specific scope

#### Commands
```vim
:pwd                   " Show current working directory
:cd /path              " Change global directory
:tcd /path             " Change tab-local directory
:lcd /path             " Change window-local directory
```

### Priority Hierarchy

When determining working directory:
**window-local** > **tab-local** > **global**

## Practical Use Cases

### Use Case 1: Multiple Files, Single Project

```vim
:cd ~/projects/myapp           " Set global directory
:e src/main.js                 " Buffer 1
:vs src/utils.js               " Buffer 2 in new window
:sp test/main.test.js          " Buffer 3 in new window
```

### Use Case 2: Git Worktrees (One per Tab)

**Best strategy**: One worktree per tab using `:tcd`

```vim
" Tab 1 - worktree A
:tcd ~/projects/repo-feature-a
:e src/file.js
:vs src/other.js               " Split windows - all use feature-a
:Git status                    " Works on worktree A

" Tab 2 - worktree B
:tabnew
:tcd ~/projects/repo-feature-b
:e src/file.js
:vs src/other.js               " Split windows - all use feature-b
:Git status                    " Works on worktree B

" Switch between tabs
gt                             " Next tab
gT                             " Previous tab
```

This keeps each worktree isolated to a tab, and all windows in that tab share the same git context.

### Use Case 3: Comparing Same File Across Branches

```vim
" Tab 1 - main branch
:tcd ~/projects/repo-main
:e src/file.js

" Tab 2 - feature branch
:tabnew
:tcd ~/projects/repo-feature
:e src/file.js

" Now you can toggle between tabs to compare the same file
```

### Use Case 4: Multiple Projects Simultaneously

```vim
" Tab 1 - Frontend project
:tcd ~/projects/frontend
:e src/App.js
:vs src/api.js

" Tab 2 - Backend project
:tabnew
:tcd ~/projects/backend
:e src/server.js
:vs src/routes.js

" Tab 3 - Documentation
:tabnew
:tcd ~/projects/docs
:e README.md
```

## Quick Reference

| Primitive | Scope | Command to Create | Command to Navigate |
|-----------|-------|-------------------|---------------------|
| Buffer | File in memory | `:e file.txt` | `:bn`, `:bp`, `:b3` |
| Window | Viewport | `:sp`, `:vs` | `<C-w>w`, `<C-w>hjkl` |
| Tab | Layout | `:tabnew` | `gt`, `gT`, `:tabn` |

| Working Dir | Scope | Command | Use Case |
|-------------|-------|---------|----------|
| Global | All tabs/windows | `:cd` | Single project |
| Tab-local | Current tab | `:tcd` | Multiple worktrees |
| Window-local | Current window | `:lcd` | Mixed directories |

## Tips

1. **Buffers are persistent**: Closing a window doesn't delete the buffer
2. **Tabs are layouts**: Don't think of them like browser tabs; they're workspace layouts
3. **One project per tab**: Use `:tcd` to set the context for the entire tab
4. **List everything**:
   - `:ls` - See all buffers
   - `:tabs` - See all tabs
   - `<C-w>v` then `<C-w>w` - Create and cycle through windows
