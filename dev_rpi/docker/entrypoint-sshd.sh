#!/usr/bin/env bash
set -euo pipefail

mkdir -p /var/run/sshd /var/lib/ssh-host-keys

if [ ! -f /var/lib/ssh-host-keys/ssh_host_ed25519_key ]; then
    ssh-keygen -t ed25519 -f /var/lib/ssh-host-keys/ssh_host_ed25519_key -N ''
fi

if [ ! -f /var/lib/ssh-host-keys/ssh_host_rsa_key ]; then
    ssh-keygen -t rsa -b 4096 -f /var/lib/ssh-host-keys/ssh_host_rsa_key -N ''
fi

chmod 600 /var/lib/ssh-host-keys/ssh_host_*_key
chmod 644 /var/lib/ssh-host-keys/ssh_host_*_key.pub

exec "$@"