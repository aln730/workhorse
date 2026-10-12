{
  pkgs,
  ...
}:
{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "-d --delete-older-than 30d";
  };
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    btop
    tmux
    curl
    wget
    rsync
    smartmontools
    pciutils
    usbutils
    wireguard-tools
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  security.sudo.wheelNeedsPassword = false;

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "1h";
  };

  networking.firewall.enable = true;

  services.smartd.enable = true;
  services.fstrim.enable = true;
  services.journald.extraConfig = "SystemMaxUse=1G";
}
