{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs: {
    nixosConfigurations =
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
      in
      {
        severas = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [ ./hosts/severas ];
        };

        LBook = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            ./hosts/LBook/configuration.nix
            inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
            inputs.nixos-hardware.nixosModules.common-gpu-intel-disable
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.gustas = import ./hosts/LBook/home/home.nix;
              home-manager.extraSpecialArgs = specialArgs // {
                firefox-addons = inputs.firefox-addons.packages.${system};
              };
            }
          ];
        };

        T480s = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            ./hosts/T480s/configuration.nix
            inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480s
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.jolanta = import ./users/jolanta.nix;
              home-manager.extraSpecialArgs = specialArgs;
            }
          ];
        };
      };
  };
}
