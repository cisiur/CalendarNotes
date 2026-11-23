# CalendarNotes — project context
Updated: 2026-11-23.
Current state: CN-02 adds a developer-only exchange-folder diagnostic: a
Windows user-selected directory adapter and Android SAF tree-URI adapter,
write-once test artifacts, SHA-256 verification and own-artifact cleanup.
It does not implement SQLite, event synchronization, exports or journal CRUD.
## Scope
Private personal journal: Android + Windows, reusable note templates, multiple entries per calendar day, date-based calendar/list, exports to external analytics. Offline-first and no server.
## Decisions
Flutter/Dart shared app, Riverpod for state, go_router navigation, Drift+SQLite for independent device-local database, append-only JSON event files exchanged in distinct synchronized folder; Syncthing preferred.
Templates and field definitions versioned; stable UUIDs. No silent overwrites in conflicts. Structured CSV/JSON export.
## Open investigation
Android Scoped Storage/SAF folder interoperability with Syncthing-Fork on real
hardware, atomic publication behavior, exact Flutter/package resolution and
optional OneDrive third-party adapter. The Codex host has no Flutter/Dart,
Android device or Visual Studio C++ tools, so CN-02 hardware feasibility is
UNVERIFIED; see `docs/10_SYNC_FOLDER_FEASIBILITY.md`.
## Next task
Run the CN-02 manual Android/Windows/Syncthing checklist and record evidence
before approving CN-03 (Drift SQLite plus transactional outbox).
