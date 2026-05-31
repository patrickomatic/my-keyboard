SHELL := /bin/bash

ZMK_IMAGE := zmkfirmware/zmk-build-arm:stable
CONFIG_DIR := /workspaces/zmk-config/config
BOARD := nice_nano_v2

LEFT_SHIELD := corne_left
RIGHT_SHIELD := corne_right
RESET_SHIELD := settings_reset

DOCKER_RUN := docker run --rm \
	-v "$(CURDIR):/workspaces/zmk-config" \
	-w /workspaces/zmk-config \
	$(ZMK_IMAGE)

QMK2ZMK := tools/bin/qmk2zmk
QMK2ZMK_INSTALLER := https://github.com/patrickomatic/qmk2zmk/releases/latest/download/qmk2zmk-installer.sh

PLANCK_SOURCE_ZIP  := zsa_planck_ez_glow_aq6j5_Ja0DwO_planck_source.zip
PLANCK_KEYMAP_C    := zsa_planck_ez_glow_planck_source/keymap.c
CONVERTED_KEYMAP   := config/corne.keymap.generated

.PHONY: all help install-deps install-qmk2zmk setup build left right reset convert layout clean check-docker

all: install-deps build

help:
	@printf "Targets:\n"
	@printf "  make all              Pull the ZMK Docker build image, then build all firmware\n"
	@printf "  make install-deps     Pull the ZMK Docker build image and install local tools\n"
	@printf "  make install-qmk2zmk  Install qmk2zmk to tools/bin/\n"
	@printf "  make setup            Initialize/update the local west workspace\n"
	@printf "  make build            Build left, right, and settings_reset firmware\n"
	@printf "  make left             Build left half firmware\n"
	@printf "  make right            Build right half firmware\n"
	@printf "  make reset            Build settings reset firmware\n"
	@printf "  make convert          Convert the Planck QMK source to a ZMK Corne keymap ($(CONVERTED_KEYMAP))\n"
	@printf "  make layout           Print the Planck source layout table\n"
	@printf "  make clean            Remove local build output and west workspace files\n"

install-deps: check-docker install-qmk2zmk
	docker pull "$(ZMK_IMAGE)"

install-qmk2zmk:
	@if [ ! -x "$(QMK2ZMK)" ]; then \
		printf "Installing qmk2zmk to tools/bin/ ...\n"; \
		curl -fsSL "$(QMK2ZMK_INSTALLER)" | \
			QMK2ZMK_INSTALL_DIR="$(CURDIR)/tools" \
			QMK2ZMK_NO_MODIFY_PATH=1 \
			QMK2ZMK_PRINT_QUIET=1 \
			sh; \
	else \
		printf "qmk2zmk already installed: $$($(QMK2ZMK) --version 2>/dev/null || echo '(unknown version)')\n"; \
	fi

check-docker:
	@command -v docker >/dev/null || { printf "Docker is missing. Install Docker Desktop, then rerun this target.\n" >&2; exit 1; }
	@docker info >/dev/null || { printf "Docker is not running. Start Docker Desktop, then rerun this target.\n" >&2; exit 1; }

setup: check-docker
	$(DOCKER_RUN) sh -c 'test -d .west || west init -l config && west update --fetch-opt=--filter=tree:0 && west zephyr-export'

build: left right reset

left: check-docker
	$(DOCKER_RUN) sh -c 'test -d .west || west init -l config; west update --fetch-opt=--filter=tree:0; west zephyr-export; west build -s zmk/app -d build/left -b "$(BOARD)" -- -DSHIELD="$(LEFT_SHIELD)" -DZMK_CONFIG="$(CONFIG_DIR)"'

right: check-docker
	$(DOCKER_RUN) sh -c 'test -d .west || west init -l config; west update --fetch-opt=--filter=tree:0; west zephyr-export; west build -s zmk/app -d build/right -b "$(BOARD)" -- -DSHIELD="$(RIGHT_SHIELD)" -DZMK_CONFIG="$(CONFIG_DIR)"'

reset: check-docker
	$(DOCKER_RUN) sh -c 'test -d .west || west init -l config; west update --fetch-opt=--filter=tree:0; west zephyr-export; west build -s zmk/app -d build/settings_reset -b "$(BOARD)" -- -DSHIELD="$(RESET_SHIELD)" -DZMK_CONFIG="$(CONFIG_DIR)"'

convert: install-qmk2zmk
	unzip -p "$(PLANCK_SOURCE_ZIP)" "$(PLANCK_KEYMAP_C)" | \
		$(QMK2ZMK) --keyboard corne -f c -o "$(CONVERTED_KEYMAP)" /dev/stdin
	@printf "Converted keymap written to %s\n" "$(CONVERTED_KEYMAP)"

layout: install-qmk2zmk
	unzip -p "$(PLANCK_SOURCE_ZIP)" "$(PLANCK_KEYMAP_C)" | \
		$(QMK2ZMK) --print-layout --keyboard planck -f c /dev/stdin

clean:
	rm -rf build .west modules tools zephyr bootloader zmk
