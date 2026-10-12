{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.homelab.nextcloud;
  hl = config.homelab;
  hostName = "cloud.${hl.domain}";
in
{
  options.homelab.nextcloud = {
    enable = lib.mkEnableOption "Nextcloud";
    package = lib.mkOption {
      type = lib.types.package;
      # Use the newest nextcloudNN your nixpkgs offers.
      default = pkgs.nextcloud32;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Loopback port of Nextcloud's nginx (NPM proxies to it).";
    };
    phoneRegion = lib.mkOption {
      type = lib.types.str;
      default = "US";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."nextcloud/admin-password".owner = "nextcloud";

    services.nextcloud = {
      enable = true;
      package = cfg.package;
      inherit hostName;
      https = true;
      home = "${hl.dataRoot}/nextcloud";
      maxUploadSize = "16G";
      configureRedis = true;
      autoUpdateApps.enable = true;

      database.createLocally = true;
      config = {
        dbtype = "pgsql";
        adminuser = "admin";
        adminpassFile = config.sops.secrets."nextcloud/admin-password".path;
      };

      settings = {
        trusted_proxies = [
          "127.0.0.1"
          "::1"
        ];
        overwriteprotocol = "https";
        default_phone_region = cfg.phoneRegion;
        maintenance_window_start = 1;
      };

      extraAppsEnable = true;
      extraApps = {
        # user_oidc = log in with authentik
        inherit (cfg.package.packages.apps)
          calendar
          contacts
          notes
          user_oidc
          ;
      };

      phpOptions = {
        "opcache.interned_strings_buffer" = "16";
        memory_limit = "1G";
      };
    };

    # Keep the module's nginx on loopback so NPM owns 80/443.
    services.nginx.virtualHosts.${hostName}.listen = [
      {
        addr = "127.0.0.1";
        port = cfg.port;
      }
    ];
  };
}
