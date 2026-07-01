{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    xremap-flake.url = "github:xremap/nix-flake";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    ...
  }: let
    system = "x86_64-linux";
    user = "reisdro";
    mkDesktopHost = hostname:
      nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit inputs user;
        };

        modules = [
          ./system/hosts/${hostname}/configuration.nix

          home-manager.nixosModules.home-manager

          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";

            home-manager.extraSpecialArgs = {
              inherit inputs user;
            };

            home-manager.users.${user} = import ./user/home.nix;
          }
        ];
      };
    mkServerHost = hostname:
      nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit inputs user;
        };

        modules = [
          ./system/hosts/${hostname}/configuration.nix

          home-manager.nixosModules.home-manager

          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";

            home-manager.extraSpecialArgs = {
              inherit inputs user;
            };

            home-manager.users.${user} = import ./user/home-server.nix;
          }
        ];
      };
  in {
    nixosConfigurations = {
      clancy = mkDesktopHost "clancy";
      nico = mkServerHost "nico";
    };
  };
}
