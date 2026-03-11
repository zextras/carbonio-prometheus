# Carbonio Prometheus

![Contributors](https://img.shields.io/github/contributors/zextras/carbonio-prometheus "Contributors") ![Activity](https://img.shields.io/github/commit-activity/m/zextras/carbonio-prometheus "Activity") ![Project](https://img.shields.io/badge/project-carbonio-informational
"Project") [![Twitter](https://img.shields.io/twitter/url/https/twitter.com/zextras.svg?style=social&label=Follow%20%40zextras)](https://twitter.com/zextras)

A collection of scripts, config files, configurations and Prometheus exporters used in Carbonio.

## Quick Start

### Prerequisites

- Docker or Podman installed
- Make

### Building Packages

```bash
# Build all packages for Ubuntu 22.04
make build TARGET=ubuntu-jammy

# Build all packages for Rocky Linux 9
make build TARGET=rocky-9

# Build a single package
make build PACKAGE=alertmanager TARGET=ubuntu-jammy
```

### Interactive Debug Build

For faster iterations, use `build-debug` to enter a container with `yap prepare`
already done. You can then rebuild packages repeatedly without paying the
preparation cost each time:

```bash
make build-debug TARGET=ubuntu-jammy
```

Once inside the container:

```bash
# Build all packages
yap build ubuntu-jammy /project

# Build only one package
yap build --from alertmanager --to alertmanager ubuntu-jammy /project
```

### Build Times

| Method | Time |
| ------ | ---- |
| CI build | ~8m |
| `make build` (full, local) | ~1m 20s |
| `yap build` inside `make build-debug` (single package) | ~50s |

### Supported Targets

- `ubuntu-jammy` - Ubuntu 22.04 LTS
- `ubuntu-noble` - Ubuntu 24.04 LTS
- `rocky-8` - Rocky Linux 8
- `rocky-9` - Rocky Linux 9

### Configuration

You can customize the build by setting environment variables:

```bash
# Use a specific container runtime
make build TARGET=ubuntu-jammy CONTAINER_RUNTIME=docker

# Use a different output directory
make build TARGET=rocky-9 OUTPUT_DIR=./my-packages
```

Run `make help` for the full list of targets and options.

## Contribute to Carbonio Prometheus

All contributions are accepted! Please refer to the CONTRIBUTING file (if present in this repository)
for more detail on how to contribute. If the repository has a Code of Conduct,
we kindly ask to follow that as well.
