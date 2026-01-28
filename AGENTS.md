# AGENTS.md

## Project Overview

Torrust Demo is a production deployment configuration for the Torrust BitTorrent tracker and index platform. It provides a complete Docker Compose-based infrastructure for running a public BitTorrent tracker and torrent index with monitoring, backups, and SSL/TLS support.

**Live Demo**: <https://index.torrust-demo.com/torrents>

**Main Components**:

- **Tracker**: BitTorrent tracker supporting UDP and HTTP protocols
- **Index**: Torrent index backend API
- **Index GUI**: Web frontend for browsing torrents
- **Nginx Proxy**: Reverse proxy with SSL/TLS termination
- **Prometheus**: Metrics collection
- **Grafana**: Monitoring dashboards
- **Certbot**: Let's Encrypt certificate management

## Repository Location

Production deployment is located at: `/home/torrust/github/torrust/torrust-demo`

All Docker Compose commands must be run from this directory.

## Setup Commands

```bash
# Navigate to the app directory
cd /home/torrust/github/torrust/torrust-demo

# Initialize storage directories and configuration
./share/bin/install.sh

# Start all services
docker compose up --build --detach

# View logs for all services
docker compose logs -f

# View logs for specific service
docker compose logs -f tracker
docker compose logs -f index
```

## Deployment

The deployment script automates pulling new images and restarting services:

```bash
# SSH into production server
ssh torrust@139.59.150.216

# Run deployment script
./share/bin/deploy-torrust-demo.com.sh
```

After deployment, always run smoke tests (see Testing Instructions section).

## Testing Instructions

### Smoke Tests

After any deployment or changes, run these smoke tests to verify functionality:

```bash
# Clone Torrust Tracker repository for test clients
git clone git@github.com:torrust/torrust-tracker.git
cd torrust-tracker

# Test UDP tracker announce
cargo run -p torrust-tracker-client --bin udp_tracker_client announce \
  udp://tracker.torrust-demo.com:6969/announce \
  9c38422213e30bff212b30c360d26f9a02136422 | jq

# Test HTTP tracker announce
cargo run -p torrust-tracker-client --bin http_tracker_client announce \
  https://tracker.torrust-demo.com \
  9c38422213e30bff212b30c360d26f9a02136422 | jq

# Test health check endpoint
TORRUST_CHECKER_CONFIG='{
  "udp_trackers": ["udp://tracker.torrust-demo.com:6969/announce"],
  "http_trackers": ["https://tracker.torrust-demo.com"],
  "health_checks": ["https://tracker.torrust-demo.com/api/health_check"]
}' cargo run -p torrust-tracker-client --bin tracker_checker
```

### Log Monitoring

```bash
# View filtered tracker logs (excludes common noise)
./share/bin/tracker-filtered-logs.sh

# View all container logs
docker compose logs -f

# View specific container logs with line limit
docker compose logs -f tracker | head -n100

# Search logs for errors
docker compose logs -f | grep "ERROR"
```

## Important Scripts

All utility scripts are located in `share/bin/`:

- `deploy-torrust-demo.com.sh` - Deployment automation
- `install.sh` - Initialize storage directories and default configs
- `index-db-backup.sh` - Backup Index SQLite database
- `tracker-db-backup.sh` - Backup Tracker SQLite database
- `ssl_renew.sh` - Renew Let's Encrypt certificates
- `tracker-filtered-logs.sh` - View tracker logs with noise filtered out
- `time-running.sh` - Check how long a container has been running

## Configuration Files

Configuration templates are in `share/container/default/config/`:

- `tracker.prod.container.sqlite3.toml` - Tracker configuration
- `index.prod.container.sqlite3.toml` - Index configuration
- `nginx.conf` - Nginx reverse proxy configuration
- `prometheus.yml` - Prometheus scrape configuration
- `crontab.conf` - Cron jobs for backups and SSL renewal

Runtime configurations are stored in `storage/` directory (not tracked in git).

## Service Ports

**External Ports** (exposed to internet):

- 80/tcp - HTTP (redirects to HTTPS)
- 443/tcp - HTTPS
- 6868/udp - UDP Tracker
- 6969/udp - UDP Tracker (main)

**Internal Ports** (Docker network only):

- 3000 - Index GUI
- 3001 - Index API
- 3100 - Grafana
- 7070 - HTTP Tracker
- 1212 - Tracker API
- 9090 - Prometheus (should NOT be exposed externally)

## Monitoring and Backups

### Grafana Dashboards

Access Grafana at: <http://grafana.torrust-demo.com>

Dashboard configurations are backed up in `share/grafana/dashboards/`:

- `metrics.json` - Tracker metrics dashboard
- `stats.json` - Tracker stats dashboard

### Automated Backups

Backups run via cron (see `share/container/default/config/crontab.conf`):

- Index database: Hourly backups, 7-day retention
- SSL certificates: Daily renewal check at 12:00

Backup location: `/home/torrust/backups`

```bash
# Manual backup
./share/bin/index-db-backup.sh

# Check backup status
ls -alt /home/torrust/backups

# View cron logs
tail /var/log/cron.log
```

## Rollback Procedure

If a deployment causes issues:

1. Check available Docker images: `docker images torrust/tracker`
2. Tag the previous version: `docker tag <image_id> torrust/tracker:rollback`
3. Update `compose.yaml` to use the `:rollback` tag
4. Restart services: `docker compose up --build --detach`
5. Verify with smoke tests and log monitoring

See [docs/rollbacks.md](docs/rollbacks.md) for detailed instructions.

## Security Considerations

**Firewall**: Digital Ocean firewall is configured to:

- Allow ports 80, 443, 6868/udp, 6969/udp only
- Block port 9090 (Prometheus has no authentication)
- Temporarily enable port 80 when renewing Let's Encrypt certificates

**Secrets**: Production secrets are in `.env.production` (not tracked in git):

- `USER_ID` - User ID for container processes
- `GF_SECURITY_ADMIN_USER` - Grafana admin username
- `GF_SECURITY_ADMIN_PASSWORD` - Grafana admin password
- `TORRUST_TRACKER_CONFIG_OVERRIDE_HTTP_API__ACCESS_TOKENS__ADMIN` - Tracker API token

## Code Conventions

**Commit Messages**: Use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `chore:` - Maintenance tasks
- `refactor:` - Code refactoring

**Shell Scripts**:

- Use bash shebang: `#!/bin/bash`
- Include comments explaining script purpose
- Use absolute paths for production scripts
- Exit on errors for critical operations

**Docker Compose**:

- Use `--build --detach` flags for production deployments
- Set log rotation: `max-size: "10m"`, `max-file: "10"`
- Use restart policy: `unless-stopped` for production services

**Linting**:

- All Markdown files must pass markdown linter
- All files must pass CSpell spell checking
- Add project-specific terms to `project-words.txt`
- Run `npx markdownlint-cli2 "**/*.md"` to check Markdown
- Run `npx cspell "**/*"` to check spelling
- See [Linting Guide](docs/linting.md) for detailed instructions

## Useful Docker Commands

```bash
# List running containers
docker ps

# Check container uptime
./share/bin/time-running.sh tracker

# Restart specific service
docker compose restart tracker

# View container resource usage
docker stats

# Clean up unused images and containers
docker system prune -af

# Access container shell
docker exec -it tracker /bin/bash
```

## Documentation

- [Setup Guide](docs/setup.md) - Initial server setup
- [Deployment Guide](docs/deployment.md) - Deployment procedures
- [Firewall Configuration](docs/firewall.md) - Security setup
- [Rollback Guide](docs/rollbacks.md) - Rollback procedures
- [Backup Guide](docs/backups.md) - Backup management
- [Sample Commands](docs/sample_commands.md) - Common Docker commands
- [Linting Guide](docs/linting.md) - Code quality and linting requirements

## Integration

**qBittorrent Plugin**: A search plugin is available in `docs/qbittorrent/torrust.py` that allows qBittorrent users to search the Torrust index directly from the client.

## Production URLs

- **Index Web UI**: <https://index.torrust-demo.com>
- **Tracker HTTP**: <https://tracker.torrust-demo.com/announce>
- **Tracker UDP**: udp://tracker.torrust-demo.com:6969/announce
- **Grafana**: <http://grafana.torrust-demo.com>
- **Tracker API**: <https://tracker.torrust-demo.com/api/>
- **Index API**: <https://index.torrust-demo.com/api/>
