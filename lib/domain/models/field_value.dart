sealed class FieldValue {
  const FieldValue();
}

class TextFieldValue extends FieldValue {
  const TextFieldValue(this.value);

  final String value;
}

class IntegerFieldValue extends FieldValue {
  const IntegerFieldValue(this.value);

  final int value;
}

class DecimalFieldValue extends FieldValue {
  const DecimalFieldValue(this.value);

  final double value;
}

class BooleanFieldValue extends FieldValue {
  const BooleanFieldValue(this.value);

  final bool value;
}

class SelectFieldValue extends FieldValue {
  const SelectFieldValue(this.optionId);

  final String optionId;
}

class MultiSelectFieldValue extends FieldValue {
  MultiSelectFieldValue(Iterable<String> optionIds)
      : optionIds = List<String>.unmodifiable(optionIds);

  final List<String> optionIds;
}

/// A calendar date in ISO-8601 `YYYY-MM-DD` form, without a timezone.
class DateFieldValue extends FieldValue {
  const DateFieldValue(this.isoDate);

  final String isoDate;
}

/// A wall-clock time in `HH:mm:ss` form, without a timezone.
class TimeFieldValue extends FieldValue {
  const TimeFieldValue(this.isoTime);

  final String isoTime;
}

class TimestampFieldValue extends FieldValue {
  TimestampFieldValue(DateTime value) : value = value.toUtc();

  final DateTime value;
}

class DurationFieldValue extends FieldValue {
  const DurationFieldValue(this.value);

  final Duration value;
}
