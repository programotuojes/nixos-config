{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-unstable, nix-darwin, ... }@inputs:
  let
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
      hidden = import ./hidden.nix;
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    };
  in {
    nixosConfigurations = {
      severas = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          ./hosts/severas/configuration.nix
        ];
      };

      LBook = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          ./hosts/LBook/configuration.nix
          inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
          inputs.nixos-hardware.nixosModules.common-gpu-intel-disable
        ];
      };

      T480s = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          ./hosts/T480s/configuration.nix
          inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480s
        ];
      };
    };

    darwinConfigurations."Gustass-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit inputs;
	hidden = specialArgs.hidden;
      };
      modules = [ ./hosts/mac/configuration.nix ];
    };
  };
}
