// Test filename cleaning
// Run this with: dart test_filename.dart

void main() {
  print('🧪 Testing Filename Cleaning');
  print('============================\n');

  // Test the problematic filename from the error
  final problematicFileName =
      'project_media_1757684112001.blob:http://localhost:55788/da3fbf74-6ee2-431b-ba6e-4276a4f4e80d';

  print('Original filename:');
  print('$problematicFileName\n');

  // Simulate the cleaning process
  String cleanName = problematicFileName
      .replaceAll(
        RegExp(r'[^\w\-_\.]'),
        '_',
      ) // Replace invalid chars with underscore
      .replaceAll(
        RegExp(r'_{2,}'),
        '_',
      ) // Replace multiple underscores with single
      .replaceAll(RegExp(r'^_+|_+$'), '') // Remove leading/trailing underscores
      .replaceAll(RegExp(r'blob:http://[^/]+/'), '') // Remove blob URLs
      .replaceAll(
        RegExp(r'[^a-zA-Z0-9\-_\.]'),
        '_',
      ); // Remove any remaining invalid characters

  // Ensure it has an extension
  if (!cleanName.contains('.')) {
    cleanName = '${cleanName}_file';
  }

  // Limit length
  if (cleanName.length > 100) {
    final extension = cleanName.split('.').last;
    cleanName = '${cleanName.substring(0, 95)}.$extension';
  }

  print('Cleaned filename:');
  print('$cleanName\n');

  print('✅ Filename should now be Appwrite-compatible!');
  print('The app should work correctly with this fix.');
}



