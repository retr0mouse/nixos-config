{pkgs, ...}: {
  programs.chromium = {
    package = pkgs.brave;
    enable = true;
    commandLineArgs = [
      "--password-store=basic"
    ];
    extensions = [
      {id = "mnjggcdmjocbbbhaepdhchncahnbgone";} # SponsorBlock
    ];
  };
}
