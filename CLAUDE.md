# Claude instructions for my-keyboard

## Repo overview

ZMK firmware config for a **Corne 42** (3×6+3 split, `nice_nano_v2`). The keymap at `config/corne.keymap` was converted from the ZSA Planck EZ Oryx QMK export (`zsa_planck_ez_glow_aq6j5_Ja0DwO_planck_source.zip`) using `qmk2zmk`, then manually adapted from the Planck's 4×12 grid to the Corne's 3×6+3 matrix.

## Key files

- `config/corne.keymap` — shared ZMK keymap for both halves
- `config/corne.conf` — Kconfig settings
- `config/west.yml` — ZMK version pin (v0.3)
- `build.yaml` — GitHub Actions build matrix
- `Makefile` — local Docker build targets
- `zsa_planck_ez_glow_aq6j5_Ja0DwO_planck_source.zip` — original QMK source (reference only)

## Tools

`qmk2zmk` (https://github.com/patrickomatic/qmk2zmk) is installed to `tools/bin/` via `make install-qmk2zmk` (runs automatically as part of `make install-deps`). The `tools/` directory is gitignored and recreated on demand. Do not commit binaries under `tools/`.

To convert the Planck source to a fresh ZMK Corne keymap: `make convert` — writes to `config/corne.keymap.generated` (never overwrites the hand-tuned `config/corne.keymap`). To print a visual layout table: `make layout`.

## Building

Builds run inside Docker (`zmkfirmware/zmk-build-arm:stable`). Always use the Makefile targets rather than invoking `west` directly outside the container.

## Keymap notes

- Layer 0 (base): Colemak-DH with timeless home-row mods (`&hml`/`&hmr`)
- Layer 1 (lower): symbols; activated by left thumb `MO(1)`
- Layer 2 (raise): numbers/nav; activated by right thumb `MO(2)`
- Layer 3 (adjust): reached via conditional layer when lower+raise are both active
- `ST_MACRO_0` on base layer row 2 col 0: Cmd+C → Cmd+V (copy-paste macro)
- `caps_word` replaces Caps Lock on base layer

Keys that exist in the original Planck but are not yet mapped on the Corne (currently `&trans` everywhere):
- Lower layer bottom-right: tab-switching shortcuts (`LG+LS+[` / `RG+RS+]`), PgDn, PgUp
- Raise layer bottom-right: volume and brightness media keys
- Adjust layer: dynamic tapping-term controls, RGB controls
