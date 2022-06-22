{
  description = "fantastic-morphisms";

  inputs = {
    # Nix Inputs
    nixpkgs.url = github:nixos/nixpkgs/nixpkgs-unstable;
    flake-utils.url = github:numtide/flake-utils;
    pre-commit-hooks.url = github:cachix/pre-commit-hooks.nix;
    pre-commit-hooks.inputs.flake-utils.follows = "flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    pre-commit-hooks,
    flake-utils,
  }: let
    utils = flake-utils.lib;
  in
    utils.eachDefaultSystem (system: let
      compilerVersion = "ghc923";
      pkgs = nixpkgs.legacyPackages.${system};
      hsPkgs = pkgs.haskell.packages.${compilerVersion}.override {
        overrides = hfinal: hprev: {
          fantastic-morphisms = hfinal.callCabal2nix "fantastic-morphisms" ./. {};
        };
      };
    in rec {
      packages =
        utils.flattenTree
        {fantastic-morphisms = hsPkgs.fantastic-morphisms;};

      # nix flake check
      checks = {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            alejandra.enable = true;
            fourmolu.enable = true;
            cabal-fmt.enable = true;
          };
        };
      };

      # nix develop
      devShell = hsPkgs.shellFor {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        withHoogle = true;
        packages = p: [
          p.fantastic-morphisms
        ];
        buildInputs = with pkgs;
          [
            hsPkgs.haskell-language-server
            haskellPackages.cabal-install
            cabal2nix
            haskellPackages.ghcid
            haskellPackages.fourmolu
            haskellPackages.cabal-fmt
            nodePackages.serve
          ]
          ++ (builtins.attrValues (import ./scripts.nix {s = pkgs.writeShellScriptBin;}));
      };

      # nix build
      defaultPackage = packages.fantastic-morphisms;
    });
}
