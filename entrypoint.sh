#!/bin/bash
# Palworld Railway entrypoint
#
# The upstream image (thijsvanloef/palworld-server-docker:v2.7.3) ships its own
# entrypoint at /home/steam/server/init.sh which:
#   - Validates the /palworld volume is writable
#   - Installs/updates the Palworld dedicated server
#   - Compiles server settings from env vars into PalWorldSettings.ini
#   - Starts the server binary
#
# What we add:
#   1. A "we made it past the chown" log line so the Railway deploy log
#      shows the server is initializing correctly.
#   2. Echo the effective UID so a misconfigured volume mount (where the
#      upstream chown fails) shows up immediately in logs.
#   3. Verify /palworld is writable by the steam user before exec.
#   4. Then exec the upstream entrypoint.
set -eu

echo "[palworld-railway] starting"
echo "[palworld-railway] image: thijsvanloef/palworld-server-docker:v2.7.3"
echo "[palworld-railway] uid=$(id -u) gid=$(id -g) steam_uid=1000"
echo "[palworld-railway] PORT=$PORT"
echo "[palworld-railway] REST_API_PORT=$REST_API_PORT"
echo "[palworld-railway] PLAYERS=$PLAYERS"
echo "[palworld-railway] SERVER_NAME=$SERVER_NAME"
echo "[palworld-railway] COMMUNITY=$COMMUNITY"

# Verify /palworld is writable
if [ ! -d /palworld ]; then
    echo "[palworld-railway] ERROR: /palworld directory does not exist"
    exit 1
fi

if [ ! -w /palworld ]; then
    echo "[palworld-railway] ERROR: /palworld is not writable by uid=$(id -u)"
    echo "[palworld-railway] This usually means the volume is owned by root"
    echo "[palworld-railway] Fix: ensure the Railway volume mount path is correct"
    exit 1
fi

# Create required directories as root before dropping to steam user
mkdir -p /palworld/Pal/Saved/SaveGames/0 /palworld/backups /palworld/Pal/Saved/Config/LinuxServer

# The upstream entrypoint is at /home/steam/server/init.sh. We exec it directly.
exec /home/steam/server/init.sh "$@"
