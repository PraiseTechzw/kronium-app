import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:kronium/core/logger_service.dart';
import 'package:kronium/core/user_controller.dart';

/// Production-ready security service
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final Random _random = Random.secure();

  /// Generate secure random string
  String generateSecureToken({int length = 32}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
      length,
      (index) => chars[_random.nextInt(chars.length)],
    ).join();
  }

  /// Hash password with salt
  String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate salt for password hashing
  String generateSalt({int length = 16}) {
    return generateSecureToken(length: length);
  }

  /// Validate password strength
  Map<String, dynamic> validatePasswordStrength(String password) {
    final result = <String, dynamic>{
      'isValid': false,
      'score': 0,
      'feedback': <String>[],
    };

    if (password.isEmpty) {
      (result['feedback'] as List<String>).add('Password is required');
      return result;
    }

    int score = 0;
    final feedback = <String>[];

    // Length check
    if (password.length >= 8) {
      score += 1;
    } else {
      feedback.add('Password must be at least 8 characters long');
    }

    // Uppercase check
    if (password.contains(RegExp(r'[A-Z]'))) {
      score += 1;
    } else {
      feedback.add('Password must contain at least one uppercase letter');
    }

    // Lowercase check
    if (password.contains(RegExp(r'[a-z]'))) {
      score += 1;
    } else {
      feedback.add('Password must contain at least one lowercase letter');
    }

    // Number check
    if (password.contains(RegExp(r'[0-9]'))) {
      score += 1;
    } else {
      feedback.add('Password must contain at least one number');
    }

    // Special character check
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      score += 1;
    } else {
      feedback.add('Password must contain at least one special character');
    }

    // Common password check
    if (_isCommonPassword(password)) {
      score -= 2;
      feedback.add(
        'Password is too common, please choose a more unique password',
      );
    }

    result['score'] = score;
    result['feedback'] = feedback;
    result['isValid'] = score >= 4 && feedback.isEmpty;

    return result;
  }

  /// Check if password is commonly used
  bool _isCommonPassword(String password) {
    const commonPasswords = [
      'password',
      '123456',
      '123456789',
      'qwerty',
      'abc123',
      'password123',
      'admin',
      'letmein',
      'welcome',
      'monkey',
      'dragon',
      'master',
      'shadow',
      'superman',
      'michael',
      'football',
      'baseball',
      'liverpool',
      'jordan',
      'princess',
    ];

    return commonPasswords.contains(password.toLowerCase());
  }

  /// Sanitize user input to prevent XSS
  String sanitizeInput(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('&', '&amp;')
        .replaceAll('/', '&#x2F;')
        .trim();
  }

  /// Validate and sanitize email
  String? validateAndSanitizeEmail(String email) {
    if (email.isEmpty) return null;

    final sanitized = sanitizeInput(email.toLowerCase().trim());
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(sanitized)) {
      return null;
    }

    return sanitized;
  }

  /// Check for SQL injection patterns
  bool containsSqlInjection(String input) {
    final sqlPatterns = [
      r"('|(\\')|(;)|(\\;))",
      r"((\%27)|(\'))((\%6F)|o|(\%4F))((\%72)|r|(\%52))",
      r"((\%27)|(\'))((\%75)|u|(\%55))((\%6E)|n|(\%4E))((\%69)|i|(\%49))((\%6F)|o|(\%4F))((\%6E)|n|(\%4E))",
      r"((\%27)|(\'))((\%73)|s|(\%53))((\%65)|e|(\%45))((\%6C)|l|(\%4C))((\%65)|e|(\%45))((\%63)|c|(\%43))((\%74)|t|(\%54))",
      r"((\%27)|(\'))((\%69)|i|(\%49))((\%6E)|n|(\%4E))((\%73)|s|(\%53))((\%65)|e|(\%45))((\%72)|r|(\%52))((\%74)|t|(\%54))",
      r"((\%27)|(\'))((\%64)|d|(\%44))((\%65)|e|(\%45))((\%6C)|l|(\%4C))((\%65)|e|(\%45))((\%74)|t|(\%54))((\%65)|e|(\%45))",
      r"((\%27)|(\'))((\%75)|u|(\%55))((\%70)|p|(\%50))((\%64)|d|(\%44))((\%61)|a|(\%41))((\%74)|t|(\%54))((\%65)|e|(\%45))",
      r"((\%27)|(\'))((\%64)|d|(\%44))((\%72)|r|(\%52))((\%6F)|o|(\%4F))((\%70)|p|(\%50))",
    ];

    for (final pattern in sqlPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(input)) {
        return true;
      }
    }

    return false;
  }

  /// Rate limiting check (simple in-memory implementation)
  final Map<String, List<DateTime>> _rateLimitMap = {};

  bool checkRateLimit(
    String identifier, {
    int maxRequests = 10,
    Duration window = const Duration(minutes: 1),
  }) {
    final now = DateTime.now();
    final windowStart = now.subtract(window);

    // Clean old entries
    final timestamps = _rateLimitMap[identifier];
    if (timestamps != null) {
      timestamps.removeWhere((time) => time.isBefore(windowStart));
    }

    // Initialize if not exists
    _rateLimitMap[identifier] ??= [];

    // Check if limit exceeded
    final currentTimestamps = _rateLimitMap[identifier]!;
    if (currentTimestamps.length >= maxRequests) {
      logger.warning('Rate limit exceeded for: $identifier');
      return false;
    }

    // Add current request
    currentTimestamps.add(now);
    return true;
  }

  /// Validate user permissions for action
  bool validatePermission(String permission, {String? context}) {
    try {
      final userController = Get.find<UserController>();
      final hasPermission = userController.hasPermission(permission);

      if (!hasPermission) {
        logger.warning(
          'Permission denied: $permission for user ${userController.userId.value} in context: $context',
        );
      }

      return hasPermission;
    } catch (e) {
      logger.error('Error validating permission: $permission', e);
      return false;
    }
  }

  /// Validate admin access
  bool validateAdminAccess({String? context}) {
    try {
      final userController = Get.find<UserController>();
      final isAdmin = userController.isAdmin;

      if (!isAdmin) {
        logger.warning(
          'Admin access denied for user ${userController.userId.value} in context: $context',
        );
      }

      return isAdmin;
    } catch (e) {
      logger.error('Error validating admin access', e);
      return false;
    }
  }

  /// Generate CSRF token
  String generateCSRFToken() {
    return generateSecureToken(length: 32);
  }

  /// Validate CSRF token
  bool validateCSRFToken(String token, String expectedToken) {
    return token.isNotEmpty && token == expectedToken;
  }

  /// Encrypt sensitive data (simple implementation)
  String encryptData(String data, String key) {
    // This is a simple XOR encryption for demonstration
    // In production, use proper encryption libraries like encrypt package
    final keyBytes = utf8.encode(key);
    final dataBytes = utf8.encode(data);
    final encrypted = <int>[];

    for (int i = 0; i < dataBytes.length; i++) {
      encrypted.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return base64.encode(encrypted);
  }

  /// Decrypt sensitive data
  String decryptData(String encryptedData, String key) {
    try {
      final keyBytes = utf8.encode(key);
      final encryptedBytes = base64.decode(encryptedData);
      final decrypted = <int>[];

      for (int i = 0; i < encryptedBytes.length; i++) {
        decrypted.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      return utf8.decode(decrypted);
    } catch (e) {
      logger.error('Error decrypting data', e);
      return '';
    }
  }

  /// Log security event
  void logSecurityEvent(String event, {Map<String, dynamic>? details}) {
    final userController = Get.find<UserController>();
    final logData = {
      'event': event,
      'timestamp': DateTime.now().toIso8601String(),
      'userId': userController.userId.value,
      'userRole': userController.role.value,
      'details': details ?? {},
    };

    logger.warning('Security Event: ${jsonEncode(logData)}');
  }

  /// Validate file upload security
  Map<String, dynamic> validateFileUpload(
    String fileName,
    int fileSize,
    String? mimeType,
  ) {
    final result = <String, dynamic>{'isValid': false, 'errors': <String>[]};

    final errors = result['errors'] as List<String>;

    // Check file size (10MB limit)
    const maxFileSize = 10 * 1024 * 1024; // 10MB
    if (fileSize > maxFileSize) {
      errors.add('File size exceeds 10MB limit');
    }

    // Check file extension
    final allowedExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.pdf',
      '.doc',
      '.docx',
      '.mp4',
      '.mov',
    ];
    final extension = fileName.toLowerCase().substring(
      fileName.lastIndexOf('.'),
    );

    if (!allowedExtensions.contains(extension)) {
      errors.add('File type not allowed');
    }

    // Check MIME type if provided
    if (mimeType != null) {
      final allowedMimeTypes = [
        'image/jpeg',
        'image/png',
        'image/gif',
        'application/pdf',
        'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'video/mp4',
        'video/quicktime',
      ];

      if (!allowedMimeTypes.contains(mimeType)) {
        errors.add('MIME type not allowed');
      }
    }

    // Check for suspicious file names
    if (fileName.contains('..') ||
        fileName.contains('/') ||
        fileName.contains('\\')) {
      errors.add('Invalid file name');
    }

    result['isValid'] = errors.isEmpty;
    return result;
  }

  /// Clean up rate limit data periodically
  void cleanupRateLimitData() {
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(hours: 1));

    _rateLimitMap.removeWhere((key, timestamps) {
      timestamps.removeWhere((time) => time.isBefore(cutoff));
      return timestamps.isEmpty;
    });

    logger.debug('Rate limit data cleaned up');
  }
}
