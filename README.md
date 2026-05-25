# Corne 42 ZMK Config

Personal ZMK firmware configuration for a Corne 42.

## Build targets

This repository is pinned to ZMK `v0.3` and builds:

- `nice_nano_v2` + `corne_left`
- `nice_nano_v2` + `corne_right`
- `nice_nano_v2` + `settings_reset`

Pushing to GitHub will run the ZMK user-config workflow and publish UF2 firmware artifacts from the Actions run.

## Files

- `build.yaml`: GitHub Actions build matrix.
- `config/west.yml`: ZMK manifest pin.
- `config/corne.conf`: Corne-specific Kconfig settings.
- `config/corne.keymap`: Shared keymap for both halves.

## Notes

Flash `settings_reset` first if the halves have old pairing data, then flash the left and right firmware. For keymap-only changes on a split keyboard, ZMK generally only requires reflashing the central side.
