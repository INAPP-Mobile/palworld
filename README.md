# Deploy and Host

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.com/deploy/palworld)

Palworld Dedicated Server — one-click deploy with persistent volume, REST API, automated backups, and zero-downtime updates. Powered by [thijsvanloef/palworld-server-docker](https://github.com/thijsvanloef/palworld-server-docker).

After deploying, open Palworld → Multiplayer → Enter Server Address: `<your-railway-domain>:8211`

## About Hosting

This template runs a single Palworld dedicated server wrapped around the upstream Docker image. Game data persists on a Railway volume mounted at `/palworld` — saves, configs, and backups survive deploys and restarts.

The entrypoint runs as root on boot to chown the Railway volume (root-owned by default) to the `steam` user, then drops privileges before launching the server. Railway uses the REST API on port `8212` for healthchecks since the game port (`8211`) is UDP and Railway doesn't support UDP healthchecks.

Key environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `ADMIN_PASSWORD` | *auto-generated* | RCON/REST API admin password — visible in the service's Variables tab after deploy |
| `PLAYERS` | `16` | Max simultaneous players (1-32) |
| `SERVER_NAME` | `My Palworld Server` | Displayed in the server browser |
| `SERVER_PASSWORD` | *(empty)* | Set to make the server private |
| `COMMUNITY` | `true` | Show in public server browser |
| `RCON_ENABLED` | `false` | Enable remote console |
| `BACKUP_ENABLED` | `true` | Auto-backup world saves |
| `TZ` | `UTC` | Server timezone |

## Storage Requirements

The Palworld server requires **at least 10 GB of persistent storage** for the base installation. The initial game download via SteamCMD is ~5 GB, and world saves, backups, and mods increase over time. Railway provisions a volume automatically, but you may need to upgrade from the default 5 GB plan limit if you plan to run long-term with backups enabled.

## Why Deploy

- **Persistent saves**: world data lives on a Railway volume — no lost progress on restart.
- **Automated backups**: scheduled world saves with configurable retention.
- **REST API**: manage players, settings, and server state via HTTP.
- **No Docker knowledge required**: click deploy, configure env vars, start playing.

## Common Use Cases

- Host a private Palworld server for friends (set `SERVER_PASSWORD`)
- Run a public community server (set `COMMUNITY=true`)
- Experiment with server config without local Docker setup

## Dependencies for

This template has no external service dependencies — everything runs in a single container with a persistent volume.

### Deployment Dependencies

- A Railway account
- That's it
