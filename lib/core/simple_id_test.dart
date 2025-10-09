import 'package:kronium/core/simple_id_generator.dart';

/// Test file to demonstrate the simple ID system
/// Run this to see how the IDs work
class SimpleIdTest {
  static void runTest() {
    print('=== SIMPLE ID SYSTEM TEST ===\n');

    // Test basic ID generation
    print('1. Basic 4-character IDs:');
    for (int i = 0; i < 5; i++) {
      print('   ${i + 1}. ${SimpleIdGenerator.generateSimpleId()}');
    }

    print('\n2. Prefixed IDs:');
    print('   User: ${SimpleIdGenerator.generatePrefixedId('USER')}');
    print('   Project: ${SimpleIdGenerator.generatePrefixedId('PROJ')}');
    print('   Service: ${SimpleIdGenerator.generatePrefixedId('SERV')}');

    print('\n3. Entity-specific IDs:');
    print('   User: ${SimpleIdGenerator.generateEntityId('user')}');
    print('   Project: ${SimpleIdGenerator.generateEntityId('project')}');
    print('   Service: ${SimpleIdGenerator.generateEntityId('service')}');
    print('   Booking: ${SimpleIdGenerator.generateEntityId('booking')}');
    print('   Admin: ${SimpleIdGenerator.generateEntityId('admin')}');

    print('\n4. Extension methods:');
    print('   User: ${'user'.toSimpleId()}');
    print('   Project: ${'project'.toSimpleId()}');

    print('\n5. Custom length IDs:');
    print('   Short (3 chars): ${SimpleIdGenerator.generateCustomLengthId(3)}');
    print(
      '   Medium (6 chars): ${SimpleIdGenerator.generateCustomLengthId(6)}',
    );

    print('\n6. Multiple unique IDs:');
    final multipleIds = SimpleIdGenerator.generateMultipleIds(5);
    print('   5 unique IDs: $multipleIds');

    print('\n7. Validation tests:');
    final testIds = ['A3B7', 'K9M2', 'A3B', 'A3B7O', '1234', 'ABCD'];
    for (final id in testIds) {
      final isValid = SimpleIdGenerator.isValidSimpleId(id);
      print('   "$id" is valid: $isValid');
    }

    print('\n8. Character set used:');
    print('   Safe characters: ABCDEFGHJKMNPQRSTUVWXYZ23456789');
    print('   (Excludes confusing characters: 0, O, 1, I, L)');

    print('\n=== TEST COMPLETE ===');
  }
}

/// Example usage in your app:
///
/// ```dart
/// // In your main.dart or any widget:
/// SimpleIdTest.runTest();
/// ```
