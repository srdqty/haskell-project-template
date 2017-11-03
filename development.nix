{ compiler ? "ghc802" }:

let
  pkgs = import ./nixpkgs-pinned.nix;

  haskellPackages = pkgs.haskell.packages."${compiler}".override {
    overrides = new: old: {
      haskell-project-template = old.callPackage ./. { };
    };
  };

  # Specifying ghc packages this way ensures that ghc-pkg can see our packages
  ghcAndPackages = haskellPackages.ghcWithPackages (self : [
    self.cabal-install
    self.cabal2nix
    self.hpack
  ]);
in
  haskellPackages.haskell-project-template.env.overrideAttrs (old: rec {
    buildInputs = [
      pkgs.git
      ghcAndPackages
    ];

    shellHook = old.shellHook + builtins.readFile ./bash-prompt.sh + ''
      source ${pkgs.git.out}/etc/bash_completion.d/git-prompt.sh
      source ${pkgs.git.out}/etc/bash_completion.d/git-completion.bash
    '';
  })