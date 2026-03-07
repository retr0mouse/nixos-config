{ config, lib, ... }:

{
  imports = [
    ../../modules/common.nix
    ./hardware-configuration.nix
  ];
}
