local pid = vim.fn.getpid()
local omnisharp_bin = "/Users/simon.stipcich/code/omnisharp-osx-arm64-net6.0/OmniSharp"

vim.lsp.config.omnisharp = {
    cmd = { omnisharp_bin, "--languageserver" , "--hostPID", tostring(pid) },
    filetypes = { 'cs', 'vb' },
    root_dir = vim.fs.dirname(vim.fs.find({ '*.sln', '*.csproj', 'omnisharp.json', 'function.json' }, { upward = true })[1]),
}

vim.lsp.enable('omnisharp')
