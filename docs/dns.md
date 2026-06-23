# DNS Configuration

The domain `torrust-demo.com` is managed through **Digital Ocean DNS**.

## Name Servers

| Type | Hostname         | Value                | TTL  |
| ---- | ---------------- | -------------------- | ---- |
| NS   | torrust-demo.com | ns1.digitalocean.com | 1800 |
| NS   | torrust-demo.com | ns2.digitalocean.com | 1800 |
| NS   | torrust-demo.com | ns3.digitalocean.com | 1800 |

## A Records

All A records point to the same droplet IP (`144.126.245.19`):

| Type | Hostname                   | Value          | TTL  |
| ---- | -------------------------- | -------------- | ---- |
| A    | `grafana.torrust-demo.com` | 144.126.245.19 | 3600 |
| A    | `index.torrust-demo.com`   | 144.126.245.19 | 3600 |
| A    | `tracker.torrust-demo.com` | 144.126.245.19 | 3600 |
| A    | `*.torrust-demo.com`       | 144.126.245.19 | 3600 |

> The wildcard `*.torrust-demo.com` catches any other subdomains (e.g. `www`).

## TXT Records

| Type | Hostname                   | Value                         | TTL  |
| ---- | -------------------------- | ----------------------------- | ---- |
| TXT  | `tracker.torrust-demo.com` | `BITTORRENT UDP:6969 TCP:443` | 3600 |

The TXT record on `tracker.torrust-demo.com` advertises the tracker's protocols and ports
for automatic discovery by BitTorrent clients.

## Subdomains Reference

| Subdomain                  | Purpose                         |
| -------------------------- | ------------------------------- |
| `index.torrust-demo.com`   | Torrust Index web UI and API    |
| `tracker.torrust-demo.com` | BitTorrent tracker (HTTP + UDP) |
| `grafana.torrust-demo.com` | Grafana monitoring dashboard    |
