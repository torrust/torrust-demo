#!/bin/bash

# Backup the Tracker SQLite database
#
# Uses SQLite's .backup command instead of cp to ensure backup consistency.
# The .backup command:
# - Guarantees consistency even with concurrent writes
# - Uses proper page-level locking
# - Handles WAL mode databases automatically
# - Automatically restarts if source is modified mid-backup
#
# See: https://www.sqlite.org/backup.html
#
# NOTE: This script is NOT scheduled in crontab due to the large database size (~17GB).
# The Tracker DB relies on Digital Ocean weekly droplet backups instead.
# This script is available for manual backups if needed.
# See: https://github.com/torrust/torrust-demo/issues/49

# Define the directory where backups will be stored
BACKUP_DIR="/home/torrust/backups"

# Define the SQLite database file's path
DATABASE_FILE="/home/torrust/github/torrust/torrust-demo/storage/tracker/lib/database/sqlite3.db"

# Create a timestamped backup filename
BACKUP_FILE="$BACKUP_DIR/tracker_backup_$(date +%Y-%m-%d_%H-%M-%S).db"

# Use SQLite's .backup command for consistent backup
sqlite3 "$DATABASE_FILE" ".backup '$BACKUP_FILE'"

# Find and remove backups older than 7 days
find "$BACKUP_DIR" -type f -name "tracker_backup_*.db" -mtime +7 -exec rm -f {} \;
