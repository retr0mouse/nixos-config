{
  config,
  lib,
  pkgs,
  inputs,
  user,
  ...
}: {
  imports = [
    ../../modules/desktop.nix
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga503
  ];

  networking.hostName = "clancy";

  services.asusd.enable = true;
  services.logind.lidSwitchExternalPower = "ignore";

  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
  };

  services.xserver.enable = true;
  services.xserver.videoDrivers = ["amdgpu" "nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;

    open = true;
    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      #      amdgpuBusId = "PCI:6:0:0";
      nvidiaBusId = "PCI:1:0:0";

      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };
  };

  hardware.graphics.extraPackages = with pkgs; [
    mesa
  ];

  system.stateVersion = "25.11";
}
