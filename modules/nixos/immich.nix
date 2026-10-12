{
  config,
  lib,
  ...
}:

let
  cfg = config.homelab.immich;
  hl = config.homelab;
in
{
  options.homelab.immich = {
    enable = lib.mkEnableOption "Immich photo gallery";
    port = lib.mkOption {
      type = lib.types.port;
      default = 2283;
    };
  };

  config = lib.mkIf cfg.enable {
    services.immich = {
      enable = true;
      host = "127.0.0.1";
      port = cfg.port;
      mediaLocation = "${hl.dataRoot}/immich";
      # GPU for machine learning:
      # accelerationDevices = [ "/dev/dri/renderD128" ];
    };
    # Authentik OAuth: Administration -> Settings -> Authentication -> OAuth
  };
}
