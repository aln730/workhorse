{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "Arnav Gawas";
      user.email = "arnsg730@proton.me";
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
      safe.directory = [ "/etc/nixos" ];
      alias = {
        st = "status -sb";
        co = "checkout";
        br = "branch";
        ci = "commit";
        lg = "log --oneline --graph --decorate";
        last = "log -1 HEAD";
        amend = "commit --amend --no-edit";
        unstage = "reset HEAD --";
      };
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
