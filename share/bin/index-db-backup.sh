#!/bin/bash

# Backup the Index SQLite database
#
# Uses SQLite's .backup command instead of cp to ensure backup consistency.
# The .backup command:
# - Guarantees consistency even with concurrent writes
# - Uses proper page-level locking
# - Handles WAL mode databases automatically
# - Automatically restarts if source is modified mid-backup
#
# See: https://www.sqlite.org/backup.html

# Define the directory where backups will be stored
BACKUP_DIR="/home/torrust/backups"

# Define the SQLite database file's path
DATABASE_FILE="/home/torrust/github/torrust/torrust-demo/storage/index/lib/database/sqlite3.db"

# Create a timestamped backup filename
BACKUP_FILE="$BACKUP_DIR/backup_$(date +%Y-%m-%d_%H-%M-%S).db"

# Use SQLite's .backup command for consistent backup
sqlite3 "$DATABASE_FILE" ".backup '$BACKUP_FILE'"

# Find and remove backups older than 7 days
find "$BACKUP_DIR" -type f -name "backup_*.db" -mtime +7 -exec rm -f {} \;

