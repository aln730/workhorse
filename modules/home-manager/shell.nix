# modules/home-manager/shell.nix
# Server variant of tungsten's shell.nix: same zsh/starship/etc, minus the
# desktop bits (alacritty, nerd fonts, mongosh, emacs/pritunl aliases).
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fd
    jq
    curl
    wget
    unzip
    zip
    tree
    htop
    btop
    fastfetch
    age
    sops
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    shellAliases = {
      ls = "eza";
      ll = "eza -l --icons --git";
      la = "eza -la --icons --git";
      lt = "eza --tree --icons";
      cat = "bat";
      c = "clear";
      x = "exit";
      z = "fastfetch";
      ncd = "cd /etc/nixos";
      nw = "sudo nixos-rebuild switch --flake .#workhorse";
      # server helpers
      pps = "sudo podman ps";
      jl = "journalctl -u";
      jf = "journalctl -f -u";
      sysf = "systemctl --failed";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;
      # show the hostname over SSH so you never rebuild the wrong machine
      format = "$hostname$directory$git_branch$git_status$character";
      right_format = "$cmd_duration";

      hostname = {
        ssh_only = true;
        format = "[$hostname](bold yellow) ";
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };

      directory = {
        style = "bold cyan";
        truncation_length = 3;
        truncate_to_repo = true;
        read_only = "";
      };

      git_branch = {
        symbol = " ";
        style = "bold purple";
      };

      git_status = {
        style = "yellow";
      };

      cmd_duration = {
        min_time = 500;
        format = "took [$duration](yellow)";
      };
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    git = true;
    icons = "auto";
  };

  programs.bat.enable = true;

  programs.ripgrep = {
    enable = true;
    arguments = [
      "--smart-case"
      "--hidden"
      "--glob=!.git"
    ];
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    escapeTime = 0;
    baseIndex = 1;
    mouse = true;
  };
}
