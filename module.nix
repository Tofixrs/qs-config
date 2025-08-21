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
in {
  options.programs.qs-config = {
    enable = mkEnableOption "qs-config";
  };
  config = mkIf cfg.enable {
    home.packages = [
      packages.qs-config
      quickshell
    ];
    home.sessionVariables = {
      QS_CONFIG_PATH = "${packages.qs-config}";
    };
    systemd.user.services.qs-config = {
      Unit = {
        PartOf = ["graphical-session.target"];
        After = ["graphical-session-pre.target"];
      };
      Service = {
        ExecStart = "${quickshell}/bin/qs -p ${packages.qs-config}";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
