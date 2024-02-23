{
  description = "Python example flake for Zero to Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }: let
    # Systems supported
    allSystems = [
      "x86_64-linux" # 64-bit Intel/AMD Linux
      "aarch64-linux" # 64-bit ARM Linux
      "x86_64-darwin" # 64-bit Intel macOS
      "aarch64-darwin" # 64-bit ARM macOS
    ];

    # Helper to provide system-specific attributes
    forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
      pkgs = import nixpkgs { inherit system; };
    });
  in {
    packages = forAllSystems ({ pkgs }: with pkgs.lib; {
      flashcards = pkgs.stdenv.mkDerivation {
        name = "markdown-flash-cards";
        src = ./.;
        buildInputs = let
          ghcPlusPkgs = pkgs.haskellPackages.ghcWithPackages (p: with p; [
            random
            random-shuffle
            pandoc
            text
            turtle
            shh-extras
          ]);
        in [
          ghcPlusPkgs
          pkgs.pandoc
          pkgs.texlive.combined.scheme-full
        ];
        phases = ["unpackPhase" "buildPhase"];
        buildPhase = ''
          mkdir -p $out
          runhaskell haskell/main.hs input $out haskell
        '';
      };
    });

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.flashcards;
  };
}
