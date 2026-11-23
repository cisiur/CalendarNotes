# CN-02 — Cross-platform exchange folder feasibility spike

Status: READY. Epic E0. Approved starting baseline: `1797f7e4322c68408838468588936fc4eb083eea`.

## Objective

Demonstrate a **real, safe, user-selected exchange directory** accessible from Windows and Android (prefer Syncthing-Fork). This is an engineering feasibility task, not the final sync engine. No SQLite DB, journal CRUD or production event protocol in this task.

## Required reading

`AGENTS.md`, `CONTEXT.md`, `docs/02_ARCHITECTURE.md`, `docs/03_DATA_AND_SYNC.md`, `docs/06_TESTING_AND_RECOVERY.md`, `docs/07_ROADMAP.md`, `docs/09_TOOLCHAIN.md`. Inspect existing Flutter app and tests. Check actual `origin/main` HEAD equals approved baseline and worktree is clean before changes; stop on mismatch.

## Gate 0 — verify CN-01 toolchain

1. Install/use documented Flutter 3.29.3 / Dart 3.7.2 if possible; `flutter doctor -v`, `flutter pub get`, `flutter analyze`, `flutter test`. Commit `pubspec.lock` for application reproducibility. Fix only baseline compile/test issues required for CN-02, reporting them separately.
2. Record Android SDK/JDK and Windows Visual Studio C++ availability; run platform smoke tests if supported. Do not claim tests passed if unavailable.
3. If toolchain unavailable, implement only what can be meaningfully checked, explicitly mark the hardware feasibility gate BLOCKED and do not report CN-02 complete.

## Spike implementation

1. Define `ExchangeFolderAdapter` interface independent of UI and sync engine, with capabilities (read, list, create-if-absent, write-once, read/verify, delete test-only file, access check, diagnostic errors). Ensure test files cannot overwrite existing objects.
2. Windows implementation uses user-selected regular filesystem directory. Validate read/write and permission-denied scenarios; avoid hard-coded paths.
3. Android implementation uses Android Storage Access Framework `ACTION_OPEN_DOCUMENT_TREE` and persisted URI permissions. Prefer a narrow Kotlin platform channel / native Android DocumentsContract implementation if Flutter file-picker plugins cannot guarantee directory writes. Never convert a `content://` URI into a filesystem path or require `MANAGE_EXTERNAL_STORAGE`. Persist/reopen selected tree URI across app restarts. Respect Android tree restrictions.
4. Provide a clearly labeled **developer-only diagnostic screen** (Settings entry) to choose folder, show provider/capabilities, create a unique non-personal test payload, list/read/verify SHA-256, re-open after restart, and remove **only this device's own test artifacts** after explicit user action. Do not delete any unrelated user files.
5. Document whether safe atomic publication is supported. Test staging + rename where possible; do not assume SAF rename atomicity. For providers where this cannot be guaranteed, record concrete fallback proposal (content-length/hash validation and retry; no unverified partial file consumption).
6. Include an optional two-device test: Windows writes unique file, Syncthing-Fork transfers, Android reads and verifies; Android writes another, Windows verifies. Check offline/online retry and app restart. If hardware or Syncthing is unavailable, leave a reproducible manual test checklist and status `NOT VERIFIED`; do not invent success.
7. Add deterministic unit tests using temporary directory fake adapter for write-once, duplicate path, malformed/truncated payload, permission error, retries, read/list and hash verification. Platform adapter tests when platform runners are available.
8. Update `docs/10_SYNC_FOLDER_FEASIBILITY.md` with observed devices/Android versions/provider URI types, permissions, test commands/results, known issues, explicit GO/NO-GO for Syncthing folder, and separate OneDrive assessment. Update `CONTEXT.md`, roadmap and README.

## Non-goals

No direct sync of live SQLite; no event envelopes/outbox/merge engine (CN-03/04), no full background sync (CN-08), no credentials or Graph API integration, no broad-storage permissions, no template or entry CRUD, no user content in diagnostics.

## Acceptance criteria

- Windows user-selected directory and Android SAF tree URI supported by appropriate platform adapters.
- User choice persists across app restart; access revocation reported clearly.
- Write-once, read/list, SHA-256 verification and safe test-file cleanup work; no overwrites.
- Evidence for two-device Syncthing interoperability collected on real devices OR clearly flagged as blocked, not presumed.
- Document provider atomicity limitations and validated fallback, including incomplete transfers.
- Flutter analyze/test and platform checks reported truthfully; baseline toolchain issue addressed or explicitly blocked.
- `pubspec.lock` committed once resolved, no personal data, no unauthorized permissions.
- Commit/push to `origin/main` and clean worktree; report final SHA.

## Codex final report

Starting HEAD and baseline match; Flutter/Android/Windows versions; files changed; automated test results; device/provider manual test evidence; Syncthing GO/NO-GO/UNVERIFIED; remaining blockers; final SHA, pushed HEAD, clean tree; recommendation for CN-03.
