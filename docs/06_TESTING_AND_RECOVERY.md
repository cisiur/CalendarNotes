# 06 — Test plan
- Domain: stable IDs, validation for each field type, versioned template changes, two entries on one date, soft deletion.
- DB: migrations, transaction consistency, outbox recovery after crashes.
- Sync: repeated event idempotence, changed payload with duplicate ID rejection, out-of-order sequences, missing dependencies, independent-device convergence, same-aggregate concurrent edit/edit and edit/delete conflicts, malformed/truncated files, interrupted publication.
- Export: CSV RFC quoting, Polish characters, multi-select, null vs zero, decimal/date encoding, formula-looking text and stable joining in Power BI.
- Platform: Windows build/smoke; Android APK, selected SAF folder permissions after restart, Syncthing folder interoperability.
- UI: navigation, calendar/list, dynamic template fields, unsaved-change guard.
## Recovery
Separate dated, verified DB backups created via SQLite backup API or VACUUM INTO with controlled active connection. Include unsent outbox. Keep event exchange immutable, expose sync errors without private note data in logs. Backup restore must be tested in temporary storage before replacement.
## CI
On CN-01, lint/test workflow; builds on platform runners when compatible; no release publishing or distribution.
