local lspconfig = require "lspconfig"

-- configuring single server, example: typescript
-- lspconfig.tsserver.setup {
--   on_attach = nvlsp.on_attach,
--   on_init = nvlsp.on_init,
--   capabilities = nvlsp.capabilities,
-- }
--
local pid = vim.fn.getpid()
local omnisharp_bin = "/Users/simon.stipcich/code/omnisharp-osx-arm64-net6.0/OmniSharp"
lspconfig.omnisharp.setup{
    cmd = { omnisharp_bin, "--languageserver" , "--hostPID", tostring(pid) }
    -- Additional configuration can be added here
}
