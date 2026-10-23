# Installed plugins and packages

Everything installed by `flake.nix`. Keep this list in sync when you add or remove
something. See the README for how to add each kind.

## Internal: Neovim plugins (`nvimPlugins`)

Bundled into the `nvim` from this flake and loaded at startup. Configured in `init.lua`.

| Plugin | What it is for | Usage |
|---|---|---|
| `plenary-nvim` | Lua utility library that other plugins depend on (required by telescope) | Nothing to configure |
| `telescope-nvim` | Fuzzy finder: type a few letters, pick from a filtered list of files, text matches, buffers, help pages, git objects, LSP symbols… | `<Space><Space>`/`<Space>ff` find files · `<Space>/`/`<Space>fg` search text in project · `<Space>,`/`<Space>fb` open buffers · `<Space>fr` recent files · `<Space>fh` help pages · `<Space>fk` keymaps · `:Telescope` lists all pickers |
| `nvim-treesitter` (`withAllGrammars`) | Parses code into a syntax tree: accurate highlighting, indentation and folding. Parsers for all languages are installed by Nix | Automatic on every file with a parser · `zc`/`zo` close/open a fold · `:InspectTree` shows the syntax tree · don't use `:TSInstall`; the `:checkhealth` errors about `tree-sitter-cli` and the install directory can be ignored |
| `which-key-nvim` | Popup listing the keys available after a prefix, as in LazyVim. Leader groups: `b` buffer, `c` code, `f` file/find, `g` git, `q` quit, `u` ui, `w` windows | Press `<Space>` (or any prefix) and wait · `<Space>?` keymaps of the current buffer · git: `<Space>gg` lazygit, `<Space>gs` status, `<Space>gc` commits, `<Space>gb` branches · code (needs a language server): `<Space>ca` code action, `<Space>cr` rename, `<Space>cf` format, `<Space>cd` line diagnostics, `<Space>cs` symbols · ui toggles: `<Space>uw` wrap, `<Space>ul` line numbers, `<Space>uL` relative numbers, `<Space>us` spelling, `<Space>ud` diagnostics, `<Space>uh` inlay hints · `<Space>bb` other buffer, `<Space>bd` delete buffer · `<Space>w…` same as `Ctrl-w` · `<Space>qq` quit all |
| `mini-icons` | Icons shown next to which-key groups and file types | Nothing to configure |

## External: packages (`externalPackages`)

Standalone programs installed with the `default` package and available on `PATH`.

| Package | Command | What it is for |
|---|---|---|
| `alacritty` | `alacritty` | GPU-accelerated terminal emulator, configured in `alacritty.toml` (fish if installed, otherwise your login shell; JetBrainsMono 12pt, Tokyo Night colors; `Ctrl+=`/`Ctrl+-`/`Ctrl+0` font size, `Ctrl+Shift+N` new window). Wrapped in `flake.nix` with Nix's Mesa OpenGL drivers, which Nix-built GUI apps need outside NixOS (see README, Platform notes) |
| `nerd-fonts.jetbrains-mono` | (font) | Programming font with icon glyphs, used by the terminal and Neovim plugins |
| `lazygit` | `lazygit` | Terminal UI for git: staging, commits, branches, rebase |
| `mermaid-cli` | `mmdc` | Renders Mermaid diagrams (`.mmd`) to SVG/PNG/PDF |
| `ripgrep` | `rg` | Fast text search across files; required by telescope's `live_grep` |
| `fd` | `fd` | Fast file finder; used by telescope's `find_files` |
