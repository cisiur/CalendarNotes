# 08 — Architecture decision records
## ADR-001 Flutter/Dart for Windows and Android — Accepted 2026-11-23
One native cross-platform UI and domain codebase; tradeoff is Windows/Android build toolchain.
## ADR-002 Independent SQLite plus immutable JSON file exchange — Accepted 2026-11-23
Reject direct OneDrive/Syncthing synchronization of the live SQLite file due to locking, WAL and concurrent offline writes. Requires local outbox, event importer and conflict detection, but protects against loss and supports true offline use.
## ADR-003 Analytics-friendly typed and normalized exports — Accepted 2026-11-23
Stable field/option IDs and template versions are first-class data, rather than only free text. CSV/JSON exported with documented schema for BI.
## ADR-004 Syncthing preferred, OneDrive conditional — Provisional 2026-11-23
Android OneDrive is not guaranteed to mirror a writable directory. Explicit provider feasibility check in CN-02.
