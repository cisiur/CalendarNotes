# 02 — Architecture
## Tech
Flutter and Dart stable for native Android APK and Windows executable; Riverpod providers, go_router routing, Drift+SQLite repositories and migrations, json_serializable/freezed for events where useful; path_provider and platform file-system adapter, intl for localization, UUID for identities. Resolve and pin compatible versions in CN-01.
## Layers
```
UI: calendar / entry list / template builder / entry editor / settings
         |
Riverpod controllers / application commands
         |
Domain models + validators + conflict resolution contracts
         |
Repositories | Local DB + durable outbox | Export service
         |                 |
 Drift SQLite         Sync file adapters
                            |
                Syncthing / file transport
```
## Planned folders
```text
lib/app/
lib/core/
lib/domain/
lib/data/local/
lib/data/sync/
lib/features/calendar/
lib/features/entries/
lib/features/templates/
lib/features/export/
lib/features/settings/
test/
integration_test/
docs/
tasks/
```
## Storage
Each device stores its DB under private persistent application data; binaries installed elsewhere. Exchange directory user-selected separately; never put SQLite files under a synchronized folder. Export and backup directories independent of both.
Android SAF URI grants and atomic file publication may be provider-dependent; prototype in CN-02, never assume ordinary file paths. Windows uses regular filesystem. App must remain fully functional while transport disconnected.
## Calendar semantics
Record local calendar date separately (YYYY-MM-DD). Record UTC instants separately where applicable; single clock times HH:mm:ss without timezone. Respect timezone/DST differences. Keep records identified by stable random IDs, not dates or user-facing labels.
