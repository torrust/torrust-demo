# Backups

## Backup Strategy

**Index Database (Automated)**:

- Hourly backups via cron job
- 7-day retention period
- Small database size (~2.3 MB)
- Location: `/home/torrust/backups`

**Tracker Database (Manual Only)**:

- NOT scheduled in cron due to large size (~17GB)
- Relies on Digital Ocean weekly droplet backups
- Manual backup script available if needed: `./share/bin/tracker-db-backup.sh`
- See [Issue #49](https://github.com/torrust/torrust-demo/issues/49) for details

## Backup Index Database

### Automated Backups

Index backups run automatically every hour via cron. See [crontab.conf](../share/container/default/config/crontab.conf).

### Manual Backup

```bash
cd /home/torrust/github/torrust/torrust-demo/
./share/bin/index-db-backup.sh
```

## Backup Tracker Database (Manual Only)

```bash
cd /home/torrust/github/torrust/torrust-demo/
./share/bin/tracker-db-backup.sh
```

**Note**: Due to the large size (~17GB), tracker backups are not automated. Use Digital Ocean droplet backups for regular snapshots.

## Check Backups Crontab Configuration

```bash
sudo crontab -e
```

You should see the [crontab.conf](../share/container/default/config/crontab.conf) configuration file.

## Check Backups

```bash
ls -alt /home/torrust/backups
total 26618268
-rwxr-x--- 1 root root 2342912 May 12 07:00 backup_2025-05-12_07-00-01.db
-rwxr-x--- 1 root root 2342912 May 12 06:00 backup_2025-05-12_06-00-02.db
-rwxr-x--- 1 root root 2342912 May 12 05:00 backup_2025-05-12_05-00-01.db
-rwxr-x--- 1 root root 2342912 May 12 04:00 backup_2025-05-12_04-00-01.db
```

You can also check the script output with:

```bash
tail /var/log/cron.log
```
