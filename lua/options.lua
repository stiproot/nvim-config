local g = vim.g

g.mapleader = " "
g.maplocalleader = " "

local opt = vim.opt

opt.wildignore:append { "*/node_modules/*", "*/dist/*", "*/.git/*" }
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true -- Use spaces instead of tabs
opt.relativenumber = true
opt.signcolumn = "yes" -- Always show the sign column
