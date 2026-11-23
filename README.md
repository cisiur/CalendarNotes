# CalendarNotes
Offline-first personal calendar and structured journal for Android and Windows, using one Flutter application.

**Project status:** specification and development roadmap; application implementation begins with CN-01.

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
Install Flutter stable, Android SDK and Windows desktop tooling. Codex CN-01 will generate the actual scaffold and pin supported packages. Planned commands: `flutter doctor -v`, `flutter analyze`, `flutter test`, `flutter run -d windows` and `flutter run -d <device>`.

Never commit private notes, synchronized event payloads or a database into source control.
