import 'package:calendar_notes/domain/fixtures/sample_fixtures.dart';
import 'package:calendar_notes/domain/models/field_value.dart';
import 'package:calendar_notes/domain/models/template_definition.dart';
import 'package:calendar_notes/domain/validation/template_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TemplateValidator', () {
    test('accepts the universal sample template and typed values', () {
      final TemplateDefinition template = SampleFixtures.observationTemplate;

      expect(TemplateValidator.validateDefinition(template), isEmpty);
      expect(
        TemplateValidator.validateEntryValues(
          template: template,
          values: SampleFixtures.observationEntry.values,
        ),
        isEmpty,
      );
    });

    test('rejects required fields, duplicate keys and mismatched values', () {
      final TemplateDefinition invalid = TemplateDefinition(
        id: '9e75499e-3894-4174-9fe7-c8dd487e4911',
        versionId: '9e75499e-3894-4174-9fe7-c8dd487e4912',
        name: 'Kontrola',
        fields: <FieldDefinition>[
          FieldDefinition(
            id: '9e75499e-3894-4174-9fe7-c8dd487e4913',
            key: 'wartosc',
            label: 'Wartość',
            type: FieldType.integer,
            sortOrder: 0,
            required: true,
          ),
          FieldDefinition(
            id: '9e75499e-3894-4174-9fe7-c8dd487e4914',
            key: 'wartosc',
            label: 'Druga wartość',
            type: FieldType.text,
            sortOrder: 1,
          ),
        ],
      );

      expect(TemplateValidator.validateDefinition(invalid), isNotEmpty);
      expect(
        TemplateValidator.validateEntryValues(
          template: invalid,
          values: <String, FieldValue>{
            invalid.fields.first.id: const TextFieldValue('nie liczba'),
          },
        ),
        hasLength(1),
      );
    });
  });
}
