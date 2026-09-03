# Palworld Dedicated Server on Railway

[![Deploy to Railway](https://railway.app/button.svg)](https://railway.com/deploy/palworld)

Host your own Palworld dedicated server on Railway with automated backups, REST API access, and automatic updates. Powered by [thijsvanloef/palworld-server-docker](https://github.com/thijsvanloef/palworld-server-docker).

## Features

- **Automated Backups** — Scheduled world saves to persistent volume
- **REST API** — Manage players, settings, and server state via HTTP
- **Automatic Updates** — Keep your server current with zero downtime
- **Auto Reboot** — Scheduled restarts to prevent memory leaks
- **Discord Integration** — Webhook notifications for events
- **Persistent Storage** — All saves stored on Railway volumes
- **One-Click Deploy** — No Docker knowledge required

## Connecting to Your Server

After deployment:

1. Get your server's public domain from the Railway dashboard
2. Open Palworld → Multiplayer → Enter Server Address: `<domain>:8211`
3. If you set a `SERVER_PASSWORD`, enter it when prompted

## Configuration

All settings are configured via environment variables in your Railway dashboard.

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `8211` | Game port (UDP + TCP) |
| `REST_API_PORT` | `8212` | REST API port (TCP) — used for healthcheck |
| `QUERY_PORT` | `27015` | Steam query port |
| `RCON_PORT` | `25575` | RCON remote console port |
| `PLAYERS` | `16` | Max players (1-32) |
| `SERVER_NAME` | `My Palworld Server` | Server browser name |
| `SERVER_PASSWORD` | *(empty)* | Server password (public if empty) |
| `ADMIN_PASSWORD` | `change-me` | RCON/REST API admin password |
| `COMMUNITY` | `true` | Show in server browser |
| `RCON_ENABLED` | `false` | Enable RCON |
| `REST_API_ENABLED` | `true` | Enable REST API (required for healthcheck) |
| `BACKUP_ENABLED` | `true` | Enable automated backups |
| `BACKUP_CRON_EXPRESSION` | `0 0 * * *` | Backup schedule (daily midnight) |
| `DELETE_OLD_BACKUPS` | `false` | Delete old backups |
| `OLD_BACKUP_DAYS` | `30` | Days to keep backups |
| `UPDATE_ON_BOOT` | `true` | Update server on boot |
| `AUTO_UPDATE_ENABLED` | `false` | Enable automatic updates |
| `AUTO_REBOOT_ENABLED` | `false` | Enable automatic reboots |
| `TZ` | `UTC` | Server timezone |

## Storage

The server uses a Railway volume mounted at `/palworld` for persistent storage. All world saves, settings, and backups are stored here.

## Healthcheck

Railway uses the REST API on port `8212` for healthchecks since the game port (`8211`) is UDP and Railway doesn't support UDP healthchecks. Make sure `REST_API_ENABLED=true` (default) to keep the service healthy.

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| 8211 | UDP + TCP | Game port (player connections) |
| 8212 | TCP | REST API (management + healthcheck) |
| 27015 | UDP | Steam server browser |
| 25575 | TCP | RCON (remote console) |

## Backup & Restore

Backups are stored in `/palworld/backups/` as `palworld-save-YYYY-MM-DD_HH-MM-SS.tar.gz`.

To restore a backup:

1. Stop the server
2. Extract the backup to `/palworld/Pal/`
3. Start the server

Use the REST API for programmatic backups:

```bash
curl -X POST https://${{RAILWAY_PUBLIC_DOMAIN}}:8212/api/v1/save \
  -H "Authorization: Bearer ${{ADMIN_PASSWORD}}" \
  -H "Content-Type: application/json"
```

## Auto-Pause

The server supports auto-pausing when no players are connected (disabled by default). Enable with `AUTO_PAUSE_ENABLED=true`.

## Upgrading

Pull the latest Railway template version or redeploy to get the latest Palworld server image.

## License

Palworld is a trademark of Pocketpair, Inc. This template is not affiliated with or endorsed by Pocketpair.
