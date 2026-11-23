import 'package:calendar_notes/domain/models/field_value.dart';
import 'package:calendar_notes/domain/models/template_definition.dart';

class TemplateValidator {
  const TemplateValidator._();

  static List<String> validateDefinition(TemplateDefinition template) {
    final List<String> errors = <String>[];
    if (template.name.trim().isEmpty) {
      errors.add('Nazwa szablonu jest wymagana.');
    }

    final Set<String> fieldIds = <String>{};
    final Set<String> keys = <String>{};
    for (final FieldDefinition field in template.fields) {
      if (!fieldIds.add(field.id)) {
        errors.add('Id pola ${field.id} nie jest unikalne.');
      }
      if (field.key.trim().isEmpty || !keys.add(field.key)) {
        errors.add('Klucz pola musi być niepusty i unikalny.');
      }
      if (field.label.trim().isEmpty) {
        errors.add('Etykieta pola ${field.key} jest wymagana.');
      }
      final Set<String> optionIds = <String>{};
      for (final FieldOption option in field.options) {
        if (!optionIds.add(option.id)) {
          errors.add('Opcje pola ${field.key} muszą mieć unikalne ID.');
        }
      }
      if (_requiresOptions(field.type) && field.options.isEmpty) {
        errors.add('Pole ${field.key} wymaga co najmniej jednej opcji.');
      }
      if (field.defaultValue != null &&
          !isValueCompatible(field.type, field.defaultValue!)) {
        errors.add('Domyślna wartość pola ${field.key} ma niewłaściwy typ.');
      }
    }
    return errors;
  }

  static List<String> validateEntryValues({
    required TemplateDefinition template,
    required Map<String, FieldValue> values,
  }) {
    final List<String> errors = <String>[];
    final Map<String, FieldDefinition> fields = <String, FieldDefinition>{
      for (final FieldDefinition field in template.fields) field.id: field,
    };
    for (final String fieldId in values.keys) {
      if (!fields.containsKey(fieldId)) {
        errors.add('Wpis zawiera nieznane pole $fieldId.');
      }
    }
    for (final FieldDefinition field in template.fields) {
      final FieldValue? value = values[field.id];
      if (field.required && value == null) {
        errors.add('Pole ${field.label} jest wymagane.');
      } else if (value != null && !isValueCompatible(field.type, value)) {
        errors.add('Pole ${field.label} ma niewłaściwy typ wartości.');
      }
    }
    return errors;
  }

  static bool isValueCompatible(FieldType type, FieldValue value) {
    return switch (type) {
      FieldType.text || FieldType.multiline => value is TextFieldValue,
      FieldType.integer => value is IntegerFieldValue,
      FieldType.decimal => value is DecimalFieldValue,
      FieldType.boolean => value is BooleanFieldValue,
      FieldType.select => value is SelectFieldValue,
      FieldType.multiselect => value is MultiSelectFieldValue,
      FieldType.date => value is DateFieldValue,
      FieldType.time => value is TimeFieldValue,
      FieldType.timestamp => value is TimestampFieldValue,
      FieldType.duration => value is DurationFieldValue,
    };
  }

  static bool _requiresOptions(FieldType type) =>
      type == FieldType.select || type == FieldType.multiselect;
}
