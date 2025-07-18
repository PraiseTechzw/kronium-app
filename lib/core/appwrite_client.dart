import 'package:appwrite/appwrite.dart';

class AppwriteService {
  static final Client client = Client()
    .setEndpoint('https://cloud.appwrite.io/v1') // Appwrite endpoint
    .setProject('6867ce2e001b592626ae'); // Your project ID

  static final Storage storage = Storage(client);

  // Storage Helper Methods
  /// Uploads a file to Appwrite Storage. Returns the file ID on success.
  static Future<String?> uploadFile({
    required String bucketId,
    required String path,
    required List<int> bytes,
    required String fileName,
  }) async {
    try {
      final result = await storage.createFile(
        bucketId: bucketId,
        fileId: ID.unique(),
        file: InputFile.fromBytes(bytes: bytes, filename: fileName),
      );
      return result. $id;
    } catch (e) {
      // Handle error and return null
      return null;
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