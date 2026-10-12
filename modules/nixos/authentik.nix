{
  config,
  lib,
  ...
}:

let
  cfg = config.homelab.authentik;
  hl = config.homelab;
  image = "ghcr.io/goauthentik/server:${cfg.version}";
  netService = "podman-network-authentik.service";

  commonEnv = {
    AUTHENTIK_POSTGRESQL__HOST = "authentik-postgres";
    AUTHENTIK_POSTGRESQL__USER = "authentik";
    AUTHENTIK_POSTGRESQL__NAME = "authentik";
  };
  commonVolumes = [
    "${hl.dataRoot}/authentik/media:/media"
    "${hl.dataRoot}/authentik/templates:/templates"
  ];
in
{
  options.homelab.authentik = {
    enable = lib.mkEnableOption "authentik SSO";
    version = lib.mkOption {
      type = lib.types.str;
      # Check https://github.com/goauthentik/authentik/releases for the latest.
      default = "2025.10.1";
      description = "authentik image tag (2025.10+ needs no Redis).";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."authentik/secret-key" = { };
    sops.secrets."authentik/postgres-password" = { };

    sops.templates."authentik.env".content = ''
      AUTHENTIK_SECRET_KEY=${config.sops.placeholder."authentik/secret-key"}
      AUTHENTIK_POSTGRESQL__PASSWORD=${config.sops.placeholder."authentik/postgres-password"}
    '';
    sops.templates."authentik-postgres.env".content = ''
      POSTGRES_PASSWORD=${config.sops.placeholder."authentik/postgres-password"}
    '';

    systemd.tmpfiles.rules = [
      "d ${hl.dataRoot}/authentik/postgres 0700 root root -"
      "d ${hl.dataRoot}/authentik/media 0755 root root -"
      "d ${hl.dataRoot}/authentik/templates 0755 root root -"
    ];

    # Dedicated network so the containers resolve each other by name.
    systemd.services.podman-network-authentik = {
      description = "Create podman network for authentik";
      wantedBy = [ "multi-user.target" ];
      path = [ config.virtualisation.podman.package ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        podman network exists authentik || podman network create authentik
      '';
    };

    systemd.services.podman-authentik-postgres = {
      requires = [ netService ];
      after = [ netService ];
    };
    systemd.services.podman-authentik-server = {
      requires = [ netService ];
      after = [
        netService
        "podman-authentik-postgres.service"
      ];
    };
    systemd.services.podman-authentik-worker = {
      requires = [ netService ];
      after = [
        netService
        "podman-authentik-postgres.service"
      ];
    };

    virtualisation.oci-containers.containers = {
      authentik-postgres = {
        image = "docker.io/library/postgres:17-alpine";
        extraOptions = [ "--network=authentik" ];
        environment = {
          POSTGRES_USER = "authentik";
          POSTGRES_DB = "authentik";
        };
        environmentFiles = [ config.sops.templates."authentik-postgres.env".path ];
        volumes = [ "${hl.dataRoot}/authentik/postgres:/var/lib/postgresql/data" ];
      };

      authentik-server = {
        inherit image;
        cmd = [ "server" ];
        extraOptions = [ "--network=authentik" ];
        ports = [
          "127.0.0.1:9000:9000"
          "127.0.0.1:9443:9443"
        ];
        environment = commonEnv;
        environmentFiles = [ config.sops.templates."authentik.env".path ];
        volumes = commonVolumes;
        dependsOn = [ "authentik-postgres" ];
      };

      authentik-worker = {
        inherit image;
        cmd = [ "worker" ];
        extraOptions = [ "--network=authentik" ];
        environment = commonEnv;
        environmentFiles = [ config.sops.templates."authentik.env".path ];
        volumes = commonVolumes;
        dependsOn = [ "authentik-postgres" ];
      };
    };
  };
}
