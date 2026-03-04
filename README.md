# Neovim Configuration

Personal Neovim configuration with custom keybindings and plugins.

## Color Theme

**xo-theme.nvim** - Custom fork of vscode.nvim with soft pastel matrix-inspired colors
- Location: `/Users/simon.stipcich/code/repo/xo-theme.nvim`
- Base: VSCode dark theme with customized syntax colors
- Features: Soft pastels with greens, blues, purples, and yellows

## Key Features

- **Plugin Manager**: lazy.nvim
- **LSP Support**: TypeScript, Go, and more
- **Fuzzy Finding**: Telescope with fzf extension
- **Git Integration**: fugitive, gitsigns
- **Terminal Integration**: Zellij auto-lock for seamless navigation

## Essential Keybindings

### Leader Key
- Leader: `Space`

### Window Navigation
- `Ctrl+h` - Move to left window
- `Ctrl+j` - Move to window below
- `Ctrl+k` - Move to window above
- `Ctrl+l` - Move to right window

### Buffer Navigation
- `Shift+h` - Previous buffer
- `Shift+l` - Next buffer

### Window Resizing
- `Left Arrow` - Decrease vertical width
- `Right Arrow` - Increase vertical width
- `Up Arrow` - Increase horizontal height
- `Down Arrow` - Decrease horizontal height

## Telescope (Fuzzy Finder)

### Telescope Keybindings
- `<leader>fg` (`Space + f + g`) - **Live grep** - Search text in all files
- `<leader>fr` (`Space + f + r`) - Recent files
- `<leader>fb` (`Space + f + b`) - Search current buffer
- `<leader><leader>` (`Space + Space`) - List buffers

### Navigating Telescope Results

When Telescope picker is open (e.g., after `<leader>fg` for grep):

#### Insert Mode (while typing your search):
- `Ctrl+j` or `Ctrl+n` - Move to next result
- `Ctrl+k` or `Ctrl+p` - Move to previous result
- `Enter` - Open the selected file at that match
- `Ctrl+q` - Send all results to quickfix list
- `Esc` - Close the picker or switch to normal mode

#### Normal Mode (press `Esc` to enter):
- `j` - Move to next result
- `k` - Move to previous result
- `Ctrl+j` - Move to next result (alternative)
- `Ctrl+k` - Move to previous result (alternative)
- `Enter` - Open the selected file
- `q` - Close the picker

#### Tips:
1. **Filter as you type**: In insert mode, just keep typing to narrow down results
2. **Use quickfix**: Press `Ctrl+q` to send results to quickfix, then:
   - `:copen` - Open quickfix window
   - `:cnext` or `:cn` - Next match
   - `:cprev` or `:cp` - Previous match
3. **Switch modes**: `Esc` to go to normal mode, `i` or `a` to return to insert mode

### Telescope Layout
- Results list on the left
- Live preview on the right (60% width)
- Auto-adjusts based on window size

## LSP Keybindings (when LSP is attached)

### Navigation
- `gd` - Go to definition
- `gD` - Go to declaration
- `gr` - Find references
- `gi` - Go to implementation

### Documentation
- `K` - Hover documentation
- `Ctrl+k` (insert mode) - Signature help

### Refactoring
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code actions
- `<leader>f` - Format document

### Diagnostics
- `[d` - Previous diagnostic
- `]d` - Next diagnostic
- `<leader>e` - Show diagnostic float

## Visual Mode
- `p` - Paste over selection without yanking
- `<` - Indent left (stays in visual mode)
- `>` - Indent right (stays in visual mode)

## Other Useful Bindings
- `<leader>p` - Print full path of current file

## Zellij Integration

### Auto-lock Plugin
The configuration includes `zellij-autolock` which automatically:
- Switches to LOCKED mode when Neovim is running
- Allows Ctrl+hjkl to work for window navigation
- Returns to NORMAL mode when exiting Neovim

### Manual Toggle
- `Ctrl+g` - Toggle between locked and normal mode in Zellij

For detailed Zellij and Yabai keybindings, see [KEYMAPS.md](./KEYMAPS.md)

## Installation

1. Clone this repository to `~/.config/nvim`
2. Install Neovim >= 0.9.0
3. Open Neovim - lazy.nvim will automatically install plugins
4. Restart Neovim

## File Structure

```
~/.config/nvim/
├── init.lua              # Entry point
├── lua/
│   ├── options.lua       # Vim options
│   ├── keymaps.lua       # Key mappings
│   ├── config/
│   │   └── lazy.lua      # Plugin manager setup
│   └── plugins/
│       └── init.lua      # Plugin configurations
├── docs/
│   └── plans/            # Implementation plans
├── KEYMAPS.md           # Comprehensive keybinding reference
└── README.md            # This file
```

## macOS Terminal Configuration

For Alt/Option keys to work properly in iTerm2:
1. Go to: iTerm2 → Preferences → Profiles → Keys
2. Set Left Option key to: `Esc+`
3. Set Right Option key to: `Esc+`
4. **UNCHECK** "Apps can change this" for both
5. Restart iTerm2 completely

## Documentation

- **KEYMAPS.md** - Complete keybinding reference for Neovim, Zellij, and Yabai
- **docs/plans/** - Implementation planning documents
