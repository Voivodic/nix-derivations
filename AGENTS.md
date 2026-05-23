# AGENTS.md

## What this repo is

A Nix flake providing custom Python package derivations for scientific computing (cosmology, neural networks, utilities). Each package lives under `pkgs/<category>/<name>/default.nix`.

## Layout

- `flake.nix` — main flake: overlay, per-system packages, test derivations
- `default.nix` — non-flake fallback using `<nixpkgs>` channel
- `pkgs/cosmo/` — pyexshalos, class-pt
- `pkgs/nn/` — e3nn-jax, diffrax (optional CUDA support via `cudaSupport` arg)
- `pkgs/utils/` — getdist

## Key commands

```sh
nix build .#<package>              # build a package (e.g. pyexshalos, class-pt)
nix build .#cuda.<package>         # build with CUDA support
nix run .#test                      # run all import tests (GPU skipped if unavailable)
nix run .#test-cpu                  # CPU-only combined test
nix run .#test-gpu                  # GPU test (fails if no GPU)
nix run .#<package>-test            # individual package test (e.g. e3nn-jax-test)
nix run .#<package>-cpu             # individual CPU test
nix run .#<package>-gpu             # individual GPU test (strict, fails without GPU)
```

## Important quirks

- `flake.lock` is gitignored — every evaluation resolves the latest `nixos-unstable`
- Python import names differ from package names: `class-pt` → `classy`, `e3nn-jax` → `e3nn_jax`
- Default Python version is 3.14; 3.12 and 3.13 also exposed under `packages.python312` / `.python313`
- `allowUnfree = true` is set in the flake (needed for CUDA tooling)
- The overlay is exported as `overlays.default` for external consumption
- `legacyPackages` / `legacyPackagesCUDA` expose the full nixpkgs sets with the overlay applied

## Adding a new package

1. Create `pkgs/<category>/<name>/default.nix` as a `buildPythonPackage`
2. Add it to the overlay in `flake.nix` under `pythonPackagesExtensions`
3. Add it to `extractPackages` for each Python version
4. Add a test derivation using `mkTest` and wire it into `packages`
5. If non-flake usage matters, also add to `default.nix`
