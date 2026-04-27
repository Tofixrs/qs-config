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
  inherit (lib.options) mkEnableOption;
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
  };
  config = mkIf cfg.enable {
    home.packages = [
      packages.qs-config
      quickshell
      pkgs.kdePackages.qtvirtualkeyboard
      pkgs.cliphist
    ];
    xdg.configFile."shell/src".source = packages.qs-config;
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
