#!/usr/bin/env bash
set -euo pipefail

GMOD_DIR="${GMOD_DIR:-$HOME/gmod-ds}"

usage() {
    cat <<EOF
Usage:
  ./scripts/install-gmod-server.sh

Environment variables:
  GMOD_DIR   Install path for the Garry's Mod dedicated server.
             Default: $HOME/gmod-ds

Example:
  GMOD_DIR="$HOME/servers/gmod" ./scripts/install-gmod-server.sh
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

if ! command -v steamcmd >/dev/null 2>&1; then
    cat >&2 <<EOF
steamcmd is not installed or is not on PATH.

Install SteamCMD first, then run this script again.

On Arch/Manjaro, it is usually:
  sudo pacman -S steamcmd

If pacman cannot find it, enable the multilib repo in /etc/pacman.conf, then:
  sudo pacman -Syu steamcmd
EOF
    exit 1
fi

mkdir -p "$GMOD_DIR"

echo "Installing/updating Garry's Mod dedicated server into:"
echo "  $GMOD_DIR"

run_steamcmd() {
    steamcmd "$@"
}

if ! run_steamcmd \
    +force_install_dir "$GMOD_DIR" \
    +login anonymous \
    +app_info_update 1 \
    +app_update 4020 validate \
    +quit; then
    cat >&2 <<EOF

SteamCMD failed on the first try. Retrying without validate; this sometimes
gets around SteamCMD's "Missing configuration" metadata/cache error.

EOF

    run_steamcmd \
        +force_install_dir "$GMOD_DIR" \
        +login anonymous \
        +app_info_update 1 \
        +app_update 4020 \
        +quit
fi

cat <<EOF

Done.

Next run:
  GMOD_DIR="$GMOD_DIR" ./scripts/run-gmod-bridge.sh
EOF
