import 'package:calendar_notes/domain/models/journal_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  JournalEntry createEntry(String localDate) => JournalEntry(
        id: 'a1b2c3d4-e5f6-4789-8abc-def012345678',
        templateId: 'b1b2c3d4-e5f6-4789-8abc-def012345678',
        templateVersionId: 'c1b2c3d4-e5f6-4789-8abc-def012345678',
        localDate: localDate,
        createdAtUtc: DateTime.utc(2026, 1, 1),
        updatedAtUtc: DateTime.utc(2026, 1, 1),
      );

  test('accepts existing ISO local dates', () {
    expect(createEntry('2024-02-29').localDate, '2024-02-29');
    expect(JournalEntry.isValidLocalDate('2026-11-24'), isTrue);
  });

  test('rejects malformed and impossible local dates', () {
    for (final String value in <String>[
      '2026-2-03',
      '2026-02-3',
      '2026/02/03',
      '2026-02-29',
      '2024-02-30',
      '2026-13-01',
      '2026-00-01',
      '2026-04-31',
    ]) {
      expect(JournalEntry.isValidLocalDate(value), isFalse, reason: value);
      expect(() => createEntry(value), throwsArgumentError, reason: value);
    }
  });
}
