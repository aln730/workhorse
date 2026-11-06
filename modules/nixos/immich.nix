{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.homelab.immich;
  hl = config.homelab;
in
{
  # 26.05 ships Immich 2.x, which is EOL with open CVEs. Take the module and
  # the package from nixos-unstable together so they stay in sync. Remove this
  # once the stable channel carries Immich 3.x (26.11).
  disabledModules = [ "services/web-apps/immich.nix" ];
  imports = [ "${inputs.nixos-unstable}/nixos/modules/services/web-apps/immich.nix" ];

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
      package = pkgs.unstable.immich;
      host = "127.0.0.1";
      port = cfg.port;
      mediaLocation = "${hl.dataRoot}/immich";
      # GPU for machine learning:
      # accelerationDevices = [ "/dev/dri/renderD128" ];
    };
    systemd.tmpfiles.rules = [ "d ${hl.dataRoot}/immich 0750 immich immich -" ];
    # Authentik OAuth: Administration -> Settings -> Authentication -> OAuth
  };
}
