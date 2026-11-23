# 07 — Roadmap
Codex tasks are scoped and sequential; each task reports HEAD/baseline/tests/final SHA and updates context.
## E0 Foundation
- **CN-01 [NEXT]** Flutter bootstrap + Android/Windows shells, navigation, domain skeleton, tests, basic CI. See `tasks/CN-01_BOOTSTRAP.md`.
- CN-02 Windows and real Android exchange-folder/SAF proof of concept, Syncthing-Fork interoperability and fallback.
- CN-03 Drift SQLite data schema/migrations and transactional outbox.
- CN-04 Event envelope, importer, parent-revision concurrency/conflict engine and integration tests.
## E1 Journal core
- CN-05 Universal versioned template editor + field types/choices.
- CN-06 Entry CRUD, typed editor, validation, tombstones.
- CN-07 Calendar month and dated list/filter UI.
## E2 Reliability/sync
- CN-08 Exchange adapter, sync status/conflict resolution UI, cross-device tests.
- CN-09 Recovery/backup and fault-injection suite.
## E3 Analytics
- CN-10 JSON/normalized CSV exports, Power BI import guide.
- CN-11 Basic optional in-app monthly/yearly statistics.
## E4 Packaging
- CN-12 Android APK + Windows portable/installer and Polish UI/accessibility polish.
MVP exit: all basic daily note features work offline and sync without silent loss; CSV usable externally.
