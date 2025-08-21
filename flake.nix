{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/x86_64-linux";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    nix-filter.url = "github:numtide/nix-filter";
  };
  outputs = {
    flake-utils,
    nixpkgs,
    self,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        filter = inputs.nix-filter.lib;
      in {
        packages = rec {
          default = qs-config;
          qs-config = pkgs.callPackage ./pkg.nix {inherit filter;};
        };
        homeManagerModules = {
          qs-config = import ./module.nix self;
        };
      }
    );
}
