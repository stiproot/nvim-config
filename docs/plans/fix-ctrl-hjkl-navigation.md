# Implementation Plan: Fix Ctrl+hjkl Navigation in Neovim

## Problem Summary

Ctrl+hjkl key bindings are not working for Neovim window navigation despite being correctly configured in the Neovim keymaps. The issue is that Zellij intercepts these keys in its various modes before they can reach Neovim.

**User's Preferred Solution**: Use Zellij's locked mode when working in Neovim. Locked mode disables all Zellij keybindings except Ctrl+g, allowing all keys to pass through to Neovim.

## Current State

### What's Working ✓
- Neovim keymaps correctly configured in `lua/keymaps.lua:20-24`
- Ctrl+g toggle binding exists in Zellij config (lines 7, 139)
- Ctrl+h entry binding for move mode is commented out (lines 146-147)
- Default mode is set to "normal" (line 283)

### What's Not Working ✗
- User must manually press Ctrl+g every time they open Neovim
- No automatic detection when Neovim is running
- Ctrl+h still bound in move mode itself (line 81) - minor issue

## Solution: Three-Tier Approach

### Tier 1: Automatic Mode Switching (Recommended)
Install and configure `zellij-autolock` plugin to automatically switch to locked mode when Neovim is running.

### Tier 2: Documentation Updates
Update KEYMAPS.md with comprehensive locked mode workflow documentation.

### Tier 3: Optional Visual Feedback
Install `zjstatus` plugin for color-coded mode indicators (only if default status bar is insufficient).

---

## Implementation Steps

### Step 1: Install zellij-autolock Plugin

**What**: Download the autolock WASM plugin that monitors the active process and automatically switches modes.

**Actions**:
1. Create plugins directory:
   ```bash
   mkdir -p ~/.config/zellij/plugins/
   ```

2. Download the plugin:
   ```bash
   curl -L https://github.com/fresh2dev/zellij-autolock/releases/latest/download/zellij-autolock.wasm \
     -o ~/.config/zellij/plugins/zellij-autolock.wasm
   ```

3. Verify download:
   ```bash
   ls -la ~/.config/zellij/plugins/zellij-autolock.wasm
   ```

**Files Modified**: None (creates new file only)

---

### Step 2: Configure zellij-autolock in config.kdl

**What**: Add autolock plugin configuration to the Zellij config file.

**File**: `/Users/simon.stipcich/.config/zellij/config.kdl`

**Location**: Lines 265-266 (inside the `load_plugins` block)

**Change**: Replace the empty `load_plugins {}` block with:

```kdl
load_plugins {
    autolock location="file:~/.config/zellij/plugins/zellij-autolock.wasm" {
        triggers "nvim|vim"
        is_enabled true
        reaction_seconds "0.3"
        print_to_log false
    }
}
```

**Configuration Explanation**:
- `triggers "nvim|vim"` - Activates locked mode when nvim or vim processes detected
- `is_enabled true` - Plugin starts automatically with Zellij
- `reaction_seconds "0.3"` - 300ms delay before mode switch (prevents flickering)
- `print_to_log false` - Keeps logs clean (set to `true` for debugging)

**Optional Enhancement**: Add other tools to triggers if desired:
- `triggers "nvim|vim|fzf|lazygit"` - Locks mode for these tools too

---

### Step 3: Test the Automatic Mode Switching

**What**: Restart Zellij and verify autolock works correctly.

**Actions**:
1. Exit all Zellij sessions:
   ```bash
   zellij kill-all-sessions
   ```

2. Start new Zellij session:
   ```bash
   zellij
   ```

3. Verify normal mode is active (check status bar)

4. Open Neovim:
   ```bash
   nvim test.txt
   ```

5. Status bar should show "LOCKED" after ~300ms

6. Test Ctrl+hjkl navigation:
   - `:vsplit` to create vertical split
   - `:split` to create horizontal split
   - Ctrl+h/j/k/l to navigate between windows
   - All should work smoothly

7. Exit Neovim:
   - `:qa`
   - Status should return to "NORMAL"

8. Verify Zellij commands work again:
   - Ctrl+p should enter pane mode
   - Alt+hjkl should work for pane navigation

**Expected Result**: Automatic mode switching with no manual Ctrl+g required.

---

### Step 4: Update KEYMAPS.md Documentation

**What**: Add comprehensive documentation about locked mode workflow.

**File**: `/Users/simon.stipcich/.config/nvim/KEYMAPS.md`

**Location**: After line 81 (after the Zellij mode switching section)

**Add New Section**:

```markdown
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
```

**Location 2**: Update the "Resolved Conflicts" section (around line 218)

**Modify Section**:

```markdown
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
```

---

### Step 5: (Optional) Install zellij.vim for Enhanced Integration

**What**: Add Neovim plugin that coordinates navigation between Neovim windows and Zellij panes.

**File**: `/Users/simon.stipcich/.config/nvim/lua/plugins/init.lua`

**Location**: Around line 352 (before the closing brace of the plugins table)

**Add Plugin**:

```lua
{
    "fresh2dev/zellij.vim",
    lazy = false,
    config = function()
        -- Plugin works out of the box with zellij-autolock
        -- Provides seamless navigation between Neovim and Zellij panes
    end,
},
```

**Benefit**: When you navigate from a Neovim window to a Zellij pane using Ctrl+hjkl, zellij.vim signals Zellij to switch back to Normal mode automatically.

**Actions**:
1. Add plugin configuration to init.lua
2. Restart Neovim or run `:Lazy sync`
3. Plugin will be automatically loaded on next Neovim start

---

### Step 6: (Optional) Install zjstatus for Visual Feedback

**What**: Install enhanced status bar plugin for color-coded mode indicators.

**Only needed if**: Default status bar mode indicator is not prominent enough.

**Actions**:
1. Download zjstatus:
   ```bash
   curl -L https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm \
     -o ~/.config/zellij/plugins/zjstatus.wasm
   ```

2. Add configuration to config.kdl (in the `plugins` section around line 246)

3. Restart Zellij

**Note**: This is optional and can be added later if needed. The default status bar already shows the current mode.

---

## Troubleshooting Guide

### Issue: Autolock plugin not loading

**Debug**:
1. Check file exists: `ls -la ~/.config/zellij/plugins/zellij-autolock.wasm`
2. Check Zellij version: `zellij --version` (must be 0.41.0+)
3. Enable logging: Set `print_to_log true` in plugin config
4. Check logs: `tail -f /tmp/zellij-*/zellij-log/zellij.log`

### Issue: Mode not switching when opening Neovim

**Debug**:
1. Verify process name: `ps aux | grep nvim` (should show "nvim")
2. Check triggers include "nvim": `triggers "nvim|vim"`
3. Adjust delay: Try `reaction_seconds "0.1"` for faster response
4. Verify `is_enabled true` is set

### Issue: Ctrl+hjkl still not working in Neovim

**Debug**:
1. Verify locked mode is active (status bar shows "LOCKED")
2. Test if ANY Zellij keys work (try Ctrl+p - should type ^P in Neovim if locked)
3. Check Neovim keymaps: `:verbose map <C-h>` in Neovim
4. Try with minimal Neovim config: `nvim --clean`

### Issue: Can't exit locked mode

**Solutions**:
1. Press `Ctrl+g` multiple times
2. Force mode switch: `zellij action switch-mode normal` (from outside Zellij)
3. Detach and reattach: `Ctrl+o` then `d`, then `zellij attach`
4. Kill session: `zellij kill-session <name>`

---

## Rollback Plan

If autolock doesn't work as expected:

1. **Disable autolock**: Edit config.kdl, set `is_enabled false` in autolock block
2. **Remove plugin reference**: Delete or comment out the autolock block in `load_plugins`
3. **Restart Zellij**: `zellij kill-all-sessions` then `zellij`
4. **Use manual workflow**: Document that users must press `Ctrl+g` manually when entering/exiting Neovim

The manual Ctrl+g workflow is always available as a fallback.

---

## Critical Files

- `/Users/simon.stipcich/.config/zellij/config.kdl` - Add autolock plugin config (lines 265-266)
- `/Users/simon.stipcich/.config/nvim/KEYMAPS.md` - Add locked mode documentation (after line 81, update around line 218)
- `/Users/simon.stipcich/.config/nvim/lua/plugins/init.lua` - (Optional) Add zellij.vim plugin (around line 352)
- `~/.config/zellij/plugins/zellij-autolock.wasm` - Download plugin binary

---

## Expected Outcome

After implementation:
- Opening Neovim automatically enables locked mode (~300ms delay)
- Ctrl+hjkl works perfectly for Neovim window navigation
- Exiting Neovim automatically returns to normal mode
- No manual Ctrl+g toggling required for 95% of use cases
- Clear status bar feedback about current mode
- Seamless workflow between Neovim and terminal

**Success Criteria**:
1. Can navigate Neovim splits with Ctrl+hjkl without pressing Ctrl+g
2. Mode switches automatically when entering/exiting Neovim
3. Zellij commands work normally when not in Neovim
4. No conflicts or key interception issues
