{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    filter.url = "github:numtide/nix-filter";
  };
  outputs = {
    nixpkgs,
    self,
    filter,
    ...
  } @ inputs: let
    systems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        default = qs-config;
        qs-config = pkgs.callPackage ./pkg.nix {inherit filter;};
      }
    );
    devShells = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        quickshellPkg = inputs.quickshell.packages.${system}.default;
        qmlPath = pkgs.lib.makeSearchPath "lib/qt-6/qml" [
          pkgs.qt6.qtdeclarative
          pkgs.kdePackages.qtvirtualkeyboard
          quickshellPkg
        ];
        pluginPath = pkgs.lib.makeSearchPath "lib/qt-6/plugins" [
          pkgs.qt6.qtdeclarative
          pkgs.kdePackages.qtvirtualkeyboard
          quickshellPkg
        ];
      in {
        default = pkgs.mkShell {
          packages = [
            quickshellPkg
            pkgs.qt6.qtdeclarative
            pkgs.kdePackages.qtvirtualkeyboard
          ];

          shellHook = ''
            export QS_CONFIG_PATH="$PWD"
            export QML2_IMPORT_PATH="${qmlPath}''${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}"
            export QT_PLUGIN_PATH="${pluginPath}''${QT_PLUGIN_PATH:+:$QT_PLUGIN_PATH}"
          '';
        };
      }
    );
    homeManagerModules = {
      qs-config = import ./module.nix {
        inherit self inputs;
      };
    };
  };
}
