# home/server.nix: headless server profile (no desktop, no editors beyond vim)
{
  pkgs,
  ...
}:

{
  imports = [
    ../modules/home-manager/shell.nix
    ../modules/home-manager/git.nix
  ];

  home.username = "zxcv";
  home.homeDirectory = "/home/zxcv";

  # Pins the baseline behavior of Home-Manager-managed programs.
  # Do not bump this on upgrades; it exists for backwards-compat, not
  # version tracking. See the Home Manager release notes before ever
  # changing it.
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    ncdu
    dust
    lsof
    dig
    iotop
    podman-tui
  ];

  home.sessionVariables.EDITOR = "vim";

  # Lets Home Manager manage itself (adds the `home-manager` CLI).
  programs.home-manager.enable = true;
}
