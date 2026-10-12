{
  config,
  lib,
  ...
}:

let
  cfg = config.homelab.npm;
  hl = config.homelab;
in
{
  options.homelab.npm.enable = lib.mkEnableOption "Nginx Proxy Manager";

  config = lib.mkIf cfg.enable {
    # Host networking so NPM can reach every service on 127.0.0.1:<port>.
    virtualisation.oci-containers.containers.nginx-proxy-manager = {
      image = "docker.io/jc21/nginx-proxy-manager:latest";
      extraOptions = [ "--network=host" ];
      environment = {
        TZ = config.time.timeZone;
        DISABLE_IPV6 = "true";
      };
      volumes = [
        "${hl.dataRoot}/npm/data:/data"
        "${hl.dataRoot}/npm/letsencrypt:/etc/letsencrypt"
      ];
    };

    systemd.tmpfiles.rules = [
      "d ${hl.dataRoot}/npm/data 0755 root root -"
      "d ${hl.dataRoot}/npm/letsencrypt 0755 root root -"
    ];

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    # Admin UI (:81) only over the VPN.
    networking.firewall.interfaces.wg0.allowedTCPPorts = lib.optionals hl.wireguard.enable [ 81 ];
  };
}
