# Claude Code Rules for Neovim Config

## Keymap Documentation

**IMPORTANT**: Whenever `lua/keymaps.lua` is modified, you MUST update `KEYMAPS.md` to reflect the changes.

### Process:

1. **Read both files**:
   - Read `lua/keymaps.lua` to understand all current keymaps
   - Read `KEYMAPS.md` to see the current documentation

2. **Identify changes**:
   - Find keymaps that were added, removed, or modified
   - Note the key binding, mode, and description

3. **Update KEYMAPS.md**:
   - Add new keymaps to the appropriate section
   - Remove keymaps that no longer exist
   - Update descriptions if they changed
   - Maintain the existing structure and formatting
   - Keep sections organized (Path utilities, Working directory, Git, LSP, etc.)

4. **Verify completeness**:
   - Ensure ALL keymaps from `lua/keymaps.lua` are documented
   - Check that the documentation is accurate and helpful

### Current Keymap Sections in KEYMAPS.md:

- Window Navigation
- Buffer Navigation
- Tab Navigation
- Window Resizing
- Visual Mode
- LSP (when LSP is attached)
- Telescope (when picker is open)
- Git (vim-fugitive)
- Other (catch-all for misc keymaps)

### Example:

If a user adds this to `lua/keymaps.lua`:
```lua
map("n", "<leader>cd", function()
  vim.cmd('lcd %:p:h')
end, { desc = "Set lcd to buffer directory" })
```

You should add to the "Other" section in KEYMAPS.md:
```markdown
### Other
- `<leader>cd` - Set lcd to buffer directory
```

Or create a new section if it makes sense:
```markdown
### Working Directory
- `<leader>cd` - Set lcd to buffer directory
```

## Plugin Configuration

When modifying `lua/plugins/init.lua`:

1. **Check for new keymaps**: Plugin configurations often include `keys` sections
2. **Document them**: If new keymaps are added, update KEYMAPS.md
3. **Check README.md**: The main README also has a quick reference for common keymaps - update if needed

## Documentation Standards

- Use clear, concise descriptions
- Include the mode (normal, visual, insert) if not obvious
- Group related keymaps together
- Use backticks for key combinations: `<leader>ff`
- Use hyphens for lists
- Keep formatting consistent with existing style

## File Organization

When creating new utility modules:
- Place in `lua/utils/`
- Follow the module pattern (return table with functions)
- Add documentation comments
- Consider adding a doc in `docs/fundamentals/` if it's a significant feature
