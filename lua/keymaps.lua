local map = vim.keymap.set

-- Resizing panes
map("n", "<Left>", ":vertical resize -1<CR>")
map("n", "<Right>", ":vertical resize +1<CR>")
map("n", "<Up>", ":resize +1<CR>")
map("n", "<Down>", ":resize -1<CR>")

-- Buffer navigation
map("n", "<S-l>", ":bn<CR>")
map("n", "<S-h>", ":bp<CR>")

-- Paste over currently selected text without yanking it
map("v", "p", '"_dp')

-- Better indent
map("v", "<", "<gv")
map("v", ">", ">gv")

-- map("n", "<C-h>", "<C-w>h")
-- map("n", "<C-j>", "<C-\\><C-n><C-w>j")
-- map("n", "<C-k>", "<C-\\><C-n><C-w>k")
-- map("n", "<C-l>", "<C-w>l")

map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-\\><C-n><C-w>j")
map("n", "<C-k>", "<C-\\><C-n><C-w>k")
map("n", "<C-l>", "<C-\\><C-n><C-w>l")

-- Add these debugging keymaps to lua/keymaps.lua
-- ...existing code...

-- DAP (Debug Adapter Protocol) keymaps
-- map("n", "<leader>db", ":DapToggleBreakpoint<CR>")
-- map("n", "<leader>dc", ":DapContinue<CR>")
-- map("n", "<leader>ds", ":DapStepOver<CR>")
-- map("n", "<leader>di", ":DapStepInto<CR>")
-- map("n", "<leader>do", ":DapStepOut<CR>")
-- map("n", "<leader>dr", ":DapRestart<CR>")
-- map("n", "<leader>dt", ":DapTerminate<CR>")

-- -- Neotest keymaps
-- map("n", "<leader>tn", ":lua require('neotest').run.run()<CR>")
-- map("n", "<leader>tf", ":lua require('neotest').run.run(vim.fn.expand('%'))<CR>")
-- map("n", "<leader>ts", ":lua require('neotest').summary.toggle()<CR>")