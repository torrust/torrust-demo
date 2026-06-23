# Issue #89 — Backup

> **GitHub Issue**: [torrust/torrust-demo#89](https://github.com/torrust/torrust-demo/issues/89)
> **Created**: 2026-06-23
> **State**: Open

## Objective

Manually backup the Torrust Demo application from the Digital Ocean droplet.

The droplet was turned off for this procedure. We turned it on, performed the backup,
and will turn it off again afterward.

## Backup Scope

What needs to be backed up:

- [x] **Tracker SQLite database** — the main tracker data (`storage/tracker/lib/database/sqlite3.db`) — **17 GB**
- [x] **Index SQLite database** — the index data (`storage/index/lib/database/sqlite3.db`) — **2.3 MB**
- [x] **Docker Compose configuration** — `compose.yaml`, `.env.production`, and `share/container/default/config/`
- [x] **SSL certificates** — Let's Encrypt certificates — **35 KB**
- [ ] **Grafana dashboards** — dashboard JSON configs (already in repo under `share/grafana/dashboards/`)
- [ ] **Prometheus data** — metrics data (if any persistent volume)

## Backup Steps

```bash
# 1. SSH into the droplet
ssh demo

# 2. Stop Docker stack
docker compose down

# 3. Backup tracker database
./share/bin/tracker-db-backup.sh

# 4. Backup index database
./share/bin/index-db-backup.sh

# 5. Package config files and SSL certs
tar czf /tmp/torrust-config-backup-2026-06-23.tar.gz compose.yaml .env.production share/container/default/config/
sudo tar czf /tmp/torrust-certs-backup-2026-06-23.tar.gz -C /home/torrust/github/torrust/torrust-demo storage/certbot/

# 6. Copy backups locally (from local machine)
scp demo:/home/torrust/backups/tracker_backup_2026-06-23_09-34-08.db .backup/
scp demo:/home/torrust/backups/backup_2026-06-23_09-36-20.db .backup/
scp demo:/tmp/torrust-config-backup-2026-06-23.tar.gz .backup/
scp demo:/tmp/torrust-certs-backup-2026-06-23.tar.gz .backup/
```

## Backed Up Files

All files are stored in the `.backup/` directory:

| File                                      | Size   |
| ----------------------------------------- | ------ |
| `tracker_backup_2026-06-23_09-34-08.db`   | 17 GB  |
| `backup_2026-06-23_09-36-20.db`           | 2.3 MB |
| `torrust-config-backup-2026-06-23.tar.gz` | 3.4 KB |
| `torrust-certs-backup-2026-06-23.tar.gz`  | 35 KB  |

## Progress Log

| Date       | Step                    | Status | Notes                                 |
| ---------- | ----------------------- | ------ | ------------------------------------- |
| 2026-06-23 | Turn on droplet         | Done   | Droplet powered on                    |
| 2026-06-23 | SSH into server         | Done   | Connected via `ssh demo`              |
| 2026-06-23 | Stop Docker stack       | Done   | `docker compose down`                 |
| 2026-06-23 | Backup tracker database | Done   | 17 GB — SQLite `.backup` command      |
| 2026-06-23 | Backup index database   | Done   | 2.3 MB — SQLite `.backup` command     |
| 2026-06-23 | Backup config files     | Done   | compose.yaml, .env.production, config |
| 2026-06-23 | Backup SSL certificates | Done   | 35 KB — required sudo                 |
| 2026-06-23 | Copy backups locally    | Done   | All files in `.backup/`               |
| 2026-06-23 | Turn off droplet        | Done   | Droplet powered off                   |

## Local Backup Storage

Backup files are stored in the `.backup/` directory at the repository root.
This directory is gitignored.

## References

- [Backup Guide](../backups.md)
- [Tracker DB Backup Script](../../share/bin/tracker-db-backup.sh)
- [Index DB Backup Script](../../share/bin/index-db-backup.sh)
