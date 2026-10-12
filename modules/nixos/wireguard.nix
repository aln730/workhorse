{
  config,
  lib,
  ...
}:

let
  cfg = config.homelab.wireguard;
in
{
  options.homelab.wireguard = {
    enable = lib.mkEnableOption "WireGuard VPN server";
    externalInterface = lib.mkOption {
      type = lib.types.str;
      example = "eno1";
      description = "Interface VPN clients are NATed out of.";
    };
    address = lib.mkOption {
      type = lib.types.str;
      default = "10.100.0.1/24";
      description = "Server address on wg0.";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 51820;
    };
    peers = lib.mkOption {
      default = { };
      description = "VPN clients, keyed by name.";
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            publicKey = lib.mkOption { type = lib.types.str; };
            ip = lib.mkOption {
              type = lib.types.str;
              example = "10.100.0.2";
            };
          };
        }
      );
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };

    networking.nat = {
      enable = true;
      externalInterface = cfg.externalInterface;
      internalInterfaces = [ "wg0" ];
    };

    networking.firewall.allowedUDPPorts = [ cfg.port ];

    sops.secrets."wireguard/private-key" = { };

    networking.wireguard.interfaces.wg0 = {
      ips = [ cfg.address ];
      listenPort = cfg.port;
      privateKeyFile = config.sops.secrets."wireguard/private-key".path;
      peers = lib.mapAttrsToList (name: peer: {
        inherit name;
        inherit (peer) publicKey;
        allowedIPs = [ "${peer.ip}/32" ];
      }) cfg.peers;
    };
  };
}
