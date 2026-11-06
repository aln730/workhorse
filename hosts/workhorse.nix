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

  boot.loader.grub = {
	enable = true;
	device = "/dev/vda";
  };
  networking.hostName = "workhorse";
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Only set once the encrypted file exists, so the flake evaluates before you
  # have done the sops bootstrap (VM step 2 in the test plan).
  sops.defaultSopsFile = lib.mkIf (builtins.pathExists ../secrets/workhorse.yaml) ../secrets/workhorse.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  homelab = {
    domain = "agaws.net";
    dataRoot = "/srv";

    wireguard = {
      enable = false;
      externalInterface = "eno1";
      peers = { };
    };

    npm.enable = true;
    authentik.enable = true;
    immich.enable = true;
    jellyfin.enable = true;
    nextcloud.enable = true;
  };

  users.users.zxcv = {
    isNormalUser = true;
    description = "zxcv";
    initialPassword = "chom@1024";
    home = "/home/zxcv";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJRYGLISRTbpJ77ZwpvwIw/cYj324186UPRn6/XuhB+1 zxcv_tungsten"
    ];
  };
  programs.zsh.enable = true;
  system.stateVersion = "26.05";
}
