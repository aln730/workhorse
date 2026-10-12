{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./workhorse/hardware-configuration.nix
    ../modules/nixos/common.nix
    ../modules/nixos/homelab.nix
    ../modules/nixos/containers.nix
    ../modules/nixos/wireguard.nix
    ../modules/nixos/npm.nix
    ../modules/nixos/authentik.nix
    ../modules/nixos/immich.nix
    ../modules/nixos/jellyfin.nix
    ../modules/nixos/nextcloud.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "workhorse";
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Only set once the encrypted file exists, so the flake evaluates before you
  # have done the sops bootstrap (VM step 2 in the test plan).
  sops.defaultSopsFile = lib.mkIf (builtins.pathExists ../secrets/workhorse.yaml) ../secrets/workhorse.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  homelab = {
    domain = "example.com"; # <-- change me
    dataRoot = "/srv";

    wireguard = {
      enable = true;
      externalInterface = "eno1"; # <-- `ip link`
      peers = {
        phone = {
          publicKey = "REPLACE_WITH_PHONE_PUBLIC_KEY";
          ip = "10.100.0.2";
        };
        laptop = {
          publicKey = "REPLACE_WITH_LAPTOP_PUBLIC_KEY";
          ip = "10.100.0.3";
        };
      };
    };

    npm.enable = true;
    authentik.enable = true;
    immich.enable = true;
    jellyfin = {
      enable = true;
      hardwareAcceleration = false; # true for Intel/AMD iGPU transcoding
    };
    nextcloud.enable = true;
  };

  users.users.zxcv = {
    isNormalUser = true;
    description = "zxcv";
    home = "/home/zxcv";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAA... zxcv@laptop" # <-- change me
    ];
  };
  programs.zsh.enable = true;
  system.stateVersion = "26.05";
}
