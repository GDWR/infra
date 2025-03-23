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

      createSystem = hostCfg:
        nixpkgs.lib.nixosSystem {
          modules = [ 
            hostCfg
            self.nixosModules.formats 
            { 
              # Pin nixpkgs to the flake input, so that the packages installed
              # come from the flake inputs.nixpkgs.url.
              nix.registry.nixpkgs.flake = nixpkgs; 
              nix.settings.experimental-features = "nix-command flakes";
              system.stateVersion = "24.11";
            }
          ];
        };
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

      nixosConfigurations = {
        router = createSystem hosts/router.nix;
        master = createSystem hosts/master.nix;
        node = createSystem hosts/node.nix;
      };

      devShells = forAll ({ system, pkgs }: {
        default = pkgs.mkShell {
          inherit system;
          packages = [ 
            pkgs.git-crypt
            pkgs.nixos-generators 
          ];
        };
      });
    };
}
