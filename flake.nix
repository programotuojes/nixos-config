{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs: {
    nixosConfigurations.severas = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = { 
        inherit inputs;
        pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
        hidden = import ./hidden.nix;
      };
      modules = [ ./hosts/severas ];
    };
  };
}
