-- Icons for which-key groups and file types
require("mini.icons").setup({})

-- Which-key: press <Space> (or any prefix) and wait to see the available keys
local wk = require("which-key")
wk.setup({ preset = "helix" })
wk.add({
  { "<leader>b", group = "buffer" },
  { "<leader>c", group = "code" },
  { "<leader>f", group = "file/find" },
  { "<leader>g", group = "git" },
  { "<leader>q", group = "quit" },
  { "<leader>u", group = "ui" },
  { "<leader>w", group = "windows", proxy = "<c-w>" },
  { "<leader>?", function() wk.show({ global = false }) end, desc = "Buffer keymaps" },
})
