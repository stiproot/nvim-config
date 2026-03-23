-- Telescope utility functions
-- This module provides reusable telescope pickers and utilities

local M = {}

--- Finds and displays directories in a telescope picker with full paths from git root
--- This solves the problem of unclear paths in monorepos where multiple services
--- may have identically named directories (e.g., src/__tests__)
---
--- Performance: Uses async job finders to open the picker immediately and stream results
--- Uses 'fd' if available (much faster), falls back to 'find'
---
--- @param opts table|nil Optional configuration
---   - cwd: string - The root directory to search from (defaults to git workspace root)
---   - prompt_title: string - Title for the picker (defaults to "Find Directory")
---   - hidden: boolean - Whether to include hidden directories (defaults to false)
function M.find_directory(opts)
  opts = opts or {}

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local git = require("utils.git")

  local root = opts.cwd or git.get_workspace_root()
  local prompt_title = opts.prompt_title or "Find Directory"
  local hidden = opts.hidden or false

  -- Build the command - prefer 'fd' over 'find' for better performance
  -- fd is a modern, fast alternative to find (https://github.com/sharkdp/fd)
  local find_command

  -- Check if fd is available
  if vim.fn.executable("fd") == 1 then
    -- fd is much faster than find
    -- fd [pattern] [path] --type d: find directories only
    -- --color never: disable color output for parsing
    -- --exclude '.git': exclude .git directories
    -- --hidden: include hidden directories (if opts.hidden = true)
    find_command = { "fd", ".", root, "--type", "d", "--color", "never" }

    if not hidden then
      table.insert(find_command, "--exclude")
      table.insert(find_command, ".*")  -- Exclude hidden dirs (starting with .)
    else
      table.insert(find_command, "--hidden")
    end
  else
    -- Fallback to standard find command
    -- find <path> -type d: find all directories
    -- -not -path '*/.*': exclude hidden directories
    find_command = { "find", root, "-type", "d" }

    if not hidden then
      table.insert(find_command, "-not")
      table.insert(find_command, "-path")
      table.insert(find_command, "*/.*")
    end
  end

  -- Create the telescope picker with async job finder
  pickers.new({}, {
    prompt_title = prompt_title,

    -- new_oneshot_job runs the command asynchronously
    -- This means:
    -- 1. The picker opens IMMEDIATELY (no 4-second wait!)
    -- 2. Results stream in as they're found
    -- 3. You can start typing to filter while results are still loading
    finder = finders.new_oneshot_job(find_command, {
      -- entry_maker processes each line of output from the command
      -- The command outputs absolute paths, we need to make them relative to root
      entry_maker = function(line)
        -- line is the full absolute path like "/Users/foo/project/src/utils"
        -- We want to show it relative to git root like "src/utils"

        -- Make path relative to root
        local relative_path = line
        if line:sub(1, #root) == root then
          relative_path = line:sub(#root + 2)  -- +2 to skip the trailing /
        end

        -- Skip the root directory itself
        if relative_path == "" or relative_path == "." then
          return nil  -- nil entries are filtered out by telescope
        end

        return {
          value = relative_path,      -- Store relative path
          display = relative_path,    -- Show relative path from git root
          ordinal = relative_path,    -- Fuzzy match against relative path
          path = relative_path,       -- Enable path-based features
        }
      end,
    }),

    -- The sorter determines how results are ranked during fuzzy searching
    -- generic_sorter uses telescope's default fuzzy matching algorithm
    sorter = conf.generic_sorter({}),

    -- attach_mappings allows us to customize keybindings within the picker
    -- This is where we define what happens when the user selects a directory
    attach_mappings = function(prompt_bufnr, map)
      -- Replace the default <CR> (Enter) behavior
      actions.select_default:replace(function()
        -- Close the picker
        actions.close(prompt_bufnr)

        -- Get the selected entry (contains the data from entry_maker)
        local selection = action_state.get_selected_entry()

        if selection then
          -- Construct the full absolute path by combining root + relative path
          local full_path = root .. "/" .. selection.path

          -- Open the directory in neovim
          -- fnameescape ensures special characters in paths are handled correctly
          vim.cmd("edit " .. vim.fn.fnameescape(full_path))
        end
      end)

      -- Return true to keep default mappings (like <C-n>, <C-p> for navigation)
      return true
    end,
  }):find()
end

return M
