# CalendarNotes — Codex instructions
## Work pattern
Follow the established single-epic-session, incremental-task workflow: PM/technical lead supplies task, approved baseline and documents. Work on `main` unless instructed otherwise. Fetch before changes; record branch/HEAD, check clean tree and compare approved SHA. On mismatch stop. Never force-push, amend or rewrite history. After implementation inspect diff, run available tests, commit, push and report exact result/limitations.
Epic bootstrap: `AGENTS.md`, `CONTEXT.md`, current epic in `docs/07_ROADMAP.md` and named design docs. Subsequent tasks: refresh HEAD and only relevant changed docs/code, rather than reloading all context.
## Nonnegotiable design
- Flutter/Dart targets Android and Windows.
- Installation files, private local SQLite database, and synchronized exchange files are physically distinct.
- **Never synchronize an open SQLite database or its WAL/SHM sidecars via Syncthing or OneDrive.**
- Local writes and durable sync outbox form one DB transaction; event files immutable and uniquely identified.
- Sync imports are validated, idempotent, handle gaps and conflicts without silent last-write-wins; preserve deleted-record tombstones.
- Templates are universal, versioned and use stable field/option IDs.
- Keep export values typed with ISO dates and stable identifiers for Power BI.
- No accounts, cloud backend, hard-coded secrets, telemetry or personal data in Git.
## Quality gates
Unit tests, migration tests, two-device sync convergence and conflict/crash tests as each feature arrives. Run `flutter analyze` and `flutter test` whenever Flutter scaffold exists; platform smoke tests when available. Never claim to have run unavailable tests. Update `CONTEXT.md`, README and roadmap when state changes.
## Completion report
Starting HEAD, baseline match, implementation summary, tests executed, final commit SHA, push status, clean worktree, risks and next task.
