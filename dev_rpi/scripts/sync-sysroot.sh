#!/usr/bin/env bash
set -euo pipefail

docker compose exec -T rpi-dev bash -lc '
set -euo pipefail

: "${RPI_HOST:=raspberrypi.local}"
: "${RPI_USER:=pi}"
: "${RPI_SYSROOT_BASE:=/opt/rpi-sysroot}"
: "${RPI_TARGET_TRIPLE:=aarch64-linux-gnu}"

RPI_SYSROOT="${RPI_SYSROOT_BASE}/${RPI_TARGET_TRIPLE}"
REMOTE="${RPI_USER}@${RPI_HOST}"
LIBDIR="aarch64-linux-gnu"

RSYNC_DIR_OPTS=(-aHAXx --numeric-ids --delete --safe-links)
RSYNC_FILE_OPTS=(-aHAX --numeric-ids --safe-links)

sync_dir() {
  local remote_dir="$1"
  local local_dir="$2"
  if ssh "${REMOTE}" "test -d '\''${remote_dir}'\''"; then
    mkdir -p "${local_dir}"
    rsync "${RSYNC_DIR_OPTS[@]}" "${REMOTE}:${remote_dir}/" "${local_dir}/"
    echo "[sync] ${remote_dir} -> ${local_dir}"
  else
    echo "[skip] remote dir not found: ${remote_dir}"
  fi
}

sync_file() {
  local remote_file="$1"
  local local_file="$2"
  if ssh "${REMOTE}" "test -e '\''${remote_file}'\''"; then
    mkdir -p "$(dirname "${local_file}")"
    rsync "${RSYNC_FILE_OPTS[@]}" "${REMOTE}:${remote_file}" "${local_file}"
    echo "[sync] ${remote_file} -> ${local_file}"
  fi
}

echo "[*] remote  : ${REMOTE}"
echo "[*] sysroot : ${RPI_SYSROOT}"

mkdir -p "${RPI_SYSROOT}"

sync_dir "/lib/${LIBDIR}"           "${RPI_SYSROOT}/lib/${LIBDIR}"
sync_dir "/usr/lib/${LIBDIR}"       "${RPI_SYSROOT}/usr/lib/${LIBDIR}"
sync_dir "/usr/include"             "${RPI_SYSROOT}/usr/include"
sync_dir "/usr/lib/pkgconfig"       "${RPI_SYSROOT}/usr/lib/pkgconfig"
sync_dir "/usr/share/pkgconfig"     "${RPI_SYSROOT}/usr/share/pkgconfig"
sync_dir "/usr/local/include"       "${RPI_SYSROOT}/usr/local/include"
sync_dir "/usr/local/lib/${LIBDIR}" "${RPI_SYSROOT}/usr/local/lib/${LIBDIR}"
sync_dir "/usr/local/lib/pkgconfig" "${RPI_SYSROOT}/usr/local/lib/pkgconfig"
sync_dir "/usr/lib/cmake"           "${RPI_SYSROOT}/usr/lib/cmake"
sync_dir "/usr/share/cmake"         "${RPI_SYSROOT}/usr/share/cmake"

sync_file "/lib/ld-linux-aarch64.so.1" "${RPI_SYSROOT}/lib/ld-linux-aarch64.so.1"
sync_file "/lib64/ld-linux-aarch64.so.1" "${RPI_SYSROOT}/lib64/ld-linux-aarch64.so.1"

echo "[*] sysroot sync done"
'