# 01 — Product requirements
## Goal
A reusable offline daily-journal app, not a dedicated bedtime tracker.
## MVP
- Android and Windows; single user; no accounts/server/distribution.
- Calendar view (month, entry counts per day, day detail), chronological list, template/date filters.
- Create/rename/archive templates with named fields, optional defaults, required flags and select options. Types: text, multiline, integer, decimal, boolean, select, multiselect, date, time, timestamp, duration.
- Add/edit/soft-delete multiple notes per date; optional title, free text.
- Preserve old entries and their field meaning after template edits.
- Offline device databases; reliable two-way sync of separate event files; warning on unresolved conflicts.
- CSV/JSON export of dates, typed field values, template/option dictionaries.
## Later
Built-in charts, dashboards, attachments, widgets, reminders, automatic analytics, web UI, custom expressions, optional encryption.
## Example
Template `Usypianie`: `parent` single select (ja/żona/razem), `sleep_time` time, `difficulty` single select, `comments` multiline. The same template machinery can track work, chores, exercise or any observation.
## Acceptance
Create an arbitrary template without coding; record two independent notes on one day; see both in calendar/list; safely synchronize Windows and Android without data loss; report monthly counts by select-option using Power BI.
