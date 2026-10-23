-- LSP: language servers are installed by Nix, their defaults come from nvim-lspconfig
local map = vim.keymap.set
local builtin = require("telescope.builtin")

vim.lsp.config("clangd", {
  cmd = { "clangd", "--clang-tidy", "--background-index", "--header-insertion=never" },
})

-- Prefer rust-analyzer from the project's rustup toolchain, it matches its
-- Rust version; otherwise use the one from Nix
local function rust_analyzer_cmd()
  if vim.fn.executable("rustup") == 1 then
    local path = vim.trim(vim.fn.system({ "rustup", "which", "rust-analyzer" }))
    if vim.v.shell_error == 0 then return { path } end
  end
  return { "rust-analyzer" }
end
vim.lsp.config("rust_analyzer", {
  cmd = function(dispatchers, config)
    return vim.lsp.rpc.start(rust_analyzer_cmd(), dispatchers, { cwd = config.root_dir })
  end,
  settings = { ["rust-analyzer"] = { check = { command = "clippy" } } },
})

vim.lsp.enable({ "clangd", "pyright", "ruff", "rust_analyzer" })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    -- Hover comes from pyright, ruff only lints and formats
    if client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    end
    -- Completion menu while typing, <C-y> accepts, <C-n>/<C-p> move
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end
    local opts = function(desc) return { buffer = args.buf, desc = desc } end
    map("n", "gd", builtin.lsp_definitions, opts("Go to definition"))
    map("n", "gr", builtin.lsp_references, opts("References"))
    map("n", "gI", builtin.lsp_implementations, opts("Go to implementation"))
    map("n", "gy", builtin.lsp_type_definitions, opts("Go to type definition"))
  end,
})

-- Code: LSP actions work once a language server is attached to the buffer
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>cD", builtin.diagnostics, { desc = "Project diagnostics" })
map("n", "<leader>cs", builtin.lsp_document_symbols, { desc = "Symbols" })
map("n", "<leader>cl", "<cmd>checkhealth vim.lsp<cr>", { desc = "LSP info" })
