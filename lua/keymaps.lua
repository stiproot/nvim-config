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

-- Window navigation (Ctrl + hjkl)
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Move to window below" })
map("n", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Move to window above" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

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
-- map('n', '<leader>rn', vim.lsp.buf.rename, { desc = "Rename symbol" })

map("n", "<leader>p", "<C-r>=expand('%:p')<CR>")

-- LSP Keybindings (only active when LSP is attached)
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local opts = { buffer = bufnr, noremap = true, silent = true }

    -- Navigation
    map("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
    map("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
    map("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Find references" }))
    map("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))

    -- Documentation
    map("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
    map("i", "<C-k>", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature help" }))

    -- Refactoring
    map("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
    map("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code actions" }))
    map("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, vim.tbl_extend("force", opts, { desc = "Format document" }))

    -- Diagnostics
    map("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
    map("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
    map("n", "<leader>e", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Show diagnostic" }))
  end,
})
