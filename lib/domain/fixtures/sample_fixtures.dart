import 'package:calendar_notes/domain/models/field_value.dart';
import 'package:calendar_notes/domain/models/journal_entry.dart';
import 'package:calendar_notes/domain/models/template_definition.dart';

/// Non-personal, deterministic data used by smoke tests and future UI previews.
class SampleFixtures {
  SampleFixtures._();

  static final TemplateDefinition observationTemplate = TemplateDefinition(
    id: '2f1a5e04-0ed4-4b88-8a01-0f1e72a80001',
    versionId: '2f1a5e04-0ed4-4b88-8a01-0f1e72a80002',
    name: 'Obserwacja',
    fields: <FieldDefinition>[
      FieldDefinition(
        id: '2f1a5e04-0ed4-4b88-8a01-0f1e72a80003',
        key: 'samopoczucie',
        label: 'Samopoczucie',
        type: FieldType.select,
        sortOrder: 0,
        required: true,
        options: <FieldOption>[
          FieldOption(
            id: '2f1a5e04-0ed4-4b88-8a01-0f1e72a80004',
            label: 'Dobrze',
            sortOrder: 0,
          ),
        ],
      ),
      FieldDefinition(
        id: '2f1a5e04-0ed4-4b88-8a01-0f1e72a80005',
        key: 'notatka',
        label: 'Notatka',
        type: FieldType.multiline,
        sortOrder: 1,
      ),
    ],
  );

  static final JournalEntry observationEntry = JournalEntry(
    id: '2f1a5e04-0ed4-4b88-8a01-0f1e72a80006',
    templateId: observationTemplate.id,
    templateVersionId: observationTemplate.versionId,
    localDate: '2026-11-23',
    createdAtUtc: DateTime.utc(2026, 11, 23, 8),
    updatedAtUtc: DateTime.utc(2026, 11, 23, 8),
    values: <String, FieldValue>{
      '2f1a5e04-0ed4-4b88-8a01-0f1e72a80003': const SelectFieldValue(
        '2f1a5e04-0ed4-4b88-8a01-0f1e72a80004',
      ),
    },
  );
}
