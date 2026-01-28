# Issue #85: Use SQLite .backup command instead of cp for database backups

**Issue URL:** <https://github.com/torrust/torrust-demo/issues/85>

## Description

Replace the `cp` command in database backup scripts with SQLite's `.backup`
command to ensure backup consistency. The current implementation using `cp` has
a high risk of creating corrupted backups because:

- The tracker receives ~8,000-17,000 UDP requests/second continuously
- The database is ~17GB in size
- There are no low-traffic periods (24/7 high traffic)
- Probability of writes during `cp` operation is essentially 100%

The `.backup` command provides:

- Guaranteed consistency even with concurrent writes
- Proper locking mechanisms
- WAL mode support (produces single self-contained file)
- Automatic restart if source is modified mid-backup

## Questions for Implementation

### 1. Should we also apply the same fix to `index-db-backup.sh`?

The issue focuses on the tracker backup script, but the index backup script
likely has the same problem. Should I update both scripts in this PR?

**Files to check:**

- `share/bin/tracker-db-backup.sh` (mentioned in issue)
- `share/bin/index-db-backup.sh` (potentially same problem)

Yes, update both scripts. Although the implementation should be progressive. Fix
one first and them fix the other. Start with the index one because the DB is
smaller and easier to test.

### 2. Optional improvements - which ones should be included?

The issue mentions these optional enhancements:

- **Error handling:** Check if backup succeeded
- **Compression:** `gzip` or `zstd` to reduce storage
- **Verification:** `PRAGMA integrity_check` on backup file
- **Fix variable quoting:** Quote `$DATABASE_FILE` and `$BACKUP_DIR`
  throughout the script

Should I implement:

- [ ] Just the `.backup` command change (minimal change)
- [ ] Add error handling
- [ ] Add compression
- [ ] Add verification
- [ ] Fix variable quoting
- [ ] All of the above

I want the minimal change, but we can verify the other things manually.
We can also include the fix for the variable quoting as it is an easy fix that
improves script robustness.

### 3. Should I update documentation?

Which documentation files need to be updated?

- [ ] The backup scripts themselves (update comments)
- [ ] `docs/backups.md` (if it mentions the backup mechanism)
- [ ] `AGENTS.md` (if it references the backup mechanism)
- [ ] Other files?

Yes, any relevant documentation should be updated to reflect the new backup
method.

### 4. Testing approach on demo server

Once deployed to the demo server, what testing should be performed?

- [ ] Run the backup script manually
- [ ] Check that the backup file is created and has correct size
- [ ] Verify backup integrity: `sqlite3 backup.db "PRAGMA integrity_check"`
- [ ] Try to open backup with sqlite3 and run a simple query
- [ ] Compare backup file size with original database
- [ ] All of the above?

All of the above. Comprehensive testing will ensure the new backup method works
correctly. Verify first on the index DB as it is smaller and easier to handle.

### 5. Branch naming convention

What should the branch name be? Suggestions:

- `fix/issue-85-sqlite-backup-command`
- `85-use-sqlite-backup-command`
- `enhancement/sqlite-backup-command`

Follow Github branching conventions. Use `85-use-sqlite-backup-command-instead-of-cp-for-database-backups`.

## Implementation Plan

### Phase 1: Index Database Backup

1. Create git branch: `85-use-sqlite-backup-command-instead-of-cp-for-database-backups`
2. Update `share/bin/index-db-backup.sh`:
   - Replace `cp` with `sqlite3 .backup` command
   - Fix variable quoting (quote `$DATABASE_FILE` and `$BACKUP_DIR`)
   - Update comments to document the change
3. Test locally (if possible with local SQLite database)
4. Copy updated script to demo server
5. Run backup script manually on demo server
6. Verify backup:
   - Check file is created and has correct size
   - Run `sqlite3 backup.db "PRAGMA integrity_check"`
   - Open backup with sqlite3 and run a simple query
   - Compare backup file size with original database
7. Enable in production on server (if not already in crontab)
8. Commit changes:
   `git commit -m "feat: use sqlite .backup for index database backups"`

### Phase 2: Tracker Database Backup

1. Update `share/bin/tracker-db-backup.sh`:
   - Apply same changes as index script
   - Replace `cp` with `sqlite3 .backup` command
   - Fix variable quoting
   - Update comments
2. Copy to demo server (optional: may skip local/remote verification since
   script is identical to tested index version)
3. Test on demo server (optional)
4. Commit changes:
   `git commit -m "feat: use sqlite .backup for tracker database backups"`

### Phase 3: Documentation

1. Update documentation files:
   - `AGENTS.md` - Update backup mechanism description
   - `docs/backups.md` - Document new backup method
   - Update script comments as needed
2. Commit documentation changes:
   `git commit -m "docs: update backup documentation for sqlite .backup command"`

### Phase 4: Pull Request

1. Push branch to GitHub
2. Open PR for review
3. Address review comments if any
4. Merge to main after approval
