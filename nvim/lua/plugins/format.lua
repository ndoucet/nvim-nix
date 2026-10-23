-- Formatting: on save, with the language server as fallback
local map = vim.keymap.set

require("conform").setup({
  formatters_by_ft = {
    c = { "clang-format" },
    cpp = { "clang-format" },
    python = { "ruff_organize_imports", "ruff_format" },
    rust = { "rustfmt" },
    markdown = { "prettier", "markdownlint-cli2" },
  },
  formatters = {
    -- Only run the markdownlint fixer when it has reported something
    ["markdownlint-cli2"] = {
      condition = function(_, ctx)
        return #vim.diagnostic.get(ctx.buf, { namespace = require("lint").get_namespace("markdownlint-cli2") }) > 0
      end,
    },
  },
  default_format_opts = { lsp_format = "fallback" },
  format_on_save = function()
    if vim.g.autoformat ~= false then return { timeout_ms = 3000 } end
  end,
})

map({ "n", "v" }, "<leader>cf", function() require("conform").format() end, { desc = "Format" })
map("n", "<leader>cF", "<cmd>ConformInfo<cr>", { desc = "Formatter info" })
map("n", "<leader>uf", function()
  vim.g.autoformat = vim.g.autoformat == false
  vim.notify("Format on save " .. (vim.g.autoformat and "on" or "off"))
end, { desc = "Toggle format on save" })
