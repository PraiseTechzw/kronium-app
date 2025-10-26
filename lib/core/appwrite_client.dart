import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'appwrite_config.dart';

/// Exception classes for better error handling
class AppwriteException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppwriteException(this.message, {this.code, this.originalError});

  @override
  String toString() =>
      'AppwriteException: $message${code != null ? ' (Code: $code)' : ''}';
}

class AppwriteConfigException extends AppwriteException {
  AppwriteConfigException(String message)
    : super(message, code: 'CONFIG_ERROR');
}

class AppwriteUploadException extends AppwriteException {
  AppwriteUploadException(String message, {dynamic originalError})
    : super(message, code: 'UPLOAD_ERROR', originalError: originalError);
}

class AppwriteDownloadException extends AppwriteException {
  AppwriteDownloadException(String message, {dynamic originalError})
    : super(message, code: 'DOWNLOAD_ERROR', originalError: originalError);
}

class AppwriteDeleteException extends AppwriteException {
  AppwriteDeleteException(String message, {dynamic originalError})
    : super(message, code: 'DELETE_ERROR', originalError: originalError);
}

/// Enhanced Appwrite service with improved error handling and features
class AppwriteService {
  static final Client client = Client();
  static Storage? _storage;
  static bool _isInitialized = false;
  static final _initLock = Completer<void>();

  // Configuration constants
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  static const int maxFileNameLength = 100;
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// Check if service is initialized
  static bool get isInitialized => _isInitialized;

  /// Initialize Appwrite service (thread-safe)
  static Future<void> init() async {
    if (_isInitialized) {
      print('⚠️ Appwrite already initialized');
      return;
    }

    if (_initLock.isCompleted) {
      await _initLock.future;
      return;
    }

    try {
      // Validate configuration
      if (!AppwriteConfig.isConfigured) {
        throw AppwriteConfigException(
          'Appwrite configuration not set. Please follow the setup guide in APPWRITE_SETUP.md '
          'and update lib/core/appwrite_config.dart with your actual project and bucket IDs.',
        );
      }

      // Validate endpoint format
      if (!_isValidEndpoint(AppwriteConfig.endpoint)) {
        throw AppwriteConfigException(
          'Invalid endpoint format: ${AppwriteConfig.endpoint}',
        );
      }

      // Configure client
      client
          .setEndpoint(AppwriteConfig.endpoint)
          .setProject(AppwriteConfig.projectId);

      _storage = Storage(client);
      _isInitialized = true;

      print('✅ Appwrite initialized successfully');
      print('📍 Endpoint: ${AppwriteConfig.endpoint}');
      print('🔑 Project ID: ${AppwriteConfig.projectId}');

      _initLock.complete();
    } catch (e, stackTrace) {
      print('❌ Appwrite initialization error: $e');
      print('Stack trace: $stackTrace');
      _initLock.completeError(e, stackTrace);
      rethrow;
    }
  }

  /// Get storage instance (with initialization check)
  static Storage get storage {
    if (!_isInitialized || _storage == null) {
      throw AppwriteException(
        'AppwriteService not initialized. Call AppwriteService.init() first.',
        code: 'NOT_INITIALIZED',
      );
    }
    return _storage!;
  }

  /// Upload a file to Appwrite Storage with enhanced validation
  static Future<String> uploadFile({
    required String bucketId,
    required String path,
    required List<int> bytes,
    required String fileName,
    List<String>? permissions,
    void Function(double progress)? onProgress,
  }) async {
    try {
      // Validate inputs
      _validateBucketId(bucketId);
      _validateFileSize(bytes.length);

      // Clean and validate filename
      final cleanFileName = _cleanFileName(fileName);

      print('📤 Uploading file...');
      print('   Bucket: $bucketId');
      print('   Filename: $cleanFileName');
      print('   Size: ${_formatBytes(bytes.length)}');

      final startTime = DateTime.now();

      final result = await storage
          .createFile(
            bucketId: bucketId,
            fileId: ID.unique(),
            file: InputFile.fromBytes(bytes: bytes, filename: cleanFileName),
            permissions: permissions,
          )
          .timeout(
            defaultTimeout,
            onTimeout: () {
              throw AppwriteUploadException(
                'Upload timeout after ${defaultTimeout.inSeconds} seconds',
              );
            },
          );

      final duration = DateTime.now().difference(startTime);
      print('✅ Upload successful!');
      print('   File ID: ${result.$id}');
      print('   Duration: ${duration.inMilliseconds}ms');

      return result.$id;
    } on Exception catch (e) {
      final errorMessage = _parseAppwriteError(e);
      print('❌ Appwrite upload error: $errorMessage');
      throw AppwriteUploadException(errorMessage, originalError: e);
    } catch (e, stackTrace) {
      print('❌ Upload error: $e');
      print('Stack trace: $stackTrace');
      throw AppwriteUploadException(
        'Failed to upload file: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Download a file from Appwrite Storage
  static Future<List<int>> downloadFile({
    required String bucketId,
    required String fileId,
  }) async {
    try {
      _validateBucketId(bucketId);
      _validateFileId(fileId);

      print('📥 Downloading file...');
      print('   Bucket: $bucketId');
      print('   File ID: $fileId');

      final startTime = DateTime.now();

      final result = await storage
          .getFileDownload(bucketId: bucketId, fileId: fileId)
          .timeout(
            defaultTimeout,
            onTimeout: () {
              throw AppwriteDownloadException(
                'Download timeout after ${defaultTimeout.inSeconds} seconds',
              );
            },
          );

      final duration = DateTime.now().difference(startTime);
      print('✅ Download successful!');
      print('   Size: ${_formatBytes(result.length)}');
      print('   Duration: ${duration.inMilliseconds}ms');

      return result;
    } on Exception catch (e) {
      final errorMessage = _parseAppwriteError(e);
      print('❌ Appwrite download error: $errorMessage');
      throw AppwriteDownloadException(errorMessage, originalError: e);
    } catch (e, stackTrace) {
      print('❌ Download error: $e');
      print('Stack trace: $stackTrace');
      throw AppwriteDownloadException(
        'Failed to download file: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get file metadata
  static Future<File> getFileMetadata({
    required String bucketId,
    required String fileId,
  }) async {
    try {
      _validateBucketId(bucketId);
      _validateFileId(fileId);

      return await storage.getFile(bucketId: bucketId, fileId: fileId);
    } on Exception catch (e) {
      throw AppwriteException(_parseAppwriteError(e), originalError: e);
    }
  }

  /// List files in a bucket with pagination
  static Future<FileList> listFiles({
    required String bucketId,
    List<String>? queries,
    String? search,
    int? limit,
    int? offset,
  }) async {
    try {
      _validateBucketId(bucketId);

      return await storage.listFiles(
        bucketId: bucketId,
        queries: queries,
        search: search,
      );
    } on Exception catch (e) {
      throw AppwriteException(_parseAppwriteError(e), originalError: e);
    }
  }

  /// Delete a file from Appwrite Storage
  static Future<void> deleteFile({
    required String bucketId,
    required String fileId,
  }) async {
    try {
      _validateBucketId(bucketId);
      _validateFileId(fileId);

      print('🗑️ Deleting file...');
      print('   Bucket: $bucketId');
      print('   File ID: $fileId');

      await storage.deleteFile(bucketId: bucketId, fileId: fileId);

      print('✅ File deleted successfully');
    } on Exception catch (e) {
      final errorMessage = _parseAppwriteError(e);
      print('❌ Appwrite delete error: $errorMessage');
      throw AppwriteDeleteException(errorMessage, originalError: e);
    } catch (e, stackTrace) {
      print('❌ Delete error: $e');
      print('Stack trace: $stackTrace');
      throw AppwriteDeleteException(
        'Failed to delete file: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get file preview/thumbnail URL
  static String getFilePreview({
    required String bucketId,
    required String fileId,
    int? width,
    int? height,
    int? quality,
  }) {
    _validateBucketId(bucketId);
    _validateFileId(fileId);

    final params = <String, String>{};
    if (width != null) params['width'] = width.toString();
    if (height != null) params['height'] = height.toString();
    if (quality != null) params['quality'] = quality.toString();

    final queryString =
        params.isEmpty
            ? ''
            : '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';

    return '${AppwriteConfig.endpoint}/storage/buckets/$bucketId/files/$fileId/preview$queryString';
  }

  /// Get file view URL
  static String getFileView({
    required String bucketId,
    required String fileId,
  }) {
    _validateBucketId(bucketId);
    _validateFileId(fileId);

    return '${AppwriteConfig.endpoint}/storage/buckets/$bucketId/files/$fileId/view';
  }

  /// Test Appwrite connection and bucket access
  static Future<bool> testConnection(String bucketId) async {
    try {
      print('🔍 Testing Appwrite connection...');
      print('   Project ID: ${AppwriteConfig.projectId}');
      print('   Endpoint: ${AppwriteConfig.endpoint}');
      print('   Bucket ID: $bucketId');

      final result = await storage.listFiles(bucketId: bucketId);

      print('✅ Connection test successful!');
      print('   Bucket contains ${result.files.length} file(s)');
      print('   Total files: ${result.total}');
      return true;
    } on Exception catch (e) {
      final errorMessage = _parseAppwriteError(e);
      print('❌ Connection test failed: $errorMessage');

      if (errorMessage.contains('project_not_found')) {
        print('💡 Hint: Check your project ID in appwrite_config.dart');
      } else if (errorMessage.contains('bucket_not_found')) {
        print(
          '💡 Hint: Create the bucket in Appwrite Console or check bucket ID',
        );
      } else if (errorMessage.contains('permission')) {
        print(
          '💡 Hint: Add proper permissions to the bucket (Any role for read/write)',
        );
      }
      return false;
    } catch (e) {
      print('❌ Connection test failed: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('network')) {
        print('💡 Hint: Check your internet connection');
      }
      return false;
    }
  }

  // ===== Private Helper Methods =====

  /// Validate endpoint format
  static bool _isValidEndpoint(String endpoint) {
    return endpoint.startsWith('http://') || endpoint.startsWith('https://');
  }

  /// Validate bucket ID
  static void _validateBucketId(String bucketId) {
    if (bucketId.isEmpty) {
      throw AppwriteException(
        'Bucket ID cannot be empty',
        code: 'INVALID_BUCKET_ID',
      );
    }
  }

  /// Validate file ID
  static void _validateFileId(String fileId) {
    if (fileId.isEmpty) {
      throw AppwriteException(
        'File ID cannot be empty',
        code: 'INVALID_FILE_ID',
      );
    }
  }

  /// Validate file size
  static void _validateFileSize(int sizeInBytes) {
    if (sizeInBytes <= 0) {
      throw AppwriteException(
        'File size must be greater than 0',
        code: 'INVALID_FILE_SIZE',
      );
    }
    if (sizeInBytes > maxFileSize) {
      throw AppwriteException(
        'File size exceeds maximum allowed size of ${_formatBytes(maxFileSize)}',
        code: 'FILE_TOO_LARGE',
      );
    }
  }

  /// Clean filename to ensure it's valid for Appwrite
  static String _cleanFileName(String fileName) {
    if (fileName.isEmpty) {
      return 'unnamed_file';
    }

    // Extract extension
    final parts = fileName.split('.');
    final extension = parts.length > 1 ? parts.last : '';
    final nameWithoutExt =
        parts.length > 1
            ? parts.sublist(0, parts.length - 1).join('.')
            : fileName;

    // Clean the name part
    String cleanName = nameWithoutExt
        .replaceAll(RegExp(r'blob:http[s]?://[^/]+/'), '') // Remove blob URLs
        .replaceAll(
          RegExp(r'[^\w\-_]'),
          '_',
        ) // Replace invalid chars with underscore
        .replaceAll(
          RegExp(r'_{2,}'),
          '_',
        ) // Replace multiple underscores with single
        .replaceAll(
          RegExp(r'^_+|_+$'),
          '',
        ); // Remove leading/trailing underscores

    // Fallback if cleaning results in empty name
    if (cleanName.isEmpty) {
      cleanName = 'file_${DateTime.now().millisecondsSinceEpoch}';
    }

    // Add extension back
    final finalName =
        extension.isNotEmpty ? '$cleanName.$extension' : cleanName;

    // Limit length while preserving extension
    if (finalName.length > maxFileNameLength) {
      final ext = extension.isNotEmpty ? '.$extension' : '';
      final maxNameLength = maxFileNameLength - ext.length;
      return '${cleanName.substring(0, maxNameLength)}$ext';
    }

    return finalName;
  }

  /// Parse Appwrite error messages for better readability
  static String _parseAppwriteError(Exception e) {
    final message = e.toString();

    // Common error mappings
    final errorMap = {
      'project_not_found': 'Project not found. Check your project ID.',
      'bucket_not_found': 'Bucket not found. Check your bucket ID.',
      'file_not_found': 'File not found.',
      'permission_denied': 'Permission denied. Check bucket permissions.',
      'storage_file_empty': 'File is empty.',
      'storage_invalid_file_size': 'Invalid file size.',
      'storage_file_type_unsupported': 'File type not supported.',
      'storage_device_not_found': 'Storage device not found.',
      'network_error': 'Network error. Check your connection.',
    };

    for (final entry in errorMap.entries) {
      if (message.contains(entry.key)) {
        return entry.value;
      }
    }

    return message;
  }

  /// Format bytes to human-readable string
  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
