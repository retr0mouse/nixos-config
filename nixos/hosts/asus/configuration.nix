{ config, lib, ... }:

{
  imports = [
    ../../modules/common.nix
    ./hardware-configuration.nix
  ];

  services.asusd.enable = true; # enable asus cli service
  services.logind.lidSwitchExternalPower = "ignore";
  networking.hostName = "ga503"; 

    # ASUS
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      amdgpuBusId = lib.mkForce "PCI:6:0:0";
      nvidiaBusId = "PCI:1:0:0";
      offload = {
        enable = true;
	enableOffloadCmd = true;
      };
    };
  };
  services.xserver.enable = true;
  services.xserver.videoDrivers = [
    "amdgpu"
    "nvidia"
  ];

  services.upower.enable = true;

  services.power-profiles-daemon.enable = true; # to manage power profiles
  
  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
  };
}
