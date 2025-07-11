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
