# Neovim + Alacritty + JetBrainsMono Nerd Font

A lightweight, reproducible development environment managed with Nix on Linux,
without NixOS or Home Manager.

**What's included:** see [PACKAGES.md](PACKAGES.md) for the list of Neovim plugins and
external packages, what each is for, and how to use it.

## Installation

### Requirements

- Linux on `x86_64` or `aarch64` (any distribution, NixOS, or WSL2) with the Nix package manager installed (see [Installing Nix](#installing-nix))
- Flakes enabled (`nix-command` and `flakes`)

If flakes are not enabled globally, either add this line to `~/.config/nix/nix.conf`:

```
experimental-features = nix-command flakes
```

or prefix every command below with `nix --extra-experimental-features "nix-command flakes"`.

### Installing Nix

Check first whether Nix is already there: `nix --version`. If it prints a version, skip
to [Install](#install); on a shared machine with a multi-user install, any user can use it
without `sudo`. Otherwise:

| Situation | Method |
|---|---|
| You have `sudo` | [Official installer](#with-sudo-official-installer), Nix in `/nix` |
| No `sudo`, but an administrator can create `/nix` once | [Single-user install](#no-sudo-an-administrator-creates-nix) |
| No `sudo` at all | [nix-portable](#no-sudo-at-all-nix-portable), Nix in a folder you choose |

#### With sudo: official installer

```sh
curl --proto '=https' --tlsv1.2 -sSfL https://nixos.org/nix/install | sh -s -- --daemon
```

This installs Nix in `/nix`, with a daemon that builds for every user. Open a new
terminal afterwards. The daemon needs systemd: on WSL2, enable it first (add
`[boot]` and `systemd=true` to `/etc/wsl.conf`, then `wsl --shutdown` from Windows),
or use `--no-daemon` instead of `--daemon` for a single-user install.

#### No sudo, an administrator creates /nix

Ask an administrator to run, once:

```sh
sudo mkdir /nix && sudo chown <your-user> /nix
```

then install as yourself, without `sudo`:

```sh
curl --proto '=https' --tlsv1.2 -sSfL https://nixos.org/nix/install | sh -s -- --no-daemon
```

Open a new terminal afterwards. Everything else works as described in this README.

#### No sudo at all: nix-portable

[nix-portable](https://github.com/DavHau/nix-portable) is a single executable that runs Nix
without root: it keeps the Nix store in a folder you choose and makes it appear as
`/nix/store` to the programs it starts. Flakes are enabled by default.

**1. Choose the folder.** Neovim with its tools takes about 8 GB, so pick a disk with room,
not a small home quota. Below, `/data/me/nix` stands for that folder: replace it
everywhere. The folder holds two things:

- `/data/me/nix/bin/nix-portable`: the executable
- `/data/me/nix/.nix-portable/`: the Nix store, created on first run

Create the `bin` folder now:

```sh
mkdir -p /data/me/nix/bin
```

**2. Set `NP_LOCATION` and `PATH` in your shell's startup file**, before the first run.
`NP_LOCATION` tells nix-portable where to create `.nix-portable`; without it, it uses your
home folder.

```sh
# bash/zsh: add to ~/.bashrc or ~/.zshrc
export NP_LOCATION=/data/me/nix
export PATH="$NP_LOCATION/bin:$PATH"
```

```fish
# fish: add to ~/.config/fish/config.fish
set -gx NP_LOCATION /data/me/nix
set -gx PATH $NP_LOCATION/bin $PATH
```

Then open a new terminal, so both are set, and check:

```sh
echo $NP_LOCATION     # prints /data/me/nix
echo $PATH            # starts with /data/me/nix/bin
```

**3. Download nix-portable** into `$NP_LOCATION/bin` (these commands work in bash, zsh and
fish):

```sh
curl -L -o $NP_LOCATION/bin/nix-portable https://github.com/DavHau/nix-portable/releases/latest/download/nix-portable-$(uname -m)
chmod +x $NP_LOCATION/bin/nix-portable
```

**4. Check it:**

```sh
command -v nix-portable    # prints /data/me/nix/bin/nix-portable
nix-portable nix --version
```

The first run creates `$NP_LOCATION/.nix-portable`. If it was created in your home folder
instead, `NP_LOCATION` was not set: delete `~/.nix-portable` and go back to step 2.

**5. Run Neovim.** Programs from nix-portable only run through it, since `/nix/store` exists
only inside it, and `nix profile` is not supported. So instead of [Install](#install),
clone the repository and run it from the clone:

```sh
git clone git@github.com:ndoucet/nvim-nix.git ~/perso/nvim-nix
nix-portable nix shell ~/perso/nvim-nix -c nvim    # Neovim with all external tools
nix-portable nix shell ~/perso/nvim-nix            # a shell with Neovim and all tools
```

Use `nix shell`, not `nix run ~/perso/nvim-nix#nvim`: `#nvim` leaves out the external
tools (`rg`, `fd`, `lazygit`…), which telescope and `<Space>gg` need.

To type `nvim` as usual, add a launcher next to `nix-portable` (it is on the `PATH` since
step 2):

```sh
printf '#!/bin/sh\nexec nix-portable nix shell "$HOME/perso/nvim-nix" -c nvim "$@"\n' > $NP_LOCATION/bin/nvim
chmod +x $NP_LOCATION/bin/nvim
```

It always runs the clone as it is now, so there is no upgrade step: `git pull` is enough.
The price is a few seconds at each start, while Nix checks the flake.
If the system does not allow unprivileged user namespaces, nix-portable falls back to
`proot`, which works but is noticeably slower.

### Install

The repository is private, so it is fetched over SSH: the machine needs an SSH key added
to the GitHub account (check with `ssh -T git@github.com`).

Clone it, then install from the clone. A clone is needed to link the configuration files
(see [Configuration](#configuration)) and to add plugins or packages:

```sh
git clone git@github.com:ndoucet/nvim-nix.git ~/perso/nvim-nix
cd ~/perso/nvim-nix
nix profile install .
```

This installs the `default` package (`nvim-desktop`): Neovim with its plugins, plus all
external tools. To install only Neovim with its plugins:

```sh
nix profile install .#nvim
```

To install or try it without cloning:

```sh
nix profile install git+ssh://git@github.com/ndoucet/nvim-nix
nix run git+ssh://git@github.com/ndoucet/nvim-nix#nvim
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

Neovim, its language tools and the external command-line tools need no special handling.

## Configuration

Both applications work with their built-in defaults. Optional configuration:

- `~/.config/alacritty/alacritty.toml`: terminal settings and JetBrainsMono Nerd Font
- `~/.config/nvim/`: Neovim options, keybindings and plugin setup

This repository ships both (`alacritty.toml` and the `nvim/` folder). To use them, link
them into place from the clone, so edits in the repository apply immediately.

If `~/.config/nvim` already holds another configuration (LazyVim, …), move it away first,
together with its data, or its plugins will conflict (bash/zsh syntax):

```sh
for d in ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim; do
  [ -e "$d" ] && mv "$d" "$d.bak"
done
```

Then link:

```sh
mkdir -p ~/.config/alacritty
ln -s "$PWD/alacritty.toml" ~/.config/alacritty/alacritty.toml
ln -s "$PWD/nvim"           ~/.config/nvim
```

On a machine set up before the configuration was split into the `nvim/` folder,
`~/.config/nvim` is a folder holding only a link to `init.lua`; replace it:

```sh
rm ~/.config/nvim/init.lua && rmdir ~/.config/nvim
ln -s "$PWD/nvim" ~/.config/nvim
```

### Layout of the Neovim configuration

`nvim/init.lua` only sets the leader key and loads one file per topic, in this order:

| File | Contents |
|---|---|
| `lua/config/options.lua` | General options: diagnostics display, completion menu |
| `lua/config/keymaps.lua` | Keymaps not tied to a plugin: UI toggles, buffers, line diagnostics, quit |
| `lua/plugins/ui.lua` | which-key and its leader groups, mini.icons |
| `lua/plugins/neo-tree.lua` | File explorer sidebar and its `<Space>e` keys |
| `lua/plugins/telescope.lua` | Fuzzy finder and its `<Space>f…` keys |
| `lua/plugins/treesitter.lua` | Highlighting, folding, indentation |
| `lua/plugins/git.lua` | Lazygit and the git pickers (`<Space>g…`) |
| `lua/plugins/lsp.lua` | Language servers, completion, `gd`/`gr`/… and `<Space>c…` LSP keys |
| `lua/plugins/format.lua` | conform: formatter per file type, format on save |
| `lua/plugins/lint.lua` | nvim-lint: linter per file type |
| `lua/plugins/markdown.lua` | render-markdown (Markdown rendered in the buffer), markdown-preview (browser preview with Mermaid, also of `.mmd` files) |

Each plugin's keymaps live in its file. A new plugin gets a new file in `lua/plugins/`
and a `require("plugins.<name>")` line in `init.lua`. A new leader group also needs an
entry in `ui.lua`.

## Adding software: internal plugins vs external packages

All software is declared in `flake.nix`, in one of two lists. Language servers and
formatters have their own lists, `languageServers` and `formatters`, added to Neovim's
`PATH` only (see [PACKAGES.md](PACKAGES.md#language-tools-languageservers-formatters));
a new one also needs a line in `nvim/lua/plugins/lsp.lua` (`vim.lsp.enable`),
`format.lua` (`formatters_by_ft`) or `lint.lua` (`linters_by_ft`).

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
in a new file, for example `nvim/lua/plugins/lualine.lua`:

```lua
require("lualine").setup({})
```

and load it from `nvim/init.lua` with `require("plugins.lualine")` (see
[Layout of the Neovim configuration](#layout-of-the-neovim-configuration)).

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

Nix only sees files tracked by git: `git add` any new file before building. To share a
change with other machines, commit and push it, then on each machine:

```sh
git pull
nix profile upgrade --all
```

`nix build` builds the package into `./result` without installing it. Use it to check
that the flake still builds.

## Uninstall

Each step is independent: do only those you need, in this order.

### 1. Remove the package

Find the entry name, then remove it: `nvim-nix` for the `default` package, `nvim` if you
installed `.#nvim`.

```sh
nix profile list
nix profile remove nvim-nix
```

The programs (`nvim`, `alacritty`, `lazygit`, …) are no longer on the `PATH` in new
terminals.

### 2. Free the disk space

Removing the package does not delete it from `/nix/store`: older profile versions still
point to it, so you can roll back. To delete it for good:

```sh
nix profile wipe-history    # forget older profile versions: no rollback after this
nix store gc                # delete everything nothing points to any more
```

`nix store gc --dry-run` lists what would be deleted first.

### 3. Remove the configuration links

[Configuration](#configuration) linked the configuration into `~/.config`. Remove the links
(this leaves the files in the clone untouched; no trailing `/` on `~/.config/nvim`, or `rm`
looks inside the link instead of removing it):

```sh
rm ~/.config/nvim ~/.config/alacritty/alacritty.toml
```

Neovim also keeps history, undo and swap files in `~/.local/share/nvim`,
`~/.local/state/nvim` and `~/.cache/nvim`. Delete them too for a clean slate:

```sh
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
```

### 4. Restore a previous Neovim configuration

If you moved another configuration away during [Configuration](#configuration) (to
`*.bak`), first do step 3, then move it back:

```sh
# bash/zsh
for d in ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim; do
  [ -e "$d.bak" ] && mv "$d.bak" "$d"
done
```

```fish
# fish
for d in ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
  test -e $d.bak; and mv $d.bak $d
end
```

### 5. Remove nix-portable

If you used [nix-portable](#no-sudo-at-all-nix-portable) instead of steps 1 and 2:

1. Delete the folder, with the store and the `nvim` launcher. The store is read-only, so
   make it writable first:

   ```sh
   chmod -R u+w $NP_LOCATION
   rm -rf $NP_LOCATION
   ```

2. Delete the lines setting `NP_LOCATION` and `PATH` from `~/.bashrc`, `~/.zshrc` or
   `~/.config/fish/config.fish`, and open a new terminal.
3. Delete Nix's cache: `rm -rf ~/.cache/nix`.

### 6. Remove the clone

```sh
rm -rf ~/perso/nvim-nix
```

Do this last: the links of step 3 point into it, and with nix-portable, Neovim runs from it.
Push any change you want to keep first.

### 7. Uninstall Nix itself

Only if nothing else on the machine uses Nix. Removing Nix depends on how it was installed
(multi-user with a daemon, or single-user): follow the
[official uninstall instructions](https://nix.dev/manual/nix/latest/installation/uninstall.html).
