local map = vim.keymap.set

-- UI toggles
local function toggle(option)
  return function() vim.wo[option] = not vim.wo[option] end
end
map("n", "<leader>uw", toggle("wrap"), { desc = "Toggle wrap" })
map("n", "<leader>ul", toggle("number"), { desc = "Toggle line numbers" })
map("n", "<leader>uL", toggle("relativenumber"), { desc = "Toggle relative numbers" })
map("n", "<leader>us", toggle("spell"), { desc = "Toggle spelling" })
map("n", "<leader>ud", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })
map("n", "<leader>uh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

-- Buffers
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to other buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- Diagnostics
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- Quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
