import 'package:calendar_notes/core/ids/stable_id.dart';
import 'package:calendar_notes/domain/models/field_value.dart';

enum FieldType {
  text,
  multiline,
  integer,
  decimal,
  boolean,
  select,
  multiselect,
  date,
  time,
  timestamp,
  duration,
}

class FieldOption {
  FieldOption({required this.id, required this.label, required this.sortOrder})
      : assert(StableId.isValid(id));

  final String id;
  final String label;
  final int sortOrder;
  final bool archived = false;
}

class FieldDefinition {
  FieldDefinition({
    required this.id,
    required this.key,
    required this.label,
    required this.type,
    required this.sortOrder,
    this.required = false,
    this.defaultValue,
    Iterable<FieldOption> options = const <FieldOption>[],
  })  : assert(StableId.isValid(id)),
        options = List<FieldOption>.unmodifiable(options);

  final String id;
  final String key;
  final String label;
  final FieldType type;
  final int sortOrder;
  final bool required;
  final FieldValue? defaultValue;
  final List<FieldOption> options;
}

class TemplateDefinition {
  TemplateDefinition({
    required this.id,
    required this.versionId,
    required this.name,
    Iterable<FieldDefinition> fields = const <FieldDefinition>[],
    this.archived = false,
  })  : assert(StableId.isValid(id)),
        assert(StableId.isValid(versionId)),
        fields = List<FieldDefinition>.unmodifiable(fields);

  final String id;
  final String versionId;
  final String name;
  final bool archived;
  final List<FieldDefinition> fields;
}
