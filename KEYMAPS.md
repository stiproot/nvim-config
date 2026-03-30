# Keybindings Reference

This document tracks all custom keybindings across the development environment.

## Neovim

### Window Navigation
- `Ctrl+h` - Move to left window
- `Ctrl+j` - Move to window below
- `Ctrl+k` - Move to window above
- `Ctrl+l` - Move to right window

### Buffer Navigation
- `Shift+h` - Previous buffer
- `Shift+l` - Next buffer

### Tab Navigation
- `<leader>tn` - New tab
- `<leader>tc` - Close tab
- `<leader>to` - Close other tabs
- `]t` - Next tab
- `[t` - Previous tab

### Window Resizing
- `Left Arrow` - Decrease vertical width
- `Right Arrow` - Increase vertical width
- `Up Arrow` - Increase horizontal height
- `Down Arrow` - Decrease horizontal height

### Visual Mode
- `p` - Paste over selection without yanking
- `<` - Indent left (stays in visual mode)
- `>` - Indent right (stays in visual mode)

### File Navigation (netrw)
- `-` - Move up directory (vim-vinegar)
- `<leader>-` - Open netrw at git workspace root

### LSP (when LSP is attached)
**Navigation:**
- `gd` - Go to definition
- `gD` - Go to declaration
- `gr` - Find references
- `gi` - Go to implementation

**Documentation:**
- `K` - Hover documentation
- `Ctrl+k` (insert mode) - Signature help

**Refactoring:**
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code actions
- `<leader>f` - Format document

**Diagnostics:**
- `[e` - Previous diagnostic
- `]e` - Next diagnostic
- `<leader>e` - Show diagnostic float

### Telescope

**Launching pickers:**
- `<leader>ff` - Find files (from pwd, respects :lcd)
- `<leader>fg` - Live grep (from pwd, respects :lcd)
- `<leader>fd` - Find directory (from pwd, respects :lcd)
- `<leader>fF` - Find files (from git workspace root)
- `<leader>fG` - Live grep (from git workspace root)
- `<leader>fD` - Find directory (from git workspace root)
- `<leader>fr` - Recent files
- `<leader>fb` - Search current buffer
- `<leader>fh` - Help tags
- `<leader>?` - Buffer local keymaps (which-key)

**When picker is open:**

*Insert mode:*
- `Ctrl+j` - Move to next selection
- `Ctrl+k` - Move to previous selection
- `Ctrl+n` - Move to next selection
- `Ctrl+p` - Move to previous selection
- `Ctrl+q` - Send to quickfix list
- `Esc` - Close picker

*Normal mode:*
- `j` - Move to next selection
- `k` - Move to previous selection
- `Ctrl+j` - Move to next selection
- `Ctrl+k` - Move to previous selection
- `q` - Close picker

### Git (vim-fugitive)
**Custom Keybindings:**
- `<leader>gs` - Git status
- `<leader>gb` - Git blame
- `<leader>gd` - Git diff
- `<leader>gl` - Git log
- `<leader>gp` - Git push

**Git Status Window (`:Git`):**
- `s` - Stage file
- `u` - Unstage file
- `=` - Toggle inline diff
- `dd` - Open diff in horizontal split
- `dv` - Open diff in vertical split
- `i` - Show/hide inline patch
- `cc` - Create commit
- `Enter` - Open file
- `o` - Open in horizontal split
- `O` - Open in new tab
- `g?` - Show all keybindings

### GitHub (octo.nvim)

**Opening PRs/Issues:**
- `:Octo pr list` - List pull requests
- `:Octo pr search` - Search pull requests
- `:Octo issue list` - List issues
- `:Octo issue search` - Search issues

**When viewing a PR/Issue:**

*Navigation:*
- `]c` - Next comment
- `[c` - Previous comment
- `]t` - Next thread (in review diff)
- `[t` - Previous thread (in review diff)
- `]q` - Next entry
- `[q` - Previous entry
- `gf` - Go to file

*Comments:*
- `<space>ca` - Add comment
- `<space>cd` - Delete comment
- `<space>sa` - Add suggestion (code review)

*Reactions (emoji):*
- `<space>r+` - React with 👍
- `<space>r-` - React with 👎
- `<space>rh` - React with ❤️
- `<space>rp` - React with 🎉
- `<space>rr` - React with 🚀
- `<space>re` - React with 👀
- `<space>rl` - React with 😄
- `<space>rc` - React with 😕

*PR Management:*
- `<space>po` - Checkout PR locally
- `<space>pm` - Merge PR
- `<space>pc` - List PR commits
- `<space>pf` - List PR changed files
- `<space>pd` - Show PR diff
- `<space>va` - Add reviewer
- `<space>vd` - Remove reviewer

*Issue/PR Actions:*
- `<space>ic` - Close issue/PR
- `<space>io` - Reopen issue/PR
- `<space>il` - List open issues
- `<space>aa` - Add assignee
- `<space>ad` - Remove assignee
- `<space>la` - Add label
- `<space>ld` - Remove label
- `<space>lc` - Create label
- `<space>gi` - Navigate to issue

*Other:*
- `<C-r>` - Reload PR/issue
- `<C-b>` - Open in browser
- `<C-y>` - Copy URL to clipboard

**Review Diff Panel:**
- `<leader>e` - Focus files panel
- `<leader>b` - Toggle files panel
- `<leader><space>` - Toggle file viewed state

**Submit Review:**
- `<C-a>` - Approve review
- `<C-m>` - Comment review
- `<C-r>` - Request changes
- `<C-c>` - Close review tab

### Path Utilities
- `<leader>p` - Show full path of current file
- `<leader>yp` - Copy full path to clipboard
- `<leader>yr` - Copy relative path to clipboard

### Working Directory Management
- `<leader>cd` - Set lcd to buffer directory
- `<leader>cD` - Set lcd to git workspace root
- `<leader>cT` - Set tcd to git workspace root
- `<leader>ce` - Edit lcd command (pre-filled with git root path)

---

## Zellij

### Mode Switching
- `Ctrl+g` - Toggle locked mode
- `Ctrl+p` - Switch to pane mode
- `Ctrl+t` - Switch to tab mode
- `Ctrl+n` - Switch to resize mode
- `Ctrl+s` - Switch to scroll mode
- `Ctrl+o` - Switch to session mode
- `Ctrl+b` - Switch to tmux mode
- `Ctrl+q` - Quit Zellij
- ~~`Ctrl+h` - Switch to move mode~~ **DISABLED** (conflicts with Neovim window navigation)

### Locked Mode (Neovim Integration)

Zellij's locked mode disables all Zellij keybindings, allowing applications like Neovim to receive all keyboard input directly.

#### Manual Toggle
- `Ctrl+g` - Toggle between locked and normal mode

#### Automatic Mode Switching (with zellij-autolock plugin)
- **Entering Neovim** → Automatically switches to LOCKED mode
- **Exiting Neovim** → Automatically switches to NORMAL mode
- **Switching panes** → Mode adjusts based on active process
- Manual toggle (`Ctrl+g`) still available as override

#### How Locked Mode Works

**When in LOCKED mode:**
- All Zellij keybindings disabled (`Ctrl+p`, `Ctrl+t`, etc.)
- Neovim receives all key combinations directly (including `Ctrl+hjkl`)
- Only `Ctrl+g` remains active to exit locked mode
- Status bar displays "LOCKED" or shows locked mode indicator

**When in NORMAL mode:**
- All Zellij keybindings active
- `Ctrl+hjkl` intercepted by Zellij (but Ctrl+h disabled in this config)
- Use `Alt+hjkl` for Zellij pane navigation
- Status bar displays "NORMAL" or shows current Zellij mode

#### Workflow Examples

**Example 1: Editing in Neovim (with autolock)**
1. Open Neovim: `nvim myfile.txt`
2. Mode automatically switches to LOCKED
3. Create splits: `:vsplit`, `:split`
4. Navigate windows: `Ctrl+h/j/k/l` works perfectly
5. Exit Neovim: `:qa`
6. Mode automatically returns to NORMAL

**Example 2: Manual Toggle (without autolock)**
1. Open Neovim: `nvim myfile.txt`
2. Press `Ctrl+g` to enter LOCKED mode
3. Navigate with `Ctrl+h/j/k/l`
4. Exit Neovim: `:qa`
5. Press `Ctrl+g` to return to NORMAL mode

**Example 3: Switching Between Apps**
1. Neovim in one pane, terminal in another
2. In Neovim pane → Status shows LOCKED
3. Switch to terminal: `Alt+l` (Zellij global binding)
4. In terminal pane → Status shows NORMAL
5. Switch back: `Alt+h`
6. Automatically back in LOCKED mode

### Pane Mode (`Ctrl+p` to enter)
- `h/j/k/l` or `Left/Down/Up/Right` - Move focus between panes
- `n` - New pane
- `d` - New pane below
- `r` - New pane to the right
- `x` - Close focused pane
- `f` - Toggle fullscreen
- `w` - Toggle floating panes
- `z` - Toggle pane frames
- `c` - Rename pane
- `e` - Toggle pane embed or floating
- `p` - Switch focus

### Tab Mode (`Ctrl+t` to enter)
- `h/k/Left/Up` - Go to previous tab
- `j/l/Down/Right` - Go to next tab
- `1-9` - Go to tab by number
- `n` - New tab
- `x` - Close tab
- `r` - Rename tab
- `s` - Toggle active sync tab
- `Tab` - Toggle between tabs
- `[` - Break pane to left
- `]` - Break pane to right
- `b` - Break pane

### Resize Mode (`Ctrl+n` to enter)
- `h/j/k/l` - Increase size in direction
- `H/J/K/L` - Decrease size in direction
- `+/=` - Increase size
- `-` - Decrease size

### Move Mode (no default binding - Ctrl+h was disabled)
- `h/j/k/l` or `Left/Down/Up/Right` - Move pane in direction
- `n` - Move pane
- `p` - Move pane backwards
- `Tab` - Move pane

### Scroll Mode (`Ctrl+s` to enter)
- `j/Down` - Scroll down
- `k/Up` - Scroll up
- `h/Left/PageUp` - Page scroll up
- `l/Right/PageDown` - Page scroll down
- `u` - Half page scroll up
- `d` - Half page scroll down
- `Ctrl+b` - Page scroll up
- `Ctrl+f` - Page scroll down
- `Ctrl+c` - Scroll to bottom and exit to normal mode
- `e` - Edit scrollback
- `s` - Enter search mode
- `Alt+h/j/k/l` - Move focus and exit to normal mode

### Global (available in most modes)
- `Alt+h` - Move focus left (or tab if at edge)
- `Alt+j` - Move focus down
- `Alt+k` - Move focus up
- `Alt+l` - Move focus right (or tab if at edge)
- `Alt+n` - New pane
- `Alt+f` - Toggle floating panes
- `Alt+[` - Previous swap layout
- `Alt+]` - Next swap layout
- `Alt+i` - Move tab left
- `Alt+o` - Move tab right
- `Alt++/Alt+=` - Increase size
- `Alt+-` - Decrease size

### tmux Mode (`Ctrl+b` to enter)
- `h/j/k/l` or `Left/Down/Up/Right` - Move focus and exit to normal mode
- `"` - New pane below
- `%` - New pane right
- `c` - New tab
- `n` - Go to next tab
- `p` - Go to previous tab
- `x` - Close focused pane
- `z` - Toggle fullscreen
- `o` - Focus next pane
- `,` - Rename tab
- `[` - Enter scroll mode
- `d` - Detach session
- `Space` - Next swap layout
- `Ctrl+b` - Send literal Ctrl+b to terminal

---

## Yabai (via skhd)

### Window Focus
- `Alt+h` - Focus window to the left
- `Alt+j` - Focus window below
- `Alt+k` - Focus window above
- `Alt+l` - Focus window to the right

### Window Swap/Move
- `Alt+Shift+h` - Swap window left (or move to display left)
- `Alt+Shift+j` - Swap window down (or move to display down)
- `Alt+Shift+k` - Swap window up (or move to display up)
- `Alt+Shift+l` - Swap window right (or move to display right)
- `Alt+Shift+Left/Down/Up/Right` - Same as above using arrow keys

### Window Insertion Point
- `Alt+Ctrl+h` - Set insertion point west
- `Alt+Ctrl+j` - Set insertion point south
- `Alt+Ctrl+k` - Set insertion point north
- `Alt+Ctrl+l` - Set insertion point east
- `Alt+Ctrl+Left/Down/Up/Right` - Same as above using arrow keys

### Workspace Navigation
- `Alt+b` - Go back to previous workspace

### Move Window to Workspace
- `Alt+Shift+1-9` - Move window to workspace 1-9
- `Alt+Shift+0` - Move window to workspace 9
- `Alt+Shift+b` - Move window to previous workspace

### Layout Management
- `Alt+e` - Set layout to BSP (binary space partition)
- `Alt+f` - Set layout to float (also toggles zoom-fullscreen)
- `Alt+w` - Set layout to stack (also closes window)
- `Alt+Shift+y` - Mirror space on y-axis
- `Alt+Shift+x` - Mirror space on x-axis
- `Alt+Shift+0` - Balance window sizes

### Window Actions
- `Alt+f` - Toggle zoom-fullscreen
- `Alt+Shift+f` - Toggle native fullscreen
- `Alt+w` - Close focused window

### Stack Cycling
- `Alt+p` - Focus next stack window (or south)
- `Alt+n` - Focus previous stack window (or north)

---

## Conflicts & Notes

### Resolved Conflicts
1. **Zellij `Ctrl+h`** - Disabled to allow Neovim window navigation
2. **Yabai `Alt+hjkl`** - Conflicts with initial Neovim attempt, switched Neovim to `Ctrl+hjkl`
3. **Zellij Locked Mode** - Configured with zellij-autolock plugin to automatically enable when Neovim is running, passing all keys through to Neovim

### Current Configuration Strategy
- **Neovim**: Uses `Ctrl+hjkl` for window navigation
- **Zellij (Normal mode)**: Uses `Alt+hjkl` for pane navigation
- **Zellij (Locked mode)**: All bindings disabled, Neovim gets full keyboard access
- **Automatic switching**: zellij-autolock detects Neovim and switches modes automatically

### Potential Future Enhancements
- Add `fzf` to autolock triggers for fuzzy finder locked mode
- Add `lazygit` to autolock triggers for seamless TUI navigation
- Install zjstatus plugin for color-coded mode indicators
- Neovim LSP uses `Ctrl+k` in insert mode for signature help (no conflict with window navigation in normal mode)

### macOS Terminal Configuration
For Alt/Option keys to work properly in iTerm2:
1. Go to: iTerm2 → Preferences → Profiles → Keys
2. Set Left Option key to: `Esc+`
3. Set Right Option key to: `Esc+`
4. UNCHECK "Apps can change this" for both
5. Restart iTerm2 completely

---

## Layer Priority

When a key is pressed, it's intercepted in this order:

1. **skhd** (system-level) - Yabai window management
2. **Zellij** (terminal multiplexer) - Tab/pane management
3. **Neovim** (application) - Editor commands

This means:
- `Alt+hjkl` never reaches Zellij or Neovim (captured by skhd/yabai)
- `Ctrl+hjkl` can reach Neovim if not captured by Zellij
- Keys only bound in Neovim work normally when Neovim has focus
