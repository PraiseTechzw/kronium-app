import 'dart:math';

/// Simple ID generator for creating short, user-friendly IDs
/// Generates 4-character IDs using letters and numbers
class SimpleIdGenerator {
  // Characters to use for ID generation (letters and numbers only)
  static const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  // Exclude confusing characters (0, O, 1, I, L)
  static const String _safeChars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

  static final Random _random = Random();

  /// Generates a simple 4-character ID using letters and numbers
  /// Format: XXXX (e.g., A3B7, K9M2, etc.)
  static String generateSimpleId() {
    final buffer = StringBuffer();

    for (int i = 0; i < 4; i++) {
      buffer.write(_safeChars[_random.nextInt(_safeChars.length)]);
    }

    return buffer.toString();
  }

  /// Generates a simple ID with a specific prefix
  /// Format: PREFIX-XXXX (e.g., USER-A3B7, PROJ-K9M2, etc.)
  static String generatePrefixedId(String prefix) {
    return '$prefix-${generateSimpleId()}';
  }

  /// Generates multiple unique IDs
  static List<String> generateMultipleIds(int count) {
    final Set<String> ids = <String>{};

    while (ids.length < count) {
      ids.add(generateSimpleId());
    }

    return ids.toList();
  }

  /// Generates a simple ID with custom length
  static String generateCustomLengthId(int length) {
    if (length < 2 || length > 8) {
      throw ArgumentError('Length must be between 2 and 8 characters');
    }

    final buffer = StringBuffer();

    for (int i = 0; i < length; i++) {
      buffer.write(_safeChars[_random.nextInt(_safeChars.length)]);
    }

    return buffer.toString();
  }

  /// Validates if a string is a valid simple ID format
  static bool isValidSimpleId(String id) {
    if (id.length != 4) return false;

    for (int i = 0; i < id.length; i++) {
      if (!_safeChars.contains(id[i].toUpperCase())) {
        return false;
      }
    }

    return true;
  }

  /// Generates a simple ID for different entity types
  static String generateEntityId(String entityType) {
    switch (entityType.toLowerCase()) {
      case 'user':
        return generatePrefixedId('USR');
      case 'project':
        return generatePrefixedId('PRJ');
      case 'service':
        return generatePrefixedId('SRV');
      case 'booking':
        return generatePrefixedId('BKG');
      case 'admin':
        return generatePrefixedId('ADM');
      default:
        return generateSimpleId();
    }
  }
}

/// Extension methods for easy ID generation
extension SimpleIdExtension on String {
  /// Generates a simple ID for this entity type
  String toSimpleId() {
    return SimpleIdGenerator.generateEntityId(this);
  }
}

/// Example usage:
/// 
/// ```dart
/// // Basic 4-character ID
/// String id = SimpleIdGenerator.generateSimpleId(); // e.g., "A3B7"
/// 
/// // Prefixed ID
/// String userId = SimpleIdGenerator.generatePrefixedId('USER'); // e.g., "USER-A3B7"
/// 
/// // Entity-specific ID
/// String projectId = SimpleIdGenerator.generateEntityId('project'); // e.g., "PRJ-K9M2"
/// 
/// // Using extension
/// String serviceId = 'service'.toSimpleId(); // e.g., "SRV-M4N8"
/// 
/// // Custom length
/// String shortId = SimpleIdGenerator.generateCustomLengthId(3); // e.g., "X2Y"
/// 
/// // Validate ID
/// bool isValid = SimpleIdGenerator.isValidSimpleId("A3B7"); // true
/// ```
