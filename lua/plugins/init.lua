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
          hide_numbers = true, -- Hide line numbers in the terminal window
          hide_signcolumn = true, -- Hide the sign column in the terminal window
        },
        -- File refresh settings
        refresh = {
          enable = true, -- Enable file change detection
          updatetime = 100, -- updatetime when Claude Code is active (milliseconds)
          timer_interval = 1000, -- How often to check for file changes (milliseconds)
          show_notifications = true, -- Show notification when files are reloaded
        },
        -- Git project settings
        git = {
          use_git_root = true, -- Set CWD to git root when opening Claude Code (if in git project)
        },
        -- Keymaps
        keymaps = {
          toggle = {
            normal = "<leader>ac", -- Normal mode keymap for toggling Claude Code
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
