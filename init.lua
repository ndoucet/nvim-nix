vim.g.mapleader = " "

local map = vim.keymap.set

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

-- Telescope: fuzzy finder
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

-- Git: lazygit in a new tab, closed when lazygit exits
map("n", "<leader>gg", function()
  vim.cmd("tabnew | terminal lazygit")
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_create_autocmd("TermClose", {
    buffer = buf,
    callback = function() vim.api.nvim_buf_delete(buf, { force = true }) end,
  })
  vim.cmd("startinsert")
end, { desc = "Lazygit" })
map("n", "<leader>gs", builtin.git_status, { desc = "Status" })
map("n", "<leader>gc", builtin.git_commits, { desc = "Commits" })
map("n", "<leader>gb", builtin.git_branches, { desc = "Branches" })

-- Code: work once a language server is attached to the buffer
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>cf", vim.lsp.buf.format, { desc = "Format buffer" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>cs", builtin.lsp_document_symbols, { desc = "Symbols" })

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

-- Quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- Treesitter: highlighting, folding and indentation (parsers are installed by Nix)
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    if pcall(vim.treesitter.start, args.buf) then
      vim.wo.foldmethod = "expr"
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      vim.wo.foldlevel = 99
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})
