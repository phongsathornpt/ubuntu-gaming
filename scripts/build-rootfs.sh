#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${BUILD_DIR:-${ROOT_DIR}/build}"
ROOTFS="${BUILD_DIR}/rootfs"
SUITE="${UBUNTU_SUITE:-noble}"
MIRROR="${UBUNTU_MIRROR:-http://archive.ubuntu.com/ubuntu}"

if [[ ${EUID} -ne 0 ]]; then
  echo "build-rootfs.sh must run as root" >&2
  exit 1
fi

rm -rf "${ROOTFS}"
mkdir -p "${ROOTFS}"

mmdebstrap \
  --architectures=amd64 \
  --variant=apt \
  --components="main,restricted,universe,multiverse" \
  --include="$(grep -Ev '^[[:space:]]*(#|$)' "${ROOT_DIR}/config/packages.txt" | paste -sd, -)" \
  "${SUITE}" \
  "${ROOTFS}" \
  "${MIRROR}"

cp -a "${ROOT_DIR}/config/rootfs/." "${ROOTFS}/"

chroot "${ROOTFS}" systemctl enable gdm3 NetworkManager

printf 'ubuntu-gaming\n' > "${ROOTFS}/etc/hostname"

echo "rootfs built at ${ROOTFS}"
