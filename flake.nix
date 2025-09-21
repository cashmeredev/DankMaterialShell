{
  description = "Dank material shell.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    quickshell.url = "git+https://git.outfoxxed.me/quickshell/quickshell";
    quickshell.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      quickshell,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system} = {
        dankMaterialShell = pkgs.stdenvNoCC.mkDerivation {
          name = "dankMaterialShell";
          src = ./.;
          installPhase = ''
            mkdir -p $out/etc/xdg/quickshell/DankMaterialShell
            cp -r . $out/etc/xdg/quickshell/DankMaterialShell
          '';
        };

        default = self.packages.${system}.dankMaterialShell;
      };

      homeModules.dankMaterialShell =
        {
          config,
          pkgs,
          lib,
          ...
        }:
        let
          cfg = config.programs.dankMaterialShell;
        in
        {

          options.programs.dankMaterialShell = {
            enable = lib.mkEnableOption "DankMaterialShell";
          };

          config = lib.mkIf cfg.enable {
            programs.quickshell = {
              enable = true;
              package = quickshell.packages.${system}.quickshell;
              configs.DankMaterialShell = "${
                self.packages.${system}.dankMaterialShell
              }/etc/xdg/quickshell/DankMaterialShell/";
              activeConfig = lib.mkIf cfg.enableSystemd "DankMaterialShell";
              systemd = lib.mkIf cfg.enableSystemd {
                enable = true;
                target = "graphical-session.target";
              };
            };

            home.packages = with pkgs; [
              material-symbols
              inter
              fira-code
              cava
              wl-clipboard
              cliphist
              ddcutil
              libsForQt5.qt5ct
              kdePackages.qt6ct
              matugen
            ];
          };
        };
    };
}
