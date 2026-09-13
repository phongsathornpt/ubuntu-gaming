#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${BUILD_DIR:-${ROOT_DIR}/build}"
ROOTFS="${BUILD_DIR}/rootfs"
ISO_ROOT="${BUILD_DIR}/iso"
OUTPUT="${ISO_OUTPUT:-${BUILD_DIR}/ubuntu-gaming-amd64.iso}"
GRUB_CONFIG="${ISO_GRUB_CONFIG:-${ROOT_DIR}/iso/grub/grub.cfg}"

if [[ ${EUID} -ne 0 ]]; then
  echo "build-iso.sh must run as root" >&2
  exit 1
fi

if [[ ! -d "${ROOTFS}" ]]; then
  echo "rootfs not found: ${ROOTFS}" >&2
  exit 1
fi

if [[ ! -f "${GRUB_CONFIG}" ]]; then
  echo "GRUB config not found: ${GRUB_CONFIG}" >&2
  exit 1
fi

KERNEL="$(find "${ROOTFS}/boot" -maxdepth 1 -type f -name 'vmlinuz-*' | sort -V | tail -n1)"
INITRD="$(find "${ROOTFS}/boot" -maxdepth 1 -type f -name 'initrd.img-*' | sort -V | tail -n1)"

if [[ -z "${KERNEL}" || -z "${INITRD}" ]]; then
  echo "kernel/initrd missing from rootfs" >&2
  exit 1
fi

rm -rf "${ISO_ROOT}"
mkdir -p "${ISO_ROOT}/casper" "${ISO_ROOT}/boot/grub"

cp "${KERNEL}" "${ISO_ROOT}/casper/vmlinuz"
cp "${INITRD}" "${ISO_ROOT}/casper/initrd"
cp "${GRUB_CONFIG}" "${ISO_ROOT}/boot/grub/grub.cfg"

mksquashfs "${ROOTFS}" "${ISO_ROOT}/casper/filesystem.squashfs" \
  -noappend -comp zstd -b 1M

chroot "${ROOTFS}" dpkg-query -W --showformat='${Package} ${Version}\n' \
  > "${ISO_ROOT}/casper/filesystem.manifest"

du -sx --block-size=1 "${ROOTFS}" | cut -f1 \
  > "${ISO_ROOT}/casper/filesystem.size"

mkdir -p "$(dirname "${OUTPUT}")"

grub-mkrescue -o "${OUTPUT}" "${ISO_ROOT}"
sha256sum "${OUTPUT}" > "${OUTPUT}.sha256"

echo "ISO built at ${OUTPUT}"
