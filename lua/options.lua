local g = vim.g

g.mapleader = " "
g.maplocalleader = " "

local opt = vim.opt

opt.wildignore:append { "*/node_modules/*", "*/dist/*", "*/.git/*" }

-- opt.wildignore = opt.wildignore - { ".*", "*/.*" }
-- opt.path:append("**")
-- opt.wildignore:remove(".*")
-- vim.opt.path = { ".", "**" }

opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true -- Use spaces instead of tabs
opt.relativenumber = true
opt.signcolumn = "yes" -- Always show the sign column
opt.ignorecase = true -- Case-insensitive searching

-- Code folding (using treesitter)
opt.foldlevelstart = 99 -- Start with all folds open (global option)

-- Modern approach: v:lua.vim.treesitter.foldexpr() instead of nvim_treesitter#foldexpr()
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "javascript", "typescriptreact", "javascriptreact", "lua", "python", "c_sharp", "cs" },
  callback = function()
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo.foldenable = false -- Don't auto-fold on file open
    vim.wo.foldlevel = 99
    -- Workaround: Update folds after a short delay to fix E490 on file open
    vim.defer_fn(function()
      vim.cmd('normal! zx')
    end, 100)
  end,
})
