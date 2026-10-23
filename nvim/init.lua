vim.g.mapleader = " "

-- General settings and keymaps (lua/config)
require("config.options")
require("config.keymaps")

-- Plugins, installed by Nix (lua/plugins), each with its own keymaps
require("plugins.ui")
require("plugins.telescope")
require("plugins.treesitter")
require("plugins.git")
require("plugins.lsp")
require("plugins.format")
require("plugins.lint")
require("plugins.markdown")
