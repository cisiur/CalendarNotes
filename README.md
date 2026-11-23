# CalendarNotes
Offline-first personal calendar and structured journal for Android and Windows, using one Flutter application.

**Project status:** CN-01 bootstrap complete. The adaptive shell and universal
domain model are present; persistence, synchronization, exports and journal UI
remain deliberately out of scope until later tasks.

## Capabilities planned
- Date-based entries in calendar and list; multiple entries per day.
- User-defined note templates and typed fields, without hard-coded childcare use cases.
- Offline operation on each device.
- Separate device-local SQLite databases and an immutable JSON-file exchange folder synchronized externally (Syncthing preferred).
- Typed JSON and CSV exports for analysis in Power BI, Excel, SQL or Python.
- No backend, accounts or paid services, personal use only.

**Safety:** Do not synchronize a live SQLite database file. Cloud file tools cannot coordinate SQLite transactions. Each device needs its own SQLite database; files in a separate exchange folder carry changes.

## Documents
- [Product requirements](docs/01_PRODUCT_REQUIREMENTS.md)
- [Architecture](docs/02_ARCHITECTURE.md)
- [Data and synchronization contract](docs/03_DATA_AND_SYNC.md)
- [User experience](docs/04_UX_SPEC.md)
- [Export for analytics](docs/05_EXPORT_ANALYTICS.md)
- [Testing and recovery](docs/06_TESTING_AND_RECOVERY.md)
- [Development roadmap](docs/07_ROADMAP.md)
- [Architecture decisions](docs/08_ADR.md)
- [Codex task CN-01](tasks/CN-01_BOOTSTRAP.md)
- [Codex instructions](AGENTS.md)
- [Project state](CONTEXT.md)

## Development
Install Flutter 3.29.3 (Dart 3.7.2), Android SDK with JDK 17, and Visual Studio
with the **Desktop development with C++** workload. Then run:

```powershell
flutter doctor -v
flutter pub get
flutter analyze
flutter test
flutter run -d windows
flutter run -d <android-device-id>
```

The Android application ID is `dev.cisiur.calendarnotes`. Dependency versions
are explicitly declared in `pubspec.yaml`; run `flutter pub get` to create the
tool-resolved `pubspec.lock` on a machine with the pinned SDK.

The shell uses bottom navigation on narrow displays and a navigation rail from
700 logical pixels. Its four Polish destinations are Kalendarz, Wpisy,
Szablony and Ustawienia. They are intentional placeholders, not journal CRUD.

## Exchange-folder diagnostic (CN-02)

**Ustawienia** contains a developer-only diagnostic for a separately selected
exchange folder. Windows uses a normal user-selected directory; Android uses
the system SAF document-tree picker and stores only its persisted `content://`
URI. It can create a unique non-personal test payload, list/read/verify its
SHA-256, reopen the selection after restart and explicitly remove only its own
test files. It is not synchronization and never selects or copies a database.

See [exchange-folder feasibility evidence and the required device checklist](docs/10_SYNC_FOLDER_FEASIBILITY.md).

Never commit private notes, synchronized event payloads or a database into source control.
