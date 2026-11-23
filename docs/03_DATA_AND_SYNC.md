# 03 — Storage and file sync protocol (draft v1)
## Fundamental rule
**No live SQLite .db/.sqlite/.db-wal/.db-shm inside OneDrive/Syncthing.** File-sync engines do not offer SQLite transactional locking or offline database merge semantics. Instead each device has independent SQLite + durable outbox and imports immutable JSON event objects exchanged through folder sync.
## Logical database
- devices(id PK, created_at_utc, label)
- templates(id PK, stable_key, name, archived, revision_id, created_at_utc, updated_at_utc)
- template_versions(template_id FK, version_id PK, definition_json, created_at_utc)
- fields(id PK, template_id FK, key, label, type, required, sort_order, metadata_json, archived)
- options(id PK, field_id FK, key, label, sort_order, archived)
- entries(id PK, template_id FK, template_version_id FK, local_date, title, notes, revision_id, deleted_at_utc NULL, created_at_utc, updated_at_utc)
- values(entry_id FK, field_id FK, typed value columns, option_id optional)
- multi_options(entry_id FK, field_id FK, option_id FK)
- outbox(event_id PK, device_id, local_seq, envelope_json, published_at_utc NULL)
- applied_events(event_id PK, payload_hash, device_id, local_seq, applied_at_utc)
- sync_inbox(event_id PK, state, last_error, envelope_json)
- conflicts(id PK, aggregate_id, branch_json, status)
- schema_meta(key PK, value)
Physical design may adapt but no semantic data loss.
## Wire format
```text
exchange/v1/devices/<device_uuid>/events/
  00000000000000000001_<event_uuid>.json
```
Envelope fields: protocol_version(1), event_id, device_id, sequence (monotonic per device), aggregate_type, aggregate_id, operation, parent_revision_ids, occurred_at_utc, payload_schema_version, payload, sha256 of canonical envelope fields excluding hash.
Rules:
- A local mutation and outbox insert share one SQLite transaction. Publishing occurs later; crash recovery retries safely.
- Immutable event files, unique filenames; never overwrite. Publish staged then atomic rename where filesystem supports it. Where SAF atomic rename cannot be guaranteed: validate complete length/hash on import and retry incomplete objects; final protocol adapter to be proven in CN-02.
- Validate schema/hash, IDs, event sizes, path traversal and sequence collisions. Import idempotently; track gaps, hold missing dependencies, quarantine invalid events. Never trust file timestamps or arrival order.
- Event revision parents encode causality. Independent edits merge automatically. Concurrent updates of same aggregate create a persistent conflict without discarding either revision. Delete/edit conflict as well. Explicit user merge emits new revision referencing every branch.
- Tombstone deletes; do not prune history or old exchange objects without explicit retention/peer-ack protocol.
- Device ID random, not tied to identity or account. No background server.
## Backups
Online SQLite backup or VACUUM INTO, preserving unsent outbox. Never casually copy an open DB. Synced exchange is not a substitute for backups.
## Providers
Syncthing (Android maintained fork) preferred. OneDrive Windows can mirror regular folders, but Android OneDrive client is not a generic continuously synced writable local folder. Third-party sync or native Graph integration might be needed later. CN-02 proves actual Android access and file publication.
