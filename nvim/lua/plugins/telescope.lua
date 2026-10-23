-- Telescope: fuzzy finder
local map = vim.keymap.set
local builtin = require("telescope.builtin")
require("telescope").setup({})

map("n", "<leader><space>", builtin.find_files, { desc = "Find files" })
map("n", "<leader>/", builtin.live_grep, { desc = "Search text in project" })
map("n", "<leader>,", builtin.buffers, { desc = "Open buffers" })
map("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
map("n", "<leader>fg", builtin.live_grep, { desc = "Search text in project" })
map("n", "<leader>fb", builtin.buffers, { desc = "Open buffers" })
map("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
map("n", "<leader>fh", builtin.help_tags, { desc = "Help pages" })
map("n", "<leader>fk", builtin.keymaps, { desc = "Keymaps" })
