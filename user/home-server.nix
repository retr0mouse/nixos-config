{
  pkgs,
  user,
  ...
}: {
  imports = [
    ./modules/neovim.nix
    ./modules/git.nix
  ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
  };

  home.stateVersion = "25.11"; # First-deploy version — do not change.

  home.packages = with pkgs; [
    btop
    fzf
    jq
    tree
    yazi
    gh
    jdk25
  ];

  programs.ssh = {
    enable = true;

    enableDefaultConfig = false;

    matchBlocks."*" = {
      addKeysToAgent = "yes";
      compression = true;
      serverAliveInterval = 60;
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      config = "cd ~/dots && tree";
      rebuild = "sudo nixos-rebuild switch --flake ~/dots#$(hostname)";
    };

    oh-my-zsh = {
      enable = true;
      plugins = ["git"];
      theme = "robbyrussell";
    };
  };

  programs.home-manager.enable = true;
}
