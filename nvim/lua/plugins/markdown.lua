-- Render Markdown in the buffer: headings, lists, checkboxes, tables, code blocks.
-- The line under the cursor is shown raw, for editing.
local map = vim.keymap.set
local render = require("render-markdown")

render.setup({
  code = { sign = false, width = "block", right_pad = 1 },
  heading = { sign = false },
})

map("n", "<leader>um", render.toggle, { desc = "Toggle Markdown rendering" })

-- Live preview in the browser, with Mermaid diagrams. On WSL, open it in the
-- Windows default browser (xdg-open has no browser to open there).
vim.g.mkdp_echo_preview_url = 1
if vim.fn.has("wsl") == 1 then
  vim.cmd([[
    function! MkdpOpenWindows(url)
      call jobstart(['explorer.exe', a:url])
    endfunction
  ]])
  vim.g.mkdp_browserfunc = "MkdpOpenWindows"
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    map("n", "<leader>cp", "<cmd>MarkdownPreviewToggle<cr>", { buffer = args.buf, desc = "Markdown preview" })
  end,
})
