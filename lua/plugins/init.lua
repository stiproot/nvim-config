local git = require("utils.git")

return {

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "config.lspconfig"
    end,
  },

  -- Completion framework
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",  -- Lazy-load on entering insert mode
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",     -- LSP completions
      "hrsh7th/cmp-buffer",       -- Buffer words
      "hrsh7th/cmp-path",         -- File paths
      "L3MON4D3/LuaSnip",         -- Snippet engine
      "saadparwaiz1/cmp_luasnip", -- Snippet completions
    },
    config = function()
      require("config.cmp")
    end,
  },

  {
  	"nvim-treesitter/nvim-treesitter",
  	opts = {
  		ensure_installed = {
  		  "vim", "lua", "vimdoc",
        "html", "css", "c_sharp",
        "typescript", "javascript", "tsx", "json",
        "markdown", "markdown_inline"
  		},
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
  	},
  },

  -- { "github/copilot.vim", lazy = false },

  { "tpope/vim-vinegar", lazy = false },

  -- Git integration
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse" },
  },

  -- GitHub integration - PR comments, issues, reviews
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = "Octo",
    config = function()
      require("octo").setup({
        use_local_fs = false,                -- Use working directory or remote files
        enable_builtin = false,              -- Don't override vim.ui.select/input
        default_remote = {"upstream", "origin"},
        default_merge_method = "squash",     -- Valid values: merge, rebase, squash
        ssh_aliases = {
          ["github.com-work"] = "github.com" -- Map SSH alias to actual GitHub domain
        },
        picker = "telescope",
        picker_config = {
          use_emojis = true,                 -- Show emoji reactions in picker
        },
        comment_icon = "▎",                  -- Comment marker
        outdated_icon = "󰅒 ",               -- Outdated comment marker
        resolved_icon = " ",                -- Resolved thread marker
        reaction_viewer_hint_icon = " ",    -- Reaction hint
        user_icon = " ",                    -- User icon
        timeline_marker = " ",              -- Timeline marker
        timeline_indent = 2,                 -- Timeline indent (number, not string)
        right_bubble_delimiter = "",        -- Bubble delimiters for comments
        left_bubble_delimiter = "",
        github_hostname = "",                -- For GitHub Enterprise, leave empty for github.com
        snippet_context_lines = 4,           -- Lines of context for code snippets
        gh_env = {},                         -- Extra env vars for 'gh' CLI
        timeout = 5000,                      -- HTTP timeout
        ui = {
          use_signcolumn = true,             -- Show signs for comments
        },
        issues = {
          order_by = {
            field = "CREATED_AT",
            direction = "DESC"
          },
        },
        pull_requests = {
          order_by = {
            field = "CREATED_AT",
            direction = "DESC"
          },
          always_select_remote_on_create = false,
        },
        file_panel = {
          size = 10,                         -- File panel height (% or lines)
          use_icons = true,
        },
        mappings = {
          -- These are the default keymaps - you can customize in keymaps.lua if needed
          issue = {
            close_issue = { lhs = "<space>ic", desc = "close issue" },
            reopen_issue = { lhs = "<space>io", desc = "reopen issue" },
            list_issues = { lhs = "<space>il", desc = "list open issues" },
            reload = { lhs = "<C-r>", desc = "reload issue" },
            open_in_browser = { lhs = "<C-b>", desc = "open issue in browser" },
            copy_url = { lhs = "<C-y>", desc = "copy url to clipboard" },
            add_assignee = { lhs = "<space>aa", desc = "add assignee" },
            remove_assignee = { lhs = "<space>ad", desc = "remove assignee" },
            create_label = { lhs = "<space>lc", desc = "create label" },
            add_label = { lhs = "<space>la", desc = "add label" },
            remove_label = { lhs = "<space>ld", desc = "remove label" },
            goto_issue = { lhs = "<space>gi", desc = "navigate to issue" },
            add_comment = { lhs = "<space>ca", desc = "add comment" },
            delete_comment = { lhs = "<space>cd", desc = "delete comment" },
            next_comment = { lhs = "]c", desc = "next comment" },
            prev_comment = { lhs = "[c", desc = "prev comment" },
            react_hooray = { lhs = "<space>rp", desc = "react with 🎉" },
            react_heart = { lhs = "<space>rh", desc = "react with ❤️" },
            react_eyes = { lhs = "<space>re", desc = "react with 👀" },
            react_thumbs_up = { lhs = "<space>r+", desc = "react with 👍" },
            react_thumbs_down = { lhs = "<space>r-", desc = "react with 👎" },
            react_rocket = { lhs = "<space>rr", desc = "react with 🚀" },
            react_laugh = { lhs = "<space>rl", desc = "react with 😄" },
            react_confused = { lhs = "<space>rc", desc = "react with 😕" },
          },
          pull_request = {
            checkout_pr = { lhs = "<space>po", desc = "checkout PR" },
            merge_pr = { lhs = "<space>pm", desc = "merge PR" },
            list_commits = { lhs = "<space>pc", desc = "list PR commits" },
            list_changed_files = { lhs = "<space>pf", desc = "list PR changed files" },
            show_pr_diff = { lhs = "<space>pd", desc = "show PR diff" },
            add_reviewer = { lhs = "<space>va", desc = "add reviewer" },
            remove_reviewer = { lhs = "<space>vd", desc = "remove reviewer" },
            close_issue = { lhs = "<space>ic", desc = "close PR" },
            reopen_issue = { lhs = "<space>io", desc = "reopen PR" },
            list_issues = { lhs = "<space>il", desc = "list open issues" },
            reload = { lhs = "<C-r>", desc = "reload PR" },
            open_in_browser = { lhs = "<C-b>", desc = "open PR in browser" },
            copy_url = { lhs = "<C-y>", desc = "copy url to clipboard" },
            goto_file = { lhs = "gf", desc = "go to file" },
            add_assignee = { lhs = "<space>aa", desc = "add assignee" },
            remove_assignee = { lhs = "<space>ad", desc = "remove assignee" },
            create_label = { lhs = "<space>lc", desc = "create label" },
            add_label = { lhs = "<space>la", desc = "add label" },
            remove_label = { lhs = "<space>ld", desc = "remove label" },
            goto_issue = { lhs = "<space>gi", desc = "navigate to issue" },
            add_comment = { lhs = "<space>ca", desc = "add comment" },
            delete_comment = { lhs = "<space>cd", desc = "delete comment" },
            next_comment = { lhs = "]c", desc = "next comment" },
            prev_comment = { lhs = "[c", desc = "prev comment" },
            react_hooray = { lhs = "<space>rp", desc = "react with 🎉" },
            react_heart = { lhs = "<space>rh", desc = "react with ❤️" },
            react_eyes = { lhs = "<space>re", desc = "react with 👀" },
            react_thumbs_up = { lhs = "<space>r+", desc = "react with 👍" },
            react_thumbs_down = { lhs = "<space>r-", desc = "react with 👎" },
            react_rocket = { lhs = "<space>rr", desc = "react with 🚀" },
            react_laugh = { lhs = "<space>rl", desc = "react with 😄" },
            react_confused = { lhs = "<space>rc", desc = "react with 😕" },
          },
          review_thread = {
            goto_issue = { lhs = "<space>gi", desc = "navigate to issue" },
            add_comment = { lhs = "<space>ca", desc = "add comment" },
            add_suggestion = { lhs = "<space>sa", desc = "add suggestion" },
            delete_comment = { lhs = "<space>cd", desc = "delete comment" },
            next_comment = { lhs = "]c", desc = "next comment" },
            prev_comment = { lhs = "[c", desc = "prev comment" },
            select_next_entry = { lhs = "]q", desc = "next entry" },
            select_prev_entry = { lhs = "[q", desc = "prev entry" },
            close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
            react_hooray = { lhs = "<space>rp", desc = "react with 🎉" },
            react_heart = { lhs = "<space>rh", desc = "react with ❤️" },
            react_eyes = { lhs = "<space>re", desc = "react with 👀" },
            react_thumbs_up = { lhs = "<space>r+", desc = "react with 👍" },
            react_thumbs_down = { lhs = "<space>r-", desc = "react with 👎" },
            react_rocket = { lhs = "<space>rr", desc = "react with 🚀" },
            react_laugh = { lhs = "<space>rl", desc = "react with 😄" },
            react_confused = { lhs = "<space>rc", desc = "react with 😕" },
          },
          submit_win = {
            approve_review = { lhs = "<C-a>", desc = "approve review" },
            comment_review = { lhs = "<C-m>", desc = "comment review" },
            request_changes = { lhs = "<C-r>", desc = "request changes" },
            close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
          },
          review_diff = {
            add_review_comment = { lhs = "<space>ca", desc = "add review comment" },
            add_review_suggestion = { lhs = "<space>sa", desc = "add review suggestion" },
            focus_files = { lhs = "<leader>e", desc = "focus files panel" },
            toggle_files = { lhs = "<leader>b", desc = "toggle files panel" },
            next_thread = { lhs = "]t", desc = "next thread" },
            prev_thread = { lhs = "[t", desc = "prev thread" },
            select_next_entry = { lhs = "]q", desc = "next entry" },
            select_prev_entry = { lhs = "[q", desc = "prev entry" },
            close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
            toggle_viewed = { lhs = "<leader><space>", desc = "toggle viewer viewed state" },
            goto_file = { lhs = "gf", desc = "go to file" },
          },
          file_panel = {
            next_entry = { lhs = "j", desc = "next entry" },
            prev_entry = { lhs = "k", desc = "prev entry" },
            select_entry = { lhs = "<cr>", desc = "select entry" },
            refresh_files = { lhs = "R", desc = "refresh files" },
            focus_files = { lhs = "<leader>e", desc = "focus files panel" },
            toggle_files = { lhs = "<leader>b", desc = "toggle files panel" },
            select_next_entry = { lhs = "]q", desc = "next entry" },
            select_prev_entry = { lhs = "[q", desc = "prev entry" },
            close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
            toggle_viewed = { lhs = "<leader><space>", desc = "toggle viewer viewed state" },
          },
        },
      })
    end,
  },

  {
    "greggh/claude-code.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim", -- For git operations
    },
    config = function()
      require("claude-code").setup({
        -- Terminal window settings
        window = {
          height_ratio = 0.5, -- Percentage of screen height for the terminal window
          position = "botright", -- Position of the window: "botright", "topleft", etc.
          enter_insert = true, -- Whether to enter insert mode when opening Claude Code
          hide_numbers = false, -- Hide line numbers in the terminal window
          hide_signcolumn = false, -- Hide the sign column in the terminal window
        },
        -- File refresh settings
        refresh = {
          enable = true, -- Enable file change detection
          updatetime = 100, -- updatetime when Claude Code is active (milliseconds)

          show_notifications = true, -- Show notification when files are reloaded
        },
        -- Git project settings
        git = {
          use_git_root = true, -- Set CWD to git root when opening Claude Code (if in git project)
        },
        -- Keymaps
        keymaps = {
          toggle = {
            normal = "<leader>cc", -- Normal mode keymap for toggling Claude Code
            terminal = "<C-,>", -- Terminal mode keymap for toggling Claude Code
          },
        },
      })
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({
        preset = "modern",
      })

      -- Add group labels for better organization
      wk.add({
        { "<leader>f", group = "Find (Telescope)" },
        { "<leader>g", group = "Git" },
        { "<leader>c", group = "Change directory / Code" },
        { "<leader>t", group = "Tabs" },
        { "<leader>y", group = "Yank path" },
      })
    end,
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },

  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "VeryLazy",
    submodules = false,  -- Skip submodules to avoid "Could not access submodule 'test/bin'" error
    config = function()
      -- Load rainbow delimiters with a better strategy than the default
      local rainbow_delimiters = require("rainbow-delimiters")

      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          vim = rainbow_delimiters.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
          javascript = "rainbow-delimiters-react",
          tsx = "rainbow-parens",
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
        blacklist = { "html" }, -- Disable for HTML (often looks busy)
      }

      -- patch https://github.com/nvim-treesitter/nvim-treesitter/issues/1124
      if vim.fn.expand("%:p") ~= "" then
        vim.cmd.edit({ bang = true })
      end
    end,
  },

  -- {
  --   "Mofiqul/vscode.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require('vscode').setup({
  --       transparent = false,
  --       italic_comments = true,
  --       disable_nvimtree_bg = true,
  --     })
  --     require('vscode').load()
  --   end,
  -- },

  {
    "stiproot/xo-theme.nvim",
    dir = "/Users/simon.stipcich/code/repo/xo-theme.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require('vscode').setup({
        transparent = false,
        italic_comments = true,
        disable_nvimtree_bg = true,
      })
      require('vscode').load()
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      {
        "<leader>ff",
        function()
          -- Find files from current window's working directory (respects :lcd)
          local cwd = vim.fn.getcwd()
          if git.is_git_repo() then
            require("telescope.builtin").git_files({ cwd = cwd })
          else
            require("telescope.builtin").find_files({ cwd = cwd })
          end
        end,
        desc = "Find files (from pwd)",
      },
      {
        "<leader>fg",
        function()
          -- Live grep from current window's working directory (respects :lcd)
          local cwd = vim.fn.getcwd()
          require("telescope.builtin").live_grep({ cwd = cwd })
        end,
        desc = "Live grep (from pwd)",
      },
      {
        "<leader>fF",
        function()
          -- Find files from git workspace root (Global)
          if git.is_git_repo() then
            require("telescope.builtin").git_files({ cwd = git.get_workspace_root() })
          else
            require("telescope.builtin").find_files({ cwd = git.get_workspace_root() })
          end
        end,
        desc = "Find files (from git root)",
      },
      {
        "<leader>fG",
        function()
          -- Live grep from git workspace root (Global)
          require("telescope.builtin").live_grep({ cwd = git.get_workspace_root() })
        end,
        desc = "Live grep (from git root)",
      },
      {
        "<leader>fr",
        function()
          require("telescope.builtin").oldfiles()
        end,
        desc = "Recent files",
      },
      {
        "<leader>fb",
        function()
          require("telescope.builtin").current_buffer_fuzzy_find()
        end,
        desc = "Search current buffer",
      },
      {
        "<leader><leader>",
        function()
          require("telescope.builtin").buffers()
        end,
        desc = "List buffers",
      },
      {
        "<leader>fh",
        function()
          require("telescope.builtin").help_tags()
        end,
        desc = "Help tags",
      },
      {
        "<leader>cc",
        function()
          require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
        end,
        desc = "Search config files",
      },
      {
        "<leader>fu",
        function()
          require("telescope.builtin").resume()
        end,
        desc = "Resume last picker",
      },
      {
        "<leader>fl",
        function()
          require("telescope.builtin").current_buffer_fuzzy_find()
        end,
        desc = "Search lines in current buffer",
      },
      -- Additional Telescope-specific pickers
      {
        "<leader>fc",
        function()
          require("telescope.builtin").commands()
        end,
        desc = "List commands",
      },
      {
        "<leader>fs",
        function()
          require("telescope.builtin").lsp_document_symbols()
        end,
        desc = "Document symbols",
      },
      {
        "<leader>fP",
        function()
          require("telescope.builtin").builtin()
        end,
        desc = "List pickers",
      },
      {
        "<leader>fd",
        function()
          -- Find directory from current window's working directory (respects :lcd)
          local cwd = vim.fn.getcwd()
          require("utils.telescope").find_directory({ cwd = cwd })
        end,
        desc = "Find directory (from pwd)",
      },
      {
        "<leader>fD",
        function()
          -- Find directory from git workspace root (Global)
          require("utils.telescope").find_directory({ cwd = git.get_workspace_root() })
        end,
        desc = "Find directory (from git root)",
      },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-n>"] = actions.move_selection_next,
              ["<C-p>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<Esc>"] = actions.close,
              ["<C-u>"] = false,
              ["<C-d>"] = false,
            },
            n = {
              ["j"] = actions.move_selection_next,
              ["k"] = actions.move_selection_previous,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["q"] = actions.close,
            },
          },
          file_ignore_patterns = {
            "node_modules",
            ".git/",
            "vendor/",
            ".cache",
            "%.o",
            "%.a",
            "%.out",
            "%.class",
            "%.pdf",
            "%.mkv",
            "%.mp4",
            "%.zip",
          },
          path_display = { "smart" },
          dynamic_preview_title = true,
          layout_strategy = "flex",
          layout_config = {
            horizontal = {
              preview_width = 0.6,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
          },
        },
        pickers = {
          find_files = {
            theme = "ivy",
            previewer = true,
            hidden = true,
          },
          git_files = {
            theme = "ivy",
            previewer = true,
          },
          buffers = {
            theme = "ivy",
            previewer = true,
            sort_lastused = true,
            sort_mru = true,
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      })

      -- Load extensions
      telescope.load_extension("fzf")
    end,
  },

  {
    "NvChad/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },

  {
    "fresh2dev/zellij.vim",
    lazy = false,
    config = function()
      -- Plugin works out of the box with zellij-autolock
      -- Provides seamless navigation between Neovim and Zellij panes
    end,
  },

  {
    dir = vim.fn.stdpath("config") .. "/lua/cc-agent",
    name = "cc-agent",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("cc-agent").setup({})
    end,
  },

  {
    dir = "/Users/simon.stipcich/code/repo/code-playground.nvim",
    name = "code-playground",
    lazy = false,
    config = function()
      require("code-playground").setup({
        split_direction = "vsplit",  -- Vertical split with output on the right
        auto_change_cwd = false,     -- Don't change working directory automatically
        animation = "wave"           -- Loading animation style
      })
    end,
  },

}

-- Add these plugins to your return table in lua/plugins/init.lua
-- {
--   "mfussenegger/nvim-dap",
--   dependencies = {
--     "rcarriga/nvim-dap-ui",
--     "theHamsta/nvim-dap-virtual-text",
--     "nvim-neotest/nvim-nio"
--   },
--   config = function()
--     local dap = require("dap")
--     local dapui = require("dapui")
    
--     -- Setup DAP UI
--     dapui.setup()
    
--     -- Setup virtual text
--     require("nvim-dap-virtual-text").setup()
    
--     -- Configure .NET debugger
--     dap.adapters.coreclr = {
--       type = 'executable',
--       command = '/path/to/netcoredbg', -- You'll need to install netcoredbg
--       args = {'--interpreter=vscode'}
--     }
    
--     dap.configurations.cs = {
--       {
--         type = "coreclr",
--         name = "launch - netcoredbg",
--         request = "launch",
--         program = function()
--           return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
--         end,
--       },
--     }
    
--     -- Auto open/close DAP UI
--     dap.listeners.after.event_initialized["dapui_config"] = function()
--       dapui.open()
--     end
--     dap.listeners.before.event_terminated["dapui_config"] = function()
--       dapui.close()
--     end
--     dap.listeners.before.event_exited["dapui_config"] = function()
--       dapui.close()
--     end
--   end,
-- },

-- {
--   "nvim-neotest/neotest",
--   dependencies = {
--     "nvim-neotest/nvim-nio",
--     "nvim-lua/plenary.nvim",
--     "antoinemadec/FixCursorHold.nvim",
--     "nvim-treesitter/nvim-treesitter",
--     "Issafalcon/neotest-dotnet"
--   },
--   config = function()
--     require("neotest").setup({
--       adapters = {
--         require("neotest-dotnet")
--       }
--     })
--   end,
-- }
