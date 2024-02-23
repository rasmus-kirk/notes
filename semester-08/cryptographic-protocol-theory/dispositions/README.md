# Cryptographic Protocol Theory Notes
Notes for the Cryptographic Protocol Theory course at Aarhus University

## Compile cards using [nix](https://nixos.org/) (mac and linux only)

Nix allows you to build the notes in a reproducible way, meaning that we
will get precisely the same notes if we run the same commands on the same
git revision of this repo.

This also saves you from installing any dependencies other than nix and it
also saves you from worrying if you have the right versions. Simply install
nix[^1] if you haven't already and run the following command:

```shell
nix build --extra-experimental-features nix-command --extra-experimental-features flakes
```

This will create a symbolic link (`./result`) with the notes files.

For continous compilation (compiles all `.md` files on a `.md` file change),
use:

```shell
nix develop --extra-experimental-features nix-command --extra-experimental-features flakes -c pandoc-compile-continuous
```

[^1]: You can run the following command to install nix
      on linux and macos: `curl --proto '=https' --tlsv1.2
      -sSf -L https://install.determinate.systems/nix |
      sh -s -- install`. It uses the [Determinate Systems Nix
      Installer](https://github.com/DeterminateSystems/nix-installer) which
      is objectively superior to nix's native installer (Enables flakes and
      nix command by default and allows for easy uninstallation)
