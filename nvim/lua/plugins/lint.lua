-- Linting for file types without a language server
local lint = require("lint")
lint.linters_by_ft = { markdown = { "markdownlint-cli2" } }

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
  -- Scheduled: on BufReadPost the filetype is not set yet
  callback = function() vim.schedule(function() lint.try_lint() end) end,
})
