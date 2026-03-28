#!/usr/bin/env bash
set -euo pipefail

: "${BUILD_DIR:=build/rpi-release}"
: "${RPI_SYSROOT_BASE:=/opt/rpi-sysroot}"
: "${RPI_TARGET_TRIPLE:=aarch64-linux-gnu}"

RPI_SYSROOT="${RPI_SYSROOT_BASE}/${RPI_TARGET_TRIPLE}"
BIN="${1:-${BUILD_DIR}/your_binary}"

if [[ ! -x "${BIN}" ]]; then
  echo "Binary not found or not executable: ${BIN}" >&2
  exit 1
fi

shift || true

exec qemu-aarch64 -L "${RPI_SYSROOT}" "${BIN}" "$@"
