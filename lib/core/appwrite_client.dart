import 'package:appwrite/appwrite.dart';

class AppwriteService {
  static final Client client = Client();
  static Storage? _storage;

  /// Call this at app startup (e.g., in main.dart) to initialize Appwrite
  static void init() {
    client
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('6867ce2e001b592626ae');
    _storage = Storage(client);
  }

  static Storage get storage {
    if (_storage == null) {
      throw Exception('AppwriteService not initialized. Call AppwriteService.init() first.');
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
      print('Uploading to bucket: $bucketId, fileName: $fileName, bytes: ${bytes.length}');
      final result = await storage.createFile(
        bucketId: bucketId,
        fileId: ID.unique(),
        file: InputFile.fromBytes(bytes: bytes, filename: fileName),
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
      await storage.deleteFile(
        bucketId: bucketId,
        fileId: fileId,
      );
      return true;
    } catch (e) {
      // Handle error
      return false;
    }
  }
} 