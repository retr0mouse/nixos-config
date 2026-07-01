{
  programs.git = {
    enable = true;
    userName = "retr0mouse";
    userEmail = "daniil.sharin667@gmail.com";
    extraConfig.init.defaultBranch = "main";

    delta = {
      enable = true;
      options = {
        side-by-side = true;
        line-numbers = true;
      };
    };
  };
}
