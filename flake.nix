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
          ];

          # Neovim wrapped with the plugins above. wrapRc = false keeps
          # ~/.config/nvim/init.lua as the user configuration.
          nvim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
            plugins = nvimPlugins;
            wrapRc = false;
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
