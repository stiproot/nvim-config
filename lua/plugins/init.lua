local git = require("utils.git")

return {

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "config.lspconfig"
    end,
  },

  {
  	"nvim-treesitter/nvim-treesitter",
  	opts = {
  		ensure_installed = {
  		  "vim", "lua", "vimdoc",
        "html", "css", "c_sharp"
  		},
  	},
  },

  { "github/copilot.vim", lazy = false },

  { "tpope/vim-vinegar", lazy = false },

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
    "neovim/nvim-lspconfig",
    config = function()
      require "config.lspconfig"
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
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
          if git.is_git_repo() then
            require("telescope.builtin").git_files({ cwd = git.get_workspace_root() })
          else
            require("telescope.builtin").find_files({ cwd = git.get_workspace_root() })
          end
        end,
        desc = "Find files",
      },
      {
        "<leader>fg",
        function()
          require("telescope.builtin").live_grep({ cwd = git.get_workspace_root() })
        end,
        desc = "Live grep",
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
  }
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
