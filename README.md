# Torrust Demo

This repo contains all the configuration needed to run the live Torrust demo.

Live demo: <https://index.torrust-demo.com/torrents>.

It's also used to track issues in production.

## Demo tracker

- HTTP Tracker: <https://tracker.torrust-demo.com/announce>
- UDP Tracker: udp://tracker.torrust-demo.com:6969/announce

Currently, the demo tracker is running on a single server with the following specifications:

- Basic / 8 GB / 4 vCPUs.

### Monitoring

The demo includes monitoring with Grafana dashboards for the tracker to track performance metrics, peer connections, and system health.

![Grafana Dashboard](docs/media/torrust-tracker-grafana-dashboard.png)

## Documentation

- [Setup](docs/setup.md)
- [Deployment](docs/deployment.md)
- [Server Optimization](docs/server-optimization.md)
- [Firewall](docs/firewall.md)
- [Sample Commands](docs/sample_commands.md)
- [Rollbacks](docs/rollbacks.md)
- [Backups](docs/backups.md)
