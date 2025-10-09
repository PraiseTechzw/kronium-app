import 'package:appwrite/appwrite.dart';
import 'appwrite_config.dart';

class AppwriteService {
  static final Client client = Client();
  static Storage? _storage;

  /// Call this at app startup (e.g., in main.dart) to initialize Appwrite
  static void init() {
    try {
      // Validate configuration
      if (!AppwriteConfig.isConfigured) {
        throw Exception(
          'Appwrite configuration not set. Please follow the setup guide in APPWRITE_SETUP.md and update lib/core/appwrite_config.dart with your actual project and bucket IDs.',
        );
      }

      client
          .setEndpoint(AppwriteConfig.endpoint)
          .setProject(AppwriteConfig.projectId);
      _storage = Storage(client);
      print('Appwrite initialized successfully');
      print('Endpoint: https://cloud.appwrite.io/v1');
      print('Project ID: 6867ce2e001b592626ae');
    } catch (e) {
      print('Appwrite initialization error: $e');
      rethrow;
    }
  }

  static Storage get storage {
    if (_storage == null) {
      throw Exception(
        'AppwriteService not initialized. Call AppwriteService.init() first.',
      );
    }
    return _storage!;
  }

  // Storage Helper Methods
  /// Uploads a file to Appwrite Storage. Returns the file ID on success.
  static Future<String?> uploadFile({
    required String bucketId,
    required String path,
    required List<int> bytes,
    required String fileName,
  }) async {
    try {
      // Clean and validate filename
      final cleanFileName = _cleanFileName(fileName);
      print(
        'Uploading to bucket: $bucketId, fileName: $cleanFileName, bytes: ${bytes.length}',
      );

      final result = await storage.createFile(
        bucketId: bucketId,
        fileId: ID.unique(),
        file: InputFile.fromBytes(bytes: bytes, filename: cleanFileName),
      );
      print('Upload result: $result');
      print('File ID: ${result.$id}');
      return result.$id;
    } catch (e, stack) {
      print('Appwrite upload error: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  /// Cleans filename to ensure it's valid for Appwrite
  static String _cleanFileName(String fileName) {
    // Remove any invalid characters and ensure proper extension
    String cleanName = fileName
        .replaceAll(
          RegExp(r'[^\w\-_\.]'),
          '_',
        ) // Replace invalid chars with underscore
        .replaceAll(
          RegExp(r'_{2,}'),
          '_',
        ) // Replace multiple underscores with single
        .replaceAll(
          RegExp(r'^_+|_+$'),
          '',
        ) // Remove leading/trailing underscores
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

    return cleanName;
  }

  /// Downloads a file from Appwrite Storage by file ID. Returns file bytes.
  static Future<List<int>?> downloadFile({
    required String bucketId,
    required String fileId,
  }) async {
    try {
      final result = await storage.getFileDownload(
        bucketId: bucketId,
        fileId: fileId,
      );
      return result;
    } catch (e) {
      // Handle error and return null
      return null;
    }
  }

  /// Deletes a file from Appwrite Storage by file ID. Returns true if successful.
  static Future<bool> deleteFile({
    required String bucketId,
    required String fileId,
  }) async {
    try {
      await storage.deleteFile(bucketId: bucketId, fileId: fileId);
      return true;
    } catch (e) {
      // Handle error
      return false;
    }
  }

  /// Test Appwrite connection and bucket access
  static Future<bool> testConnection(String bucketId) async {
    try {
      print('Testing Appwrite connection for bucket: $bucketId');
      print('Project ID: ${AppwriteConfig.projectId}');
      print('Endpoint: ${AppwriteConfig.endpoint}');

      // Try to list files in the bucket to test connection
      final result = await storage.listFiles(bucketId: bucketId);
      print('Appwrite connection test successful');
      print('Bucket contains ${result.files.length} files');
      return true;
    } catch (e) {
      print('Appwrite connection test failed: $e');
      if (e.toString().contains('project_not_found')) {
        print('❌ Project ID is incorrect or project doesn\'t exist');
      } else if (e.toString().contains('bucket_not_found')) {
        print('❌ Bucket ID is incorrect or bucket doesn\'t exist');
      } else if (e.toString().contains('permission')) {
        print('❌ Permission denied - check bucket permissions');
      } else if (e.toString().contains('network')) {
        print('❌ Network error - check internet connection');
      }
      return false;
    }
  }
}
