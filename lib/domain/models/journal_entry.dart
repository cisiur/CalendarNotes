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
        assert(createdAtUtc.isUtc),
        assert(updatedAtUtc.isUtc),
        values = Map<String, FieldValue>.unmodifiable(values) {
    if (!isValidLocalDate(localDate)) {
      throw ArgumentError.value(
        localDate,
        'localDate',
        'Musi być istniejącą datą w formacie YYYY-MM-DD.',
      );
    }
  }

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

  static bool isValidLocalDate(String value) {
    final RegExpMatch? match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) {
      return false;
    }
    final int year = int.parse(match.group(1)!);
    final int month = int.parse(match.group(2)!);
    final int day = int.parse(match.group(3)!);
    if (month < 1 || month > 12 || day < 1 || day > 31) {
      return false;
    }
    final DateTime normalized = DateTime.utc(year, month, day);
    return normalized.year == year && normalized.month == month && normalized.day == day;
  }
}
