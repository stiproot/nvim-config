-- Enhance LSP capabilities with nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      client.server_capabilities = vim.tbl_deep_extend(
        'force',
        client.server_capabilities,
        capabilities
      )
    end
  end,
})

local pid = vim.fn.getpid()
local omnisharp_bin = "/Users/simon.stipcich/code/omnisharp-osx-arm64-net6.0/OmniSharp"

vim.lsp.config.omnisharp = {
    cmd = { omnisharp_bin, "--languageserver" , "--hostPID", tostring(pid) },
    filetypes = { 'cs', 'vb' },
    root_dir = vim.fs.dirname(vim.fs.find({ '*.sln', '*.csproj', 'omnisharp.json', 'function.json' }, { upward = true })[1]),
}

vim.lsp.enable('omnisharp')

-- TypeScript/JavaScript Language Server
vim.lsp.config.ts_ls = {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact"
  },
  root_dir = vim.fs.dirname(
    vim.fs.find({
      "package.json",
      "tsconfig.json",
      "jsconfig.json"
    }, { upward = true })[1]
  ),
}

vim.lsp.enable('ts_ls')
