{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixos-generators, ... }:
    let
      allTargets = [ "x86_64-linux" "aarch64-linux" ];
      forAll = f: nixpkgs.lib.genAttrs allTargets (system: f {
        inherit system;
        pkgs = nixpkgs.legacyPackages.${system};
      });
    in
    {
      packages = forAll ({ system, pkgs }: {
        node = nixos-generators.nixosGenerate {
          inherit system;
          modules = [
            {
              nix.registry.nixpkgs.flake = nixpkgs;
              virtualisation.diskSize = 20 * 1024;
            }
          ];
          format = "raw";
        };
      });

      devShells = forAll ({ system, pkgs }: {
        default = pkgs.mkShell {
          inherit system;
          packages = [ pkgs.nixos-generators ];
        };
      });
    };
}
