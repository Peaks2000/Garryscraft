#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

GMOD_DIR="${GMOD_DIR:-$HOME/gmod-ds}"
ADDON_NAME="${ADDON_NAME:-mcgm}"
MAP="${MAP:-gm_flatgrass}"
MAXPLAYERS="${MAXPLAYERS:-16}"
PORT="${PORT:-27015}"
MC_PORT="${MC_PORT:-25565}"
GAMEMODE="${GAMEMODE:-sandbox}"
TICKRATE="${TICKRATE:-33}"
INSTALL_MODE="${INSTALL_MODE:-symlink}"

usage() {
    cat <<EOF
Usage:
  ./scripts/run-gmod-bridge.sh

Environment variables:
  GMOD_DIR       Path to your Garry's Mod dedicated server. Default: $HOME/gmod-ds
  MAP            GMod map. Default: gm_flatgrass
  MAXPLAYERS     GMod player slots. Default: 16
  PORT           GMod server port. Default: 27015
  MC_PORT        Minecraft bridge port from lua/mcgm/config.lua. Default: 25565
  GAMEMODE       GMod gamemode. Default: sandbox
  TICKRATE       srcds tickrate. Default: 33
  INSTALL_MODE   symlink or copy. Default: symlink

Examples:
  GMOD_DIR="$HOME/servers/gmod" ./scripts/run-gmod-bridge.sh
  MAP=gm_construct MAXPLAYERS=8 ./scripts/run-gmod-bridge.sh
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

if [[ ! -d "$GMOD_DIR" ]]; then
    cat >&2 <<EOF
Could not find GMOD_DIR:
  $GMOD_DIR

Install a Garry's Mod dedicated server there, or run with:
  GMOD_DIR="/path/to/gmod/server" ./scripts/run-gmod-bridge.sh

Common SteamCMD install command:
  steamcmd +force_install_dir "$HOME/gmod-ds" +login anonymous +app_update 4020 validate +quit
EOF
    exit 1
fi

SRCDS_RUN="$GMOD_DIR/srcds_run"
if [[ ! -x "$SRCDS_RUN" ]]; then
    cat >&2 <<EOF
Could not execute:
  $SRCDS_RUN

Make sure GMOD_DIR points at a Linux Garry's Mod dedicated server folder.
EOF
    exit 1
fi

ADDONS_DIR="$GMOD_DIR/garrysmod/addons"
TARGET_ADDON="$ADDONS_DIR/$ADDON_NAME"
mkdir -p "$ADDONS_DIR"

if [[ "$INSTALL_MODE" == "copy" ]]; then
    if [[ -e "$TARGET_ADDON" || -L "$TARGET_ADDON" ]]; then
        cat >&2 <<EOF
Addon target already exists:
  $TARGET_ADDON

Move or remove it first, then run this script again.
EOF
        exit 1
    fi
    mkdir -p "$TARGET_ADDON"
    cp -R "$ROOT_DIR/lua" "$ROOT_DIR/README.md" "$TARGET_ADDON/"
else
    if [[ -e "$TARGET_ADDON" || -L "$TARGET_ADDON" ]]; then
        if [[ "$(readlink "$TARGET_ADDON" 2>/dev/null || true)" != "$ROOT_DIR" ]]; then
            cat >&2 <<EOF
Addon target already exists:
  $TARGET_ADDON

Move or remove it first, then run this script again.
EOF
            exit 1
        fi
        rm "$TARGET_ADDON"
    fi
    ln -s "$ROOT_DIR" "$TARGET_ADDON"
fi

cat <<EOF
MC+GM bridge ready.

Addon:
  $TARGET_ADDON

GMod server:
  $GMOD_DIR

Minecraft Java clients:
  Version: 1.12.2
  Address: <your-server-ip>:$MC_PORT

Starting srcds...
EOF

cd "$GMOD_DIR"
exec "$SRCDS_RUN" \
    -game garrysmod \
    -console \
    -tickrate "$TICKRATE" \
    -port "$PORT" \
    +map "$MAP" \
    +maxplayers "$MAXPLAYERS" \
    +gamemode "$GAMEMODE"
