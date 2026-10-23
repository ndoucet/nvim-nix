# Installed plugins and packages

Everything installed by `flake.nix`. Keep this list in sync when you add or remove
something. See the README for how to add each kind.

## Internal: Neovim plugins (`nvimPlugins`)

Bundled into the `nvim` from this flake and loaded at startup. Configured in `nvim/lua/plugins/` (see the README, Layout of the Neovim configuration).

| Plugin | What it is for | Usage |
|---|---|---|
| `plenary-nvim` | Lua utility library that other plugins depend on (required by telescope) | Nothing to configure |
| `telescope-nvim` | Fuzzy finder: type a few letters, pick from a filtered list of files, text matches, buffers, help pages, git objects, LSP symbols… | `<Space><Space>`/`<Space>ff` find files · `<Space>/`/`<Space>fg` search text in project · `<Space>,`/`<Space>fb` open buffers · `<Space>fr` recent files · `<Space>fh` help pages · `<Space>fk` keymaps · `:Telescope` lists all pickers |
| `nvim-treesitter` (`withAllGrammars`) | Parses code into a syntax tree: accurate highlighting, indentation and folding. Parsers for all languages are installed by Nix | Automatic on every file with a parser · `zc`/`zo` close/open a fold · `:InspectTree` shows the syntax tree · don't use `:TSInstall`; the `:checkhealth` errors about `tree-sitter-cli` and the install directory can be ignored |
| `which-key-nvim` | Popup listing the keys available after a prefix, as in LazyVim. Leader groups: `b` buffer, `c` code, `f` file/find, `g` git, `q` quit, `u` ui, `w` windows | Press `<Space>` (or any prefix) and wait · `<Space>?` keymaps of the current buffer · git: `<Space>gg` lazygit, `<Space>gs` status, `<Space>gc` commits, `<Space>gb` branches · code (needs a language server): `<Space>ca` code action, `<Space>cr` rename, `<Space>cf` format, `<Space>cd` line diagnostics, `<Space>cD` project diagnostics, `<Space>cs` symbols, `<Space>cl` LSP info, `<Space>cF` formatter info, `<Space>cp` Markdown preview · ui toggles: `<Space>uw` wrap, `<Space>ul` line numbers, `<Space>uL` relative numbers, `<Space>us` spelling, `<Space>uf` format on save, `<Space>um` Markdown rendering, `<Space>ud` diagnostics, `<Space>uh` inlay hints · `<Space>bb` other buffer, `<Space>bd` delete buffer · `<Space>w…` same as `Ctrl-w` · `<Space>qq` quit all |
| `mini-icons` | Icons shown next to which-key groups and file types | Nothing to configure |
| `nvim-lspconfig` | Default settings for each language server (command, root markers). Servers are enabled in `lsp.lua` with `vim.lsp.enable` | `gd` definition · `gr` references · `gI` implementation · `gy` type definition · `K` hover · `]d`/`[d` next/previous diagnostic · completion menu while typing: `Ctrl+n`/`Ctrl+p` move, `Ctrl+y` accept |
| `conform-nvim` | Runs the formatter for each file type, on save and with `<Space>cf`; uses the language server when there is no formatter | `<Space>uf` toggles format on save · `:ConformInfo` shows which formatter applies |
| `nvim-lint` | Runs linters for file types without a language server (Markdown), when a file is opened, saved, or when leaving insert mode | Warnings appear like language server diagnostics: `<Space>cd`, `]d`/`[d` |
| `neo-tree-nvim` | File explorer in a sidebar: tree of the current directory, following the open file; also git changes and open buffers. Opens instead of netrw on `nvim <directory>` | `<Space>e` toggle explorer · `<Space>fe` reveal current file · `<Space>ge` git changes · `<Space>be` open buffers · in the tree: `<Enter>` open, `a` add (end with `/` for a directory), `d` delete, `r` rename, `m` move, `c` copy, `H` hidden files, `?` all keys |
| `render-markdown-nvim` | Renders Markdown inside the buffer: headings, bullets, checkboxes, tables, code blocks, quotes. The line under the cursor stays raw for editing | Automatic in Markdown files · `<Space>um` toggles rendering |
| `markdown-preview-nvim` | Live preview of the current Markdown file in the browser, scrolling with the cursor; renders Mermaid diagrams (` ```mermaid ` blocks, with the Mermaid of `mermaid-cli`: the bundled one is too old), math and tables. On WSL it opens in the Windows default browser | `<Space>cp` in a Markdown file toggles the preview · `:MarkdownPreview` / `:MarkdownPreviewStop` · the URL is also printed, to open it by hand |

## Language tools (`languageServers`, `formatters`)

Added to the `PATH` of the `nvim` from this flake only, not to the profile, so they come
with `.#nvim` too. Language servers come before your `PATH` and formatters after it: a
formatter pinned by a project, a virtualenv (`ruff`), uv (`clang-format`), rustup
(`rustfmt`, `cargo clippy`) or npm (`prettier`) takes precedence over the one from Nix.

| Language | Language server (completion, navigation, errors) | Linter | Formatter |
|---|---|---|---|
| C/C++ | `clangd` (from `clang-tools`) | `clang-tidy`, run by clangd; configured by the project's `.clang-tidy` | `clang-format`; configured by `.clang-format` |
| Python | `pyright` (types), `ruff` | `ruff`; configured in `pyproject.toml` or `ruff.toml` | `ruff format` and import sorting |
| Rust | `rust-analyzer` | `cargo clippy`, run by rust-analyzer on save; needs the Rust toolchain | `rustfmt` |
| Markdown | none | `markdownlint-cli2` (run by nvim-lint); configured by `.markdownlint-cli2.yaml` or `.markdownlint.json` | `prettier` (configured by `.prettierrc`; keeps line breaks), then `markdownlint-cli2 --fix` when it reported something |

clangd needs a `compile_commands.json` at the project root to know include paths and flags
(CMake: `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON`; Make: `bear -- make`).

rust-analyzer only supports recent Rust versions. If rustup has the `rust-analyzer`
component for the project's toolchain (`rustup component add rust-analyzer`), that one is
used; otherwise the one from Nix, which warns when the toolchain is too old (fix with
`rustup update`).

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
