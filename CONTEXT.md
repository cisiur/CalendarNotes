# CalendarNotes — project context
Updated: 2026-11-23.
Current state: design documents and first Codex task prepared. App itself, Flutter platform scaffold, database, synchronization and CI are **not yet implemented**.
## Scope
Private personal journal: Android + Windows, reusable note templates, multiple entries per calendar day, date-based calendar/list, exports to external analytics. Offline-first and no server.
## Decisions
Flutter/Dart shared app, Riverpod for state, go_router navigation, Drift+SQLite for independent device-local database, append-only JSON event files exchanged in distinct synchronized folder; Syncthing preferred.
Templates and field definitions versioned; stable UUIDs. No silent overwrites in conflicts. Structured CSV/JSON export.
## Open investigation
Android Scoped Storage/SAF folder interoperability with chosen sync transport on real hardware; exact Flutter/package versions; optional OneDrive third-party sync adapter. Validate before claiming automatic synchronization.
## Next task
`tasks/CN-01_BOOTSTRAP.md`, then Android/Windows sync-folder proof-of-concept CN-02.
