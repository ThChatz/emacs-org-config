{
  description = "emacs configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    emacs-overlay.url = "github:nix-community/emacs-overlay";

    # flake-utils.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.inputs.flake-utils.follows = "flake-utils";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.inputs.nixpkgs-stable.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, emacs-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
      pkgs = import nixpkgs { system = system; overlays = [ emacs-overlay.overlays.emacs ]; };
      emacs-with-org = (pkgs.emacsPackagesFor pkgs.emacs)
        .emacsWithPackages (
          ps: [ps.org]
        );
      emacs-with-config = (pkgs.emacsWithPackagesFromUsePackage {
          config = ././conf.org;

          alwaysTangle = true;
          defaultInitFile = true;

          extraEmacsPackages = epkgs: [
            epkgs.org
            epkgs.use-package
          ];
        });
    in
      {
        packages.default = emacs-with-config;
        _overlays.default = (final: prev: {
          emacs-with-config = emacs-with-config;
        });
      });
}
