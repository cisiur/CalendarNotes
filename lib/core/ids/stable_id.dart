import 'package:uuid/uuid.dart';

/// Creates random, opaque identifiers. IDs are never derived from labels or dates.
class StableId {
  StableId._();

  static const Uuid _uuid = Uuid();

  static String newId() => _uuid.v4();

  static bool isValid(String value) => Uuid.isValidUUID(fromString: value);
}
