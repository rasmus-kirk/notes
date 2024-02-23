{
  description = "A report built with Pandoc, XeLaTex and a custom font";

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.report = (
      let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};
        #fonts = pkgs.makeFontsConf { fontDirectories = [ pkgs.dejavu_fonts ]; };
      in
        pkgs.stdenv.mkDerivation {
          name = "markdown-flash-cards";
          src = ./.;
          buildInputs = with pkgs; [
            markdown-anki-decks
          ];
          phases = ["unpackPhase" "buildPhase"];
          buildPhase = ''
            dir="input"

            mkdir -p $out

            # Zip doesn't support dates before 1980, so set the date accordingly
            unset SOURCE_DATE_EPOCH
            touch `find . -type f`
            export SOURCE_DATE_EPOCH=315532800

            #tmpDir="$TMP"
            tmpDir="$out/tmp"
            preDir="$tmpDir/pre"
            doneDir="$tmpDir/done"
            mkdir -p "$tmpDir"
            mkdir -p "$doneDir"
            mkdir -p "$preDir"

            for file in "$dir"/*; do
                # Check if the current item is a file
                if [ -f "$file" ]; then
                    filename=$(basename "$file")

                    echo "Processing file: $filename"
                    # Replace double dollar signs
                    sed ':a;N;$!ba;s/\$\$\([^$]*\)\$\$/\\\\\[\1\\\\\]/g' "$dir/$filename" > "$preDir/$filename"
                    #sed ':a;N;$!ba;s/\$\$\([^$]*\)\$\$/\[\$\$\]\1\[\/\$\$\]/g' "$dir/$filename" > "$tmpDir/pre/$filename"
                    #sed ':a;N;$!ba;s/\$\$\([^$]*\)\$\$/\\[\1\\]/g' "$dir/$filename" > "$tmpDir/pre/$filename"
                    # Replace single dollar signs
                    sed ':a;N;$!ba;s/\$\([^$]\+\)\$/\\\\\(\1\\\\\)/g' "$preDir/$filename" > "$doneDir/$filename"
                    #sed ':a;N;$!ba;s/\(\$[^$]*\$\)/\[$]\1[\/$]/g' "$tmpDir/pre/$filename" > "$tmpDir/$filename"
                fi
            done

            find "$dir/figures" -type f -exec cp {} "$doneDir" \;
            echo hello > "$out/log.log"

            for dirs in "$dir/figures/*"; do
              echo "$dirs" > "$out/log.log"
              for file in "$dirs"; do
                  echo "$file" > "$out/log.log"
                  # Check if the current item is a file
                  if [ -f "$file" ]; then
                      cp "$file" "$doneDir"
                  fi
                done
            done

            mdankideck "$doneDir" "$out"
          '';
        }
    );

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.report;
    };
}
