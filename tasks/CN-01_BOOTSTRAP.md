# CN-01 — Bootstrap Flutter app (E0)
Status: READY, implementation not started.

## Repository
`cisiur/CalendarNotes`, work on `main`. Before changes fetch, check clean worktree, log starting HEAD; compare to baseline SHA if supplied. Do not rewrite history.
## Read
`AGENTS.md`, `CONTEXT.md`, docs `01`, `02`, `03` (mandatory safety), `04`, `07`.
## Implementation
1. Generate Flutter stable app `calendar_notes`, Android application ID `dev.cisiur.calendarnotes` and native Windows target. Pin compatible versions in pubspec.lock; record toolchain.
2. Set up adaptive app shell in Polish with working routes for Kalendarz, Wpisy, Szablony, Ustawienia. Bottom navigation Android and navigation rail Windows; placeholder pages clearly marked.
3. Create domain types `TemplateDefinition`, `FieldDefinition`, `FieldOption`, `JournalEntry` and typed `FieldValue` and validation; stable UUID identities. No hard-coded bedtime logic.
4. Create architectural folder layout in docs/02, simple dependency boundaries, fabricated sample fixtures; include unit and widget smoke tests.
5. Add simple GitHub Actions analysis/test CI, update README with exact Flutter commands, update CONTEXT/roadmap after implementation.
6. Do not create a backend, production DB, real sync, exports or charts in this task.
## Acceptance
`flutter analyze` and `flutter test` pass when toolchain available. Shell routes render and change; domain supports arbitrary field definitions. Windows and Android smoke tests if environment permits; otherwise explicitly not tested. No personal data committed.
## Completion
Report initial HEAD, tests, versions, files changed, final pushed commit SHA, origin/main match and clean worktree. Recommend CN-02.
