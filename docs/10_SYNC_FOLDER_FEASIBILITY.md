# 10 — Feasibility of the exchange folder (CN-02)

Status: **IMPLEMENTED, HARDWARE VERIFICATION BLOCKED** (2026-11-23).

## Scope and safety boundary

CN-02 provides a developer-only exchange-folder diagnostic. It is not a sync
engine: it creates no SQLite database, event, outbox, note, template or user
content. In particular, the app never places an open SQLite database (nor
`-wal`/`-shm` sidecars) in the selected directory.

The diagnostic writes a small JSON payload containing only a random nonce and
a UTC timestamp. Each filename starts with
`calendarnotes-diagnostic-<installation-uuid>-`; cleanup accepts only that
installation's prefix and always requires an explicit tap and confirmation.
It cannot remove an unrelated file.

## Implemented adapters

| Platform | Selection/persistence | Operations | Publication finding |
| --- | --- | --- | --- |
| Windows | `file_selector` directory chooser; path in app preferences | list, exclusive test write, read/SHA-256 verify, own-test cleanup | writes a staging file then same-directory rename; this is an implementation test, not a claim of verified atomic publication across filesystem/sync-provider combinations. |
| Android | Native `ACTION_OPEN_DOCUMENT_TREE`; URI permission via `takePersistableUriPermission`; URI in Android `SharedPreferences` | DocumentsContract list/create/read/SHA-256 verify/delete-own-test | SAF provider rename atomicity is **not assumed**; diagnostic creation is direct and is not a production publication protocol. |

The Android implementation never converts `content://` to a filesystem path,
does not request `MANAGE_EXTERNAL_STORAGE`, and detects a persisted-permission
revocation on reopening the app.

## Incomplete-transfer fallback

SAF exposes provider-dependent creation and rename semantics. Therefore CN-02
does not grant a production atomic-publication guarantee. CN-04 import must
only accept an immutable event after its declared content length and SHA-256
are fully readable and valid; an incomplete or mismatched object stays
unconsumed and is retried later. It must never be silently treated as a valid
event. CN-02's diagnostic read-after-write implements the hash part of that
check but is not the event protocol.

## Observed environment

- Codex host: Windows; `java`/`javac` available from Eclipse Adoptium JDK
  17.0.19; `ANDROID_HOME=D:\Android\Sdk`.
- Flutter 3.29.3/Dart 3.7.2: **not installed or on PATH**. Consequently
  `flutter pub get`, `flutter analyze`, `flutter test`, Windows build and APK
  build could not start; `pubspec.lock` could not be generated.
- Visual Studio C++ tools: not detected on PATH/environment.
- Android device, Android version, SAF provider URI, Syncthing-Fork and
  OneDrive: **not available to Codex; no observations were invented**.

## Manual hardware checklist (required before GO)

1. Install Flutter 3.29.3 and Dart 3.7.2; run `flutter doctor -v`, `flutter
   pub get`, `flutter analyze`, and `flutter test`. Commit the generated
   `pubspec.lock` only after reviewing it.
2. On Windows, run `flutter run -d windows`. In **Ustawienia**, choose a new,
   empty Syncthing folder (not an app-data or database folder). Create and
   verify a diagnostic file, restart the app, use **Sprawdź dostęp po
   restarcie**, verify it again, then explicitly delete it.
3. On an Android device, install/run the APK. In **Ustawienia**, choose the
   same logical Syncthing-Fork folder through the system document-tree picker.
   Record the Android version, provider authority/URI shown by the screen and
   whether persistent read/write access remains after an app force-stop.
4. Windows → Android: create a Windows diagnostic file, wait until
   Syncthing-Fork reports transfer, then list/read/verify it on Android. Do
   not delete it until the hash result is recorded.
5. Android → Windows: create an Android diagnostic file, wait for transfer,
   list/read/verify it on Windows, then remove both files only through each
   app's explicit own-artifact cleanup.
6. Repeat both directions while one device is offline, bring it online, and
   verify the unchanged bytes/hash. Test an interrupted transfer if the
   provider permits it: consumers must show a hash mismatch or retry rather
   than accept it.
7. Revoke Android's folder access in system settings, restart, and ensure the
   diagnostic reports access revocation instead of silently selecting another
   path. Do not grant broad storage access.
8. Repeat with OneDrive only if it exposes a real writable document tree on
   that Android device. Record the result separately; do not infer support
   merely from a Windows OneDrive folder.

## Decision

- Syncthing-Fork exchange folder: **UNVERIFIED / no GO decision yet**. The
  implementation is ready for the listed device evidence, which is a hard
  gate before relying on this transport in CN-03/CN-04.
- OneDrive Android folder: **NO GO pending direct provider evidence**. A
  Windows mirror does not establish Android writable-folder interoperability.
