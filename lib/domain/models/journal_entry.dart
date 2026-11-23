import 'package:calendar_notes/core/ids/stable_id.dart';
import 'package:calendar_notes/domain/models/field_value.dart';

class JournalEntry {
  JournalEntry({
    required this.id,
    required this.templateId,
    required this.templateVersionId,
    required this.localDate,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    Map<String, FieldValue> values = const <String, FieldValue>{},
    this.title,
    this.notes,
    this.deletedAtUtc,
  })  : assert(StableId.isValid(id)),
        assert(StableId.isValid(templateId)),
        assert(StableId.isValid(templateVersionId)),
        assert(_isIsoLocalDate(localDate)),
        assert(createdAtUtc.isUtc),
        assert(updatedAtUtc.isUtc),
        values = Map<String, FieldValue>.unmodifiable(values);

  final String id;
  final String templateId;
  final String templateVersionId;
  final String localDate;
  final String? title;
  final String? notes;
  final Map<String, FieldValue> values;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final DateTime? deletedAtUtc;

  static bool _isIsoLocalDate(String value) =>
      RegExp(r'^\\d{4}-\\d{2}-\\d{2}$').hasMatch(value);
}
