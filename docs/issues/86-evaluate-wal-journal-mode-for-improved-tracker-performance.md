# Issue #86: Evaluate WAL Journal Mode for Improved Tracker Performance

**Issue**: <https://github.com/torrust/torrust-demo/issues/86>  
**Branch**: `86-evaluate-wal-journal-mode-for-improved-tracker-performance`  
**Status**: In Progress - Phase 2

## Objective

Evaluate whether switching SQLite from `delete` journal mode to `wal` (Write-Ahead Logging) mode improves tracker performance under high-traffic production load.

## Traffic Profile

- **~8,000-17,000 UDP requests per second** continuously
- **17 GB database**
- **No low-traffic periods** - constant 24/7 traffic

## Experiment Timeline

### Phase 1: Baseline Metrics (COMPLETED)

**Date**: January 13-28, 2026 (15 days)  
**Journal Mode**: DELETE  
**Status**: ✅ Complete

**Results**:

- **UDP4 Announces per second**: ~2,400-3,200 req/sec (average ~2,500 req/sec)
- **UDP Average Announce Processing Time**: Consistently **23.6 µs** (microseconds)
- Very stable performance with no variance

**Data Collected**:

- `data/grafana/phase1-delete-mode-2026-01-13-to-2026-01-28-udp4-announces-per-sec.csv`
- `data/grafana/phase1-delete-mode-2026-01-13-to-2026-01-28-udp4-avg-announce-time.csv`

### Phase 2: Switch to WAL Mode (COMPLETED)

**Date**: January 28, 2026, 13:16 UTC  
**Target Journal Mode**: WAL  
**Status**: ✅ Complete

**Commands to Execute**:

```bash
# 1. Stop the tracker
ssh torrust@139.59.150.216
cd /home/torrust/github/torrust/torrust-demo
docker compose stop tracker

# 2. Verify current journal mode
sqlite3 storage/tracker/lib/database/sqlite3.db "PRAGMA journal_mode;"
# Expected output: delete

# 3. Switch to WAL mode
sqlite3 storage/tracker/lib/database/sqlite3.db "PRAGMA journal_mode=WAL;"
# Expected output: wal

# 4. Verify the change persisted
sqlite3 storage/tracker/lib/database/sqlite3.db "PRAGMA journal_mode;"
# Expected output: wal

# 5. Check for WAL files
ls -lh storage/tracker/lib/database/
# Should see: sqlite3.db, sqlite3.db-wal, sqlite3.db-shm

# 6. Restart tracker
docker compose start tracker

# 7. Verify tracker is running
docker compose logs -f tracker | head -n50

# 8. Run smoke tests
./share/bin/tracker-filtered-logs.sh
```

**Execution Log**:

**Date**: January 28, 2026, 13:16 UTC  
**Executed by**: Production deployment

1. ✅ Stopped tracker container
2. ✅ Verified current journal mode: `delete`
3. ✅ Switched to WAL mode: `PRAGMA journal_mode=WAL;`
4. ✅ Verified change persisted: `wal`
5. ✅ Started tracker container
6. ✅ Verified WAL files created:
   - `sqlite3.db` (17 GB)
   - `sqlite3.db-shm` (32K)
   - `sqlite3.db-wal` (0 bytes initially)
7. ✅ Tracker logs show normal operation (processing requests)
8. ✅ Health check passed: `{"status":"Ok"}`

**Downtime**: ~60 seconds (tracker stop to start)

**Current Status**: Tracker running in WAL mode, processing ~2,500 requests/sec

### Phase 3: Collect Comparison Metrics (SCHEDULED)

**Start Date**: February 4, 2026 (7 days after switch)  
**End Date**: February 19, 2026 (15 days of data)  
**Status**: ⏳ Scheduled

**Metrics to Collect**:

- UDP4 Announces per second (same as Phase 1)
- UDP Average Announce Processing Time (same as Phase 1)

**Expected Filenames**:

- `data/grafana/phase3-wal-mode-2026-02-04-to-2026-02-19-udp4-announces-per-sec.csv`
- `data/grafana/phase3-wal-mode-2026-02-04-to-2026-02-19-udp4-avg-announce-time.csv`

### Phase 4: Analysis & Decision (SCHEDULED)

**Date**: February 19, 2026  
**Status**: ⏳ Scheduled

**Analysis Tasks**:

- [ ] Compare average processing time (DELETE vs WAL)
- [ ] Compare throughput (requests per second)
- [ ] Analyze WAL file growth patterns
- [ ] Check for checkpoint starvation issues
- [ ] Evaluate system resource usage differences
- [ ] Document any unexpected behavior

**Decision Criteria**:

- If performance improves: Keep WAL mode ✅
- If no significant change: Keep WAL mode (still safer for concurrent access) ✅
- If issues arise: Revert to DELETE mode ❌

## Monitoring Points

**During WAL Mode Operation**:

- Watch for WAL file size growth: `ls -lh storage/tracker/lib/database/sqlite3.db*`
- Monitor Grafana dashboards: <http://grafana.torrust-demo.com>
- Check for errors: `docker compose logs -f tracker | grep -i error`
- Verify checkpoint operations are occurring

**Rollback Plan** (if needed):

```bash
# Stop tracker
docker compose stop tracker

# Switch back to DELETE mode
sqlite3 storage/tracker/lib/database/sqlite3.db "PRAGMA journal_mode=DELETE;"

# Restart tracker
docker compose start tracker
```

## References

- Issue: <https://github.com/torrust/torrust-demo/issues/86>
- Prerequisite: <https://github.com/torrust/torrust-demo/issues/85> (SQLite `.backup` command)
- Research: <https://github.com/torrust/torrust-tracker-deployer/issues/310>
- [SQLite WAL Mode Documentation](https://www.sqlite.org/wal.html)
- [SQLite Backup API](https://www.sqlite.org/backup.html)
