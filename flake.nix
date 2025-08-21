{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    filter.url = "github:numtide/nix-filter";
  };
  outputs = {
    nixpkgs,
    self,
    filter,
    ...
  }: let
    systems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        default = qs-config;
        qs-config = pkgs.callPackage ./pkg.nix {inherit filter;};
      }
    );
    homeManagerModules = {
      qs-config = import ./module.nix self;
    };
  };
}
