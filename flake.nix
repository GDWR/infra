{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-generators, ... }:
    let
      allTargets = [ "x86_64-linux" "aarch64-linux" ];
      forAll = f: nixpkgs.lib.genAttrs allTargets (system: f {
        inherit system;
        pkgs = nixpkgs.legacyPackages.${system};
      });
    in
    {
      nixosModules.formats = { config, lib, ... }: {
        nixpkgs.hostPlatform = "x86_64-linux";
        imports = [
          nixos-generators.nixosModules.all-formats
        ];

        formatConfigs.vm = { config, ... }: {
          virtualisation.diskSize = 20 * 1024;
        };
      };

      nixosConfigurations.master = nixpkgs.lib.nixosSystem {
        modules = [ 
          hosts/master.nix  
          self.nixosModules.formats 
          { 
            # Pin nixpkgs to the flake input, so that the packages installed
            # come from the flake inputs.nixpkgs.url.
            nix.registry.nixpkgs.flake = nixpkgs; 
          }
        ];
      };
      nixosConfigurations.node = nixpkgs.lib.nixosSystem {
        modules = [ 
          hosts/node.nix  
          self.nixosModules.formats 
          { 
            # Pin nixpkgs to the flake input, so that the packages installed
            # come from the flake inputs.nixpkgs.url.
            nix.registry.nixpkgs.flake = nixpkgs; 
          }
        ];
      };

      devShells = forAll ({ system, pkgs }: {
        default = pkgs.mkShell {
          inherit system;
          packages = [ pkgs.nixos-generators ];
        };
      });
    };
}
