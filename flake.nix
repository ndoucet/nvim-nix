{
  description = "Personal Neovim and Alacritty environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs:
        let
          # Internal: Neovim plugins, loaded automatically at startup.
          # Browse names with: nix search nixpkgs vimPlugins.<name>
          nvimPlugins = with pkgs.vimPlugins; [
            plenary-nvim
            telescope-nvim
            nvim-treesitter.withAllGrammars
            which-key-nvim
            mini-icons
            nvim-lspconfig
            conform-nvim
            nvim-lint
            render-markdown-nvim
            markdown-preview-nvim
          ];

          # Language tools: added to Neovim's PATH only, not to the profile.
          # Language servers come first, so a rustup proxy without the
          # rust-analyzer component cannot shadow the one from Nix.
          languageServers = [
            clangd             # C/C++, runs clang-tidy
            pkgs.pyright       # Python types
            pkgs.rust-analyzer # Rust, runs clippy
          ];
          # Formatters and linters come last, so a version pinned by a
          # project, a virtualenv or rustup takes precedence.
          formatters = [
            pkgs.clang-tools   # clang-format, clang-tidy
            pkgs.ruff          # Python lint and format (also a language server)
            pkgs.rustfmt
            pkgs.prettier          # Markdown format
            pkgs.markdownlint-cli2 # Markdown lint
          ];
          # clangd alone, without clang-format from the same package
          clangd = pkgs.runCommand "clangd" { } ''
            mkdir -p $out/bin
            ln -s ${pkgs.clang-tools}/bin/clangd $out/bin/clangd
          '';

          # Neovim wrapped with the plugins above. wrapRc = false keeps
          # ~/.config/nvim (linked to nvim/) as the user configuration.
          nvim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
            plugins = nvimPlugins;
            wrapRc = false;
            wrapperArgs = [
              "--prefix" "PATH" ":" (pkgs.lib.makeBinPath languageServers)
              "--suffix" "PATH" ":" (pkgs.lib.makeBinPath formatters)
            ];
          };

          font = pkgs.nerd-fonts.jetbrains-mono;

          # Alacritty, made to run on any Linux:
          # - outside NixOS, Nix-built GUI apps cannot load the system's OpenGL
          #   drivers, so use Nix's Mesa (NixOS provides /run/opengl-driver)
          # - on WSL, use the WSLg Wayland socket and the d3d12 (GPU) driver
          # - always find the Nerd Font, even if XDG_DATA_DIRS lacks the profile
          alacritty = pkgs.symlinkJoin {
            name = "alacritty";
            paths = [ pkgs.alacritty ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/alacritty \
                --prefix XDG_DATA_DIRS : ${font}/share \
                --run 'if [ ! -d /run/opengl-driver ]; then
                  export __EGL_VENDOR_LIBRARY_FILENAMES=''${__EGL_VENDOR_LIBRARY_FILENAMES-${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json}
                  export LIBGL_DRIVERS_PATH=''${LIBGL_DRIVERS_PATH-${pkgs.mesa}/lib/dri}
                fi
                if [ -d /usr/lib/wsl/lib ]; then
                  [ -S /mnt/wslg/runtime-dir/wayland-0 ] && export WAYLAND_DISPLAY=/mnt/wslg/runtime-dir/wayland-0
                  export GALLIUM_DRIVER=''${GALLIUM_DRIVER:-d3d12}
                  export LD_LIBRARY_PATH=/usr/lib/wsl/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
                fi'
            '';
          };

          # External: standalone programs added to PATH.
          externalPackages = [
            alacritty
            font
            pkgs.lazygit
            pkgs.mermaid-cli
            pkgs.ripgrep
            pkgs.fd
          ];
        in
        {
          inherit nvim alacritty;
          default = pkgs.buildEnv {
            name = "nvim-desktop";
            paths = [ nvim ] ++ externalPackages;
          };
        });
    };
}
