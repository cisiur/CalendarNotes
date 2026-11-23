# CalendarNotes — project context
Updated: 2026-11-23.
Current state: CN-01 Flutter scaffold is implemented: Android application ID
`dev.cisiur.calendarnotes`, native Windows runner, Polish adaptive shell,
universal typed domain types, smoke tests and GitHub Actions analysis/test CI.
Database, synchronization, exports and journal CRUD are **not implemented**.
## Scope
Private personal journal: Android + Windows, reusable note templates, multiple entries per calendar day, date-based calendar/list, exports to external analytics. Offline-first and no server.
## Decisions
Flutter/Dart shared app, Riverpod for state, go_router navigation, Drift+SQLite for independent device-local database, append-only JSON event files exchanged in distinct synchronized folder; Syncthing preferred.
Templates and field definitions versioned; stable UUIDs. No silent overwrites in conflicts. Structured CSV/JSON export.
## Open investigation
Android Scoped Storage/SAF folder interoperability with chosen sync transport on real hardware; exact Flutter/package versions; optional OneDrive third-party sync adapter. Validate before claiming automatic synchronization.
## Next task
`tasks/CN-02_SYNC_FOLDER_POC.md` (when supplied): Android/Windows exchange-folder
and SAF proof of concept. The CN-01 environment did not contain Flutter/Dart,
so local analysis, tests and platform smoke tests still need execution on the
pinned toolchain.
