{
  inputs,
  self,
  ...
}: {
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib) types;
  cfg = config.programs.qs-config;
  inherit (pkgs.stdenv.hostPlatform) system;
  packages = self.packages.${system};
  quickshell = inputs.quickshell.packages.${system}.default;
  qmlPath = pkgs.lib.makeSearchPath "lib/qt-6/qml" [
    pkgs.qt6.qtdeclarative
    pkgs.kdePackages.qtvirtualkeyboard
    quickshell
  ];
  pluginPath = pkgs.lib.makeSearchPath "lib/qt-6/plugins" [
    pkgs.qt6.qtdeclarative
    pkgs.kdePackages.qtvirtualkeyboard
    quickshell
  ];
in {
  options.programs.qs-config = {
    enable = mkEnableOption "qs-config";
    colors = mkOption {
      description = "Visual and motion settings for qs-shell.";
      default = {};
      type = types.submodule {
        options = {
          background = mkOption {
            type = types.str;
            default = "#1E1E2E";
          };
          foreground = mkOption {
            type = types.str;
            default = "#181825";
          };
          foreground2 = mkOption {
            type = types.str;
            default = "#11111b";
          };
          inactive = mkOption {
            type = types.str;
            default = "#585b70";
          };
          accent = mkOption {
            type = types.str;
            default = "#cba6f7";
          };
          accept = mkOption {
            type = types.str;
            default = "#a6e3a1";
          };
          deny = mkOption {
            type = types.str;
            default = "#f38ba8";
          };
          active = mkOption {
            type = types.str;
            default = "#89b4fa";
          };
          hover = mkOption {
            type = types.str;
            default = "#313244";
          };
          text = mkOption {
            type = types.str;
            default = "#cdd6f4";
          };
        };
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = [
      packages.qs-config
      quickshell
      pkgs.kdePackages.qtvirtualkeyboard
      pkgs.cliphist
    ];
    xdg.configFile."shell/src".source = packages.qs-config;
    xdg.configFile."shell/colors.json".text = builtins.toJSON cfg.colors;
    home.sessionVariables = {
      QS_CONFIG_PATH = "${config.xdg.configHome}/shell/src";
      QML2_IMPORT_PATH = qmlPath;
      QT_PLUGIN_PATH = pluginPath;
    };
    systemd.user.services.qs-config = {
      Unit = {
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
        Requisite = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${quickshell}/bin/qs -p ${config.xdg.configHome}/shell/src";
        Restart = "on-failure";
        RestartSec = 1;
        Environment = [
          "QS_CONFIG_PATH=${config.xdg.configHome}/shell/src"
          "QML2_IMPORT_PATH=${qmlPath}"
          "QT_PLUGIN_PATH=${pluginPath}"
        ];
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
