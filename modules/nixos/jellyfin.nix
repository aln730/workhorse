{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.homelab.jellyfin;
  hl = config.homelab;
in
{
  options.homelab.jellyfin = {
    enable = lib.mkEnableOption "Jellyfin media server";
    hardwareAcceleration = lib.mkEnableOption "VAAPI hardware transcoding (Intel/AMD iGPU)";
  };

  config = lib.mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      openFirewall = false; # NPM / wg0 only
    };

    hardware.graphics = lib.mkIf cfg.hardwareAcceleration {
      enable = true;
      extraPackages = with pkgs; [ intel-media-driver ];
    };
    users.users.jellyfin.extraGroups = lib.optionals cfg.hardwareAcceleration [
      "video"
      "render"
    ];

    systemd.tmpfiles.rules = [
      "d ${hl.dataRoot}/media 0775 jellyfin jellyfin -"
    ];

    networking.firewall.interfaces.wg0.allowedTCPPorts = lib.optionals hl.wireguard.enable [ 8096 ];
  };
}
