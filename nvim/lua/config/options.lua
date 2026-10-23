vim.diagnostic.config({ virtual_text = true, severity_sort = true })

-- Completion menu (filled by language servers, see plugins/lsp.lua)
vim.o.completeopt = "menuone,noselect,popup,fuzzy"
