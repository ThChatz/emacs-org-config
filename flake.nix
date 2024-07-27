{
  description = "emacs configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };

  outputs = { self, nixpkgs, emacs-overlay }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; overlays = [ emacs-overlay.overlays.emacs ]; };
      emacs-with-org = (pkgs.emacsPackagesFor pkgs.emacs)
        .emacsWithPackages (
          ps: [ps.org]
        );
    in
    {

    # packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

    # packages.x86_64-linux.default = self.packages.x86_64-linux.hello;
      devShells."x86_64-linux".default = pkgs.mkShell {
        buildInputs = [ (pkgs.emacs) ];
      };

      packages."x86_64-linux".configured-emacs =
        (pkgs.emacsWithPackagesFromUsePackage {
          config = ././conf.org;

          alwaysTangle = true;
          defaultInitFile = true;

          extraEmacsPackages = epkgs: [
            epkgs.org
            epkgs.use-package
          ];
        });
      };
}
