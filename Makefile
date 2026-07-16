# SPDX-FileCopyrightText: 2026 Zextras <https://www.zextras.com>
#
# SPDX-License-Identifier: AGPL-3.0-only

# Makefile for building carbonio-prometheus packages using YAP
#
# Usage:
#   make build TARGET=ubuntu-jammy           # Build all packages for Ubuntu 22.04
#   make build PACKAGE=alertmanager          # Build only alertmanager
#   make build-debug                         # Interactive container with yap prepared
#   make clean                               # Clean build artifacts
#
# Supported targets:
#   ubuntu-jammy, ubuntu-noble, rocky-8, rocky-9

# Configuration
.DEFAULT_GOAL := build
YAP_IMAGE_PREFIX ?= docker.io/m0rf30/yap
YAP_VERSION ?= 2.4.1
CONTAINER_RUNTIME ?= $(shell command -v docker >/dev/null 2>&1 && echo docker || echo podman)

# Build directories
OUTPUT_DIR ?= artifacts

# Default target (can be overridden)
TARGET ?= ubuntu-jammy

# Optional: build a single package (e.g., PACKAGE=alertmanager)
PACKAGE ?=
YAP_BUILD_FLAGS = $(if $(PACKAGE),--from $(PACKAGE) --to $(PACKAGE),)

# Container image name (format: docker.io/m0rf30/yap-<target>:<version>)
YAP_IMAGE = $(YAP_IMAGE_PREFIX)-$(TARGET):$(YAP_VERSION)

# Container name
CONTAINER_NAME ?= yap-$(TARGET)

# Container options
CONTAINER_OPTS = --rm -ti \
	--name $(CONTAINER_NAME) \
	--entrypoint bash \
	-v $(CURDIR):/project \
	-v $(CURDIR)/$(OUTPUT_DIR):/artifacts

.PHONY: all build build-debug clean pull list-targets help

# Default target
all: build

## build: Build packages for the specified TARGET (optionally filtered by PACKAGE)
build:
	@echo "Building packages for $(TARGET)$(if $(PACKAGE), [package: $(PACKAGE)],)..."
	@mkdir -p $(OUTPUT_DIR)
	$(CONTAINER_RUNTIME) run $(CONTAINER_OPTS) $(YAP_IMAGE) -c "yap prepare -g $(TARGET) && yap build $(YAP_BUILD_FLAGS) $(TARGET) /project"

## build-debug: Launch interactive container with yap prepare already done
build-debug:
	@echo "Launching interactive build container for $(TARGET)..."
	@mkdir -p $(OUTPUT_DIR)
	$(CONTAINER_RUNTIME) run $(CONTAINER_OPTS) $(YAP_IMAGE) -c '\
		yap prepare -g $(TARGET) && \
		echo "" && \
		echo "========================================" && \
		echo " Ready! Run one of the following:" && \
		echo "========================================" && \
		echo "" && \
		echo "  Build all packages:" && \
		echo "    yap build $(TARGET) /project" && \
		echo "" && \
		echo "  Build a single package:" && \
		echo "    yap build --from <name> --to <name> $(TARGET) /project" && \
		echo "" && \
		echo "  Example:" && \
		echo "    yap build --from alertmanager --to alertmanager $(TARGET) /project" && \
		echo "" && \
		echo "========================================" && \
		echo "" && \
		exec bash'

## pull: Pull the YAP container image for the specified TARGET
pull:
	@echo "Pulling YAP image for $(TARGET)..."
	$(CONTAINER_RUNTIME) pull $(YAP_IMAGE)

## clean: Remove build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(OUTPUT_DIR)

## list-targets: List supported distribution targets
list-targets:
	@echo "Supported distribution targets:"
	@echo ""
	@echo "  ubuntu-jammy    (Ubuntu 22.04 LTS)"
	@echo "  ubuntu-noble    (Ubuntu 24.04 LTS)"
	@echo "  rocky-8         (Rocky Linux 8)"
	@echo "  rocky-9         (Rocky Linux 9)"
	@echo ""
	@echo "Usage: make build TARGET=<target>"

## help: Show this help message
help:
	@echo "Carbonio Prometheus - Build System"
	@echo ""
	@echo "This Makefile builds carbonio-prometheus packages using YAP"
	@echo "(Yet Another Packager) in Docker/Podman containers."
	@echo ""
	@echo "Usage:"
	@echo "  make <target> [TARGET=<distro>] [OPTIONS]"
	@echo ""
	@echo "Targets:"
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/## /  /' | column -t -s ':'
	@echo ""
	@echo "Options:"
	@echo "  TARGET             Distribution target (default: $(TARGET))"
	@echo "  PACKAGE            Build a single package by name (default: all)"
	@echo "  YAP_IMAGE_PREFIX   YAP image prefix (default: $(YAP_IMAGE_PREFIX))"
	@echo "  YAP_VERSION        YAP image version (default: $(YAP_VERSION))"
	@echo "  CONTAINER_RUNTIME  Container runtime (default: podman)"
	@echo "  CONTAINER_NAME     Container name (default: $(CONTAINER_NAME))"
	@echo "  OUTPUT_DIR         Output directory for packages (default: $(OUTPUT_DIR))"
	@echo ""
	@echo "Examples:"
	@echo "  make build TARGET=ubuntu-jammy"
	@echo "  make build TARGET=rocky-9"
	@echo "  make build PACKAGE=alertmanager"
	@echo "  make build TARGET=rocky-9 PACKAGE=node"
	@echo "  make build-debug"
	@echo "  make build-debug TARGET=rocky-9"
	@echo "  make pull TARGET=ubuntu-noble"
	@echo ""
