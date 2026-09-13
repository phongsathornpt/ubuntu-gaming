# Architecture

## Goal

Ubuntu Gaming is an AMD-first gaming desktop distribution. It keeps an Ubuntu LTS userspace while allowing the hardware-facing stack to move faster after validation.

## v0.1 baseline

- Ubuntu 24.04 LTS (`noble`) userspace
- amd64 first
- GNOME desktop on Wayland
- AMDGPU kernel driver
- Mesa RadeonSI + RADV
- PipeWire/WirePlumber
- GameMode and MangoHud
- zram for compressed swap
- reproducible public GitHub Actions builds

## Update policy

The base operating system follows Ubuntu LTS security updates. Kernel, Mesa and firmware are treated as a separate hardware enablement layer. They must pass staging and hardware tests before promotion. Development snapshots must never be promoted directly to the stable channel merely because they are newer.

Planned channels:

- `stable`: validated releases for normal installations
- `testing`: release candidates and hardware validation
- `edge`: current hardware stack for development and early hardware support

## AMD and gaming policy

The distribution uses the upstream `amdgpu` kernel driver and Mesa's RADV/RadeonSI drivers by default. AMDGPU-PRO is not part of the default graphics stack.

Performance changes must be benchmarked. Security mitigations are not disabled as a gaming optimization. CPU-wide performance mode is not forced permanently; game-specific policy belongs in the gaming profile layer.

## Display policy

Wayland is the default session. VRR/Adaptive-Sync/FreeSync support is a first-class target, including mixed-refresh multi-monitor configurations. VRR capability and ranges must be derived from the actual display stack rather than hard-coded.

## Memory policy

The initial memory policy uses zram capped at 8 GiB with LZ4 compression. PSI/systemd-oomd integration and workload-specific tuning will be validated before becoming stable defaults.

## Build pipeline

The first stage builds a root filesystem with `mmdebstrap`, applies version-controlled overlays, validates GNOME and AMD Mesa components, and emits a compressed rootfs artifact. Later stages will add custom kernel/Mesa packages, ISO construction, QEMU boot tests, release signing and physical AMD GPU validation.
