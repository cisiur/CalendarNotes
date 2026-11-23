# 05 — Export and analytical model
## Principles
Stable IDs and typed fields must survive export; do not only export user-facing strings or JSON blobs. Exports selected by date range and templates, with deleted items optionally included. CSV in UTF-8, ISO-8601 dates/timestamps, invariant decimals.
## Normalized CSV ZIP
- templates.csv: template_id, stable_key, name, archived
- template_fields.csv: field_id, template_id, stable_key, label, value_type
- field_options.csv: option_id, field_id, stable_key, label
- entries.csv: entry_id, template_id, template_version_id, local_date, title, notes, created_utc, updated_utc, deleted_utc
- entry_values.csv: entry_id, field_id, value_type, text_value, integer_value, decimal_value, boolean_value, date_value, time_value, instant_value, duration_seconds, option_id
- entry_multi_options.csv: entry_id, field_id, option_id
- manifest.json: export/schema versions, UTC export time, filters, row counts, value semantics
Nullable unset values stay empty, not zero; multi-select option assignments remain separate. Export both IDs and human-friendly dimension labels. CSV escaping per RFC 4180. Protect spreadsheet opening from formula injection and document any escaping policy; JSON retains exact raw values.
## JSON
Canonical versioned export with templates, immutable versions, options, entries and typed values; do not equate export with implemented restore capability.
## Power BI example
Join `entries.entry_id = entry_values.entry_id` and `entry_values.option_id = field_options.option_id`, filter template/field stable IDs, group local_date by month/year and count entries. Use a proper date dimension for calendar reporting. For option label history join version-specific definition snapshots.
## Future
Built-in statistics, saved aggregations, Power BI report template, incremental export.
