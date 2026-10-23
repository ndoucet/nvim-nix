local map = vim.keymap.set
local builtin = require("telescope.builtin")

-- Lazygit in a new tab, closed when lazygit exits
map("n", "<leader>gg", function()
  vim.cmd("tabnew | terminal lazygit")
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_create_autocmd("TermClose", {
    buffer = buf,
    callback = function() vim.api.nvim_buf_delete(buf, { force = true }) end,
  })
  vim.cmd("startinsert")
end, { desc = "Lazygit" })

-- Git pickers
map("n", "<leader>gs", builtin.git_status, { desc = "Status" })
map("n", "<leader>gc", builtin.git_commits, { desc = "Commits" })
map("n", "<leader>gb", builtin.git_branches, { desc = "Branches" })
