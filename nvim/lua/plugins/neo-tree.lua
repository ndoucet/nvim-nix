-- File explorer in a sidebar. Also opens instead of netrw on `nvim <directory>`.
local map = vim.keymap.set

-- Neo-tree takes its file icons from nvim-web-devicons; let mini.icons stand in.
require("mini.icons").mock_nvim_web_devicons()

require("neo-tree").setup({
  filesystem = {
    follow_current_file = { enabled = true },
    use_libuv_file_watcher = true,
  },
})

map("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Explorer" })
map("n", "<leader>fe", "<cmd>Neotree reveal<cr>", { desc = "Reveal file in explorer" })
map("n", "<leader>ge", "<cmd>Neotree git_status toggle<cr>", { desc = "Git explorer" })
map("n", "<leader>be", "<cmd>Neotree buffers toggle<cr>", { desc = "Buffer explorer" })
