{
  pkgs,
  user,
  ...
}: {
  imports = [
    ./modules/neovim.nix
    ./modules/git.nix
    ./modules/zsh.nix
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

  programs.home-manager.enable = true;
}
