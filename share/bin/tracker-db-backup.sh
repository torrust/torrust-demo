#!/bin/bash

# Backup the Tracker SQLite database
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

# Copy the SQLite database file to create a backup
cp $DATABASE_FILE "$BACKUP_FILE"

# Find and remove backups older than 7 days
find $BACKUP_DIR -type f -name "tracker_backup_*.db" -mtime +7 -exec rm -f {} \;
