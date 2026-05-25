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

.PHONY: all help install-deps setup build left right reset clean check-docker

all: install-deps build

help:
	@printf "Targets:\n"
	@printf "  make all           Pull the ZMK Docker build image, then build all firmware\n"
	@printf "  make install-deps  Pull the ZMK Docker build image\n"
	@printf "  make setup         Initialize/update the local west workspace\n"
	@printf "  make build         Build left, right, and settings_reset firmware\n"
	@printf "  make left          Build left half firmware\n"
	@printf "  make right         Build right half firmware\n"
	@printf "  make reset         Build settings reset firmware\n"
	@printf "  make clean         Remove local build output and west workspace files\n"

install-deps: check-docker
	docker pull "$(ZMK_IMAGE)"

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

clean:
	rm -rf build .west modules tools zephyr bootloader zmk
