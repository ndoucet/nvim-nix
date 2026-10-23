# Neovim + Alacritty + JetBrainsMono Nerd Font

A lightweight, reproducible development environment managed with Nix on Linux,
without NixOS or Home Manager.

**What's included:** see [PACKAGES.md](PACKAGES.md) for the list of Neovim plugins and
external packages, what each is for, and how to use it.

## Installation

### Requirements

- Linux on `x86_64` or `aarch64` (any distribution, NixOS, or WSL2) with the Nix package manager installed
- Flakes enabled (`nix-command` and `flakes`)

If flakes are not enabled globally, either add this line to `~/.config/nix/nix.conf`:

```
experimental-features = nix-command flakes
```

or prefix every command below with `nix --extra-experimental-features "nix-command flakes"`.

### Install

From the project directory:

```sh
nix profile install .
```

This installs the `default` package (`nvim-desktop`): Neovim with its plugins, plus all
external tools. To install only Neovim with its plugins:

```sh
nix profile install .#nvim
```

To try it without installing:

```sh
nix run .#nvim
```

### Verify

```sh
nvim --version
alacritty --version
fc-match "JetBrainsMono Nerd Font"
```

### Platform notes

The flake is not tied to one machine. The `alacritty` wrapper in `flake.nix` adapts at
launch:

- **Other Linux distributions:** Nix-built graphical apps cannot load the system's
  OpenGL drivers, so Alacritty uses Nix's Mesa drivers. These cover Intel, AMD and
  open-source NVIDIA (nouveau) GPUs. With the proprietary NVIDIA driver, Alacritty
  falls back to software rendering, which works but is slower. For GPU rendering
  there, run it through [nixGL](https://github.com/nix-community/nixGL).
- **NixOS:** the system drivers (`/run/opengl-driver`) are used unchanged.
- **WSL2:** Alacritty connects to the WSLg display and renders on the GPU through
  the `d3d12` driver.

Neovim and the external command-line tools need no special handling.

## Configuration

Both applications work with their built-in defaults. Optional configuration files:

- `~/.config/alacritty/alacritty.toml`: terminal settings and JetBrainsMono Nerd Font
- `~/.config/nvim/init.lua`: Neovim options, keybindings and plugin setup

This repository ships templates for both. To use them, link them into place:

```sh
mkdir -p ~/.config/alacritty ~/.config/nvim
ln -s "$PWD/alacritty.toml" ~/.config/alacritty/alacritty.toml
ln -s "$PWD/init.lua"       ~/.config/nvim/init.lua
```

## Adding software: internal plugins vs external packages

All software is declared in `flake.nix`, in one of two lists.

| | Internal (Neovim plugins) | External (packages) |
|---|---|---|
| What | Lua or Vimscript code that runs inside Neovim | Standalone programs |
| Examples | telescope, treesitter | lazygit, mermaid-cli, ripgrep |
| List in `flake.nix` | `nvimPlugins` | `externalPackages` |
| Nix attribute | `pkgs.vimPlugins.<name>` | `pkgs.<name>` |
| Available as | a Lua module (`require(...)`) | a command on `PATH` |

### Internal: Neovim plugins

**Install.** Find the plugin name:

```sh
nix search nixpkgs vimPlugins.lualine
```

Add it to `nvimPlugins` in `flake.nix` without the `vimPlugins.` prefix
(the list is already inside `with pkgs.vimPlugins;`):

```nix
nvimPlugins = with pkgs.vimPlugins; [
  plenary-nvim
  telescope-nvim
  nvim-treesitter.withAllGrammars
  lualine-nvim
];
```

Then rebuild and upgrade (see [Update](#update)), and add it to [PACKAGES.md](PACKAGES.md).

**Use.** Plugins are on Neovim's `packpath` and load automatically at startup.
Do not install them again with a plugin manager (lazy.nvim, packer, …). Configure them
in `~/.config/nvim/init.lua`:

```lua
require("lualine").setup({})
```

The repository's `init.lua` already sets up telescope and treesitter.

Plugins installed this way exist only inside the `nvim` from this flake. They are
not available to another Neovim installed elsewhere on the system.

### External: packages

**Install.** Find the package name:

```sh
nix search nixpkgs htop
```

Add it to `externalPackages` in `flake.nix` with the `pkgs.` prefix:

```nix
externalPackages = [
  pkgs.alacritty
  pkgs.nerd-fonts.jetbrains-mono
  pkgs.lazygit
  pkgs.mermaid-cli
  pkgs.ripgrep
  pkgs.fd
  pkgs.htop
];
```

Then rebuild and upgrade (see [Update](#update)), and add it to [PACKAGES.md](PACKAGES.md).

**Use.** External packages are installed into your Nix profile and are on `PATH`,
so you can use them from any shell:

```sh
lazygit
mmdc -i diagram.mmd -o diagram.svg
```

From inside Neovim, run them with `:!`, from a terminal buffer, or from a keymap:

```lua
vim.keymap.set("n", "<leader>gg", "<cmd>terminal lazygit<cr>")
```

Plugins that call external tools (for example telescope's `live_grep`, which needs
`ripgrep`) find them through `PATH`. External packages come only with the `default`
package, not with `.#nvim`.

## Update

After editing `flake.nix`, or to update nixpkgs:

```sh
nix flake update          # optional: update nixpkgs to the latest revision
nix profile upgrade --all
```

`nix build` builds the package into `./result` without installing it. Use it to check
that the flake still builds.

## Uninstall

```sh
nix profile list
nix profile remove <name-or-index>
```

Uninstalling does not delete personal configuration files under `~/.config`.
