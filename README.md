# Corne 42 ZMK Config

Personal ZMK firmware configuration for a Corne 42.

## Build targets

This repository is pinned to ZMK `v0.3` and builds:

- `nice_nano_v2` + `corne_left`
- `nice_nano_v2` + `corne_right`
- `nice_nano_v2` + `settings_reset`

Pushing to GitHub will run the ZMK user-config workflow and publish UF2 firmware artifacts from the Actions run.

## Local build

The simplest build path is still GitHub Actions: push a commit and download the `firmware` artifact from the workflow run.

For local builds, use Docker. This mirrors the ZMK GitHub Actions build container and avoids installing the Zephyr SDK natively.

```sh
make install-deps
make build
```

Firmware outputs are written to:

- `build/left/zephyr/zmk.uf2`
- `build/right/zephyr/zmk.uf2`
- `build/settings_reset/zephyr/zmk.uf2`

`make install-deps` pulls the ZMK build image and installs `qmk2zmk` to `tools/bin/`. `make build` initializes or updates the local west workspace and builds all configured firmware targets.

## Converting and printing the layout

```sh
make convert   # convert Planck QMK source → config/corne.keymap.generated
make layout    # print a human-readable layout table of the Planck source
```

`make convert` runs [`qmk2zmk`](https://github.com/patrickomatic/qmk2zmk) on the Planck source zip (`zsa_planck_ez_glow_aq6j5_Ja0DwO_planck_source.zip`) and writes the auto-generated ZMK Corne keymap to `config/corne.keymap.generated`. Review the generated file and manually merge changes into `config/corne.keymap` — the production keymap has additional manual adaptations (home-row mods, thumb cluster layout) that qmk2zmk does not produce.

`make layout` prints the Planck source as a visual layout table for reference.

`qmk2zmk` is installed automatically to `tools/bin/` on first run of either target.

## Files

- `build.yaml`: GitHub Actions build matrix.
- `config/west.yml`: ZMK manifest pin.
- `config/corne.conf`: Corne-specific Kconfig settings.
- `config/corne.keymap`: Shared keymap for both halves.

## Notes

Flash `settings_reset` first if the halves have old pairing data, then flash the left and right firmware. For keymap-only changes on a split keyboard, ZMK generally only requires reflashing the central side.

The current keymap was converted from the exported ZSA Planck EZ Oryx QMK source using:

```sh
qmk2zmk --keyboard corne -o converted-corne.keymap zsa_planck_ez_glow_planck_source/keymap.c
```

The generated 4x12 Planck output was manually adapted to the Corne 42 matrix. QMK dynamic tapping-term controls and RGB controls were left out for now.
