{
  description = "A report built with Pandoc and a custom font";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; }; 
        fonts = pkgs.makeFontsConf { fontDirectories = [ pkgs.dejavu_fonts ]; };
        latexPkgs =  with pkgs; [
          pandoc
          haskellPackages.pandoc-crossref
          texlive.combined.scheme-full
        ];
        pandoc-compile = pkgs.writeShellApplication {
          name = "pandoc-compile";
          runtimeInputs = latexPkgs;
          text = "pandoc input.md -o output.pdf ";
        };
        pandoc-compile-continuous = pkgs.writeShellApplication {
          name = "pandoc-compile-continuous";
          runtimeInputs = [pandoc-compile pkgs.inotify-tools];
          text = ''
            set +e
            while true; do
              inotifywait -e modify input.md 2>/dev/null
              date
              pandoc-compile
            done
          '';
        };
        report = pkgs.stdenv.mkDerivation {
          name = "LatexReport";
          src = ./.;
          buildInputs = latexPkgs;
          phases = ["unpackPhase" "buildPhase"];
          buildPhase = ''
            export FONTCONFIG_FILE=${fonts}
            mkdir -p $out
            pandoc input.md -o $out/output.pdf
          '';        
        };
        in {
        devShell = pkgs.mkShell {
          buildInputs = latexPkgs ++ [pandoc-compile pandoc-compile-continuous];
        };
        defaultPackage = report;
      }
    );
}
