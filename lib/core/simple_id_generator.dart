import 'dart:math';

/// Simple ID generator for creating user-friendly IDs
/// Generates 8-character IDs with exactly 3 letters and 5 numbers
class SimpleIdGenerator {
  // Letters to use for ID generation (exclude confusing characters)
  static const String _letters = 'ABCDEFGHJKMNPQRSTUVWXYZ';

  // Numbers to use for ID generation (exclude confusing characters)
  static const String _numbers = '23456789';

  static final Random _random = Random();

  /// Generates a simple 8-character ID with exactly 3 letters and 5 numbers
  /// Format: LLLNNNNN (e.g., ABC23456, XYZ78923, etc.)
  static String generateSimpleId() {
    final List<String> letters = List.generate(
      3,
      (index) => _letters[_random.nextInt(_letters.length)],
    );
    final List<String> numbers = List.generate(
      5,
      (index) => _numbers[_random.nextInt(_numbers.length)],
    );

    // Shuffle the combined list to randomize position
    final List<String> combined = [...letters, ...numbers];
    combined.shuffle(_random);

    return combined.join();
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
  /// Note: For 8-character IDs, use generateSimpleId() for proper 3 letters + 5 numbers format
  static String generateCustomLengthId(int length) {
    if (length < 2 || length > 8) {
      throw ArgumentError('Length must be between 2 and 8 characters');
    }

    final buffer = StringBuffer();

    for (int i = 0; i < length; i++) {
      // Use both letters and numbers for custom length
      final allChars = _letters + _numbers;
      buffer.write(allChars[_random.nextInt(allChars.length)]);
    }

    return buffer.toString();
  }

  /// Validates if a string is a valid simple ID format
  /// Must be exactly 8 characters with 3 letters and 5 numbers
  static bool isValidSimpleId(String id) {
    if (id.length != 8) return false;

    int letterCount = 0;
    int numberCount = 0;

    for (int i = 0; i < id.length; i++) {
      final char = id[i].toUpperCase();
      if (_letters.contains(char)) {
        letterCount++;
      } else if (_numbers.contains(char)) {
        numberCount++;
      } else {
        return false; // Invalid character
      }
    }

    return letterCount == 3 && numberCount == 5;
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
/// // Basic 8-character ID with 3 letters and 5 numbers
/// String id = SimpleIdGenerator.generateSimpleId(); // e.g., "ABC23456"
/// 
/// // Prefixed ID
/// String userId = SimpleIdGenerator.generatePrefixedId('USER'); // e.g., "USER-ABC23456"
/// 
/// // Entity-specific ID
/// String projectId = SimpleIdGenerator.generateEntityId('project'); // e.g., "PRJ-XYZ78923"
/// 
/// // Using extension
/// String serviceId = 'service'.toSimpleId(); // e.g., "SRV-MNP45678"
/// 
/// // Custom length (not recommended for 8-char IDs)
/// String shortId = SimpleIdGenerator.generateCustomLengthId(3); // e.g., "X2Y"
/// 
/// // Validate ID
/// bool isValid = SimpleIdGenerator.isValidSimpleId("ABC23456"); // true
/// ```
