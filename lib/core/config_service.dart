import 'package:flutter/foundation.dart';

/// Production-ready configuration service
class ConfigService {
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  // Environment configuration
  static const bool isProduction = kReleaseMode;
  static const bool isDevelopment = kDebugMode;
  static const bool isProfile = kProfileMode;

  // App configuration
  static const String appName = 'Kronium Pro';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // API configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );

  // Security configuration
  static const int sessionTimeoutMinutes = 60;
  static const int maxLoginAttempts = 5;
  static const int rateLimitMaxRequests = 10;
  static const int rateLimitWindowMinutes = 1;

  // File upload configuration
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
  ];
  static const List<String> allowedVideoTypes = ['.mp4', '.mov', '.avi'];
  static const List<String> allowedDocumentTypes = ['.pdf', '.doc', '.docx'];

  // UI configuration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackbarDuration = Duration(seconds: 3);
  static const Duration splashScreenDuration = Duration(seconds: 2);

  // Pagination configuration
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache configuration
  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 50 * 1024 * 1024; // 50MB

  // Logging configuration
  static bool get enableLogging => isDevelopment || isProfile;
  static bool get enableVerboseLogging => isDevelopment;
  static bool get enableCrashReporting => isProduction;

  // Feature flags
  static const bool enableOfflineMode = false;
  static const bool enablePushNotifications = false;
  static const bool enableAnalytics = false;
  static const bool enableBiometricAuth = false;
  static const bool enableDarkMode = true;
  static const bool enableMultiLanguage = false;

  // Business logic configuration
  static const double defaultServicePrice = 100.0;
  static const int maxProjectsPerUser = 50;
  static const int maxBookingsPerUser = 100;
  static const Duration bookingCancellationWindow = Duration(hours: 24);

  // Database configuration
  static const int connectionTimeout = 30; // seconds
  static const int queryTimeout = 15; // seconds
  static const int maxRetries = 3;

  // Storage configuration
  static const String storageBucket = 'public';
  static const String profileImagesFolder = 'profile_images';
  static const String serviceImagesFolder = 'service_images';
  static const String serviceVideosFolder = 'service_videos';
  static const String projectMediaFolder = 'project_media';
  static const String chatAttachmentsFolder = 'chat_attachments';

  // Validation configuration
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 1000;
  static const int maxAddressLength = 500;

  // Get environment-specific configuration
  static Map<String, dynamic> getEnvironmentConfig() {
    return {
      'environment':
          isProduction
              ? 'production'
              : (isDevelopment ? 'development' : 'profile'),
      'appName': appName,
      'appVersion': appVersion,
      'buildNumber': appBuildNumber,
      'enableLogging': enableLogging,
      'enableVerboseLogging': enableVerboseLogging,
      'enableCrashReporting': enableCrashReporting,
      'supabaseUrl': supabaseUrl,
      'features': {
        'offlineMode': enableOfflineMode,
        'pushNotifications': enablePushNotifications,
        'analytics': enableAnalytics,
        'biometricAuth': enableBiometricAuth,
        'darkMode': enableDarkMode,
        'multiLanguage': enableMultiLanguage,
      },
    };
  }

  // Get security configuration
  static Map<String, dynamic> getSecurityConfig() {
    return {
      'sessionTimeoutMinutes': sessionTimeoutMinutes,
      'maxLoginAttempts': maxLoginAttempts,
      'rateLimitMaxRequests': rateLimitMaxRequests,
      'rateLimitWindowMinutes': rateLimitWindowMinutes,
      'maxFileSize': maxFileSize,
      'allowedImageTypes': allowedImageTypes,
      'allowedVideoTypes': allowedVideoTypes,
      'allowedDocumentTypes': allowedDocumentTypes,
    };
  }

  // Get UI configuration
  static Map<String, dynamic> getUIConfig() {
    return {
      'animationDuration': animationDuration.inMilliseconds,
      'snackbarDuration': snackbarDuration.inSeconds,
      'splashScreenDuration': splashScreenDuration.inSeconds,
      'defaultPageSize': defaultPageSize,
      'maxPageSize': maxPageSize,
    };
  }

  // Get business configuration
  static Map<String, dynamic> getBusinessConfig() {
    return {
      'defaultServicePrice': defaultServicePrice,
      'maxProjectsPerUser': maxProjectsPerUser,
      'maxBookingsPerUser': maxBookingsPerUser,
      'bookingCancellationWindowHours': bookingCancellationWindow.inHours,
    };
  }

  // Get validation configuration
  static Map<String, dynamic> getValidationConfig() {
    return {
      'minPasswordLength': minPasswordLength,
      'maxPasswordLength': maxPasswordLength,
      'minNameLength': minNameLength,
      'maxNameLength': maxNameLength,
      'maxDescriptionLength': maxDescriptionLength,
      'maxAddressLength': maxAddressLength,
    };
  }

  // Check if feature is enabled
  static bool isFeatureEnabled(String feature) {
    switch (feature.toLowerCase()) {
      case 'offline':
      case 'offlinemode':
        return enableOfflineMode;
      case 'push':
      case 'pushnotifications':
        return enablePushNotifications;
      case 'analytics':
        return enableAnalytics;
      case 'biometric':
      case 'biometricauth':
        return enableBiometricAuth;
      case 'dark':
      case 'darkmode':
        return enableDarkMode;
      case 'multilanguage':
      case 'i18n':
        return enableMultiLanguage;
      default:
        return false;
    }
  }

  // Get all configuration as a single map
  static Map<String, dynamic> getAllConfig() {
    return {
      'environment': getEnvironmentConfig(),
      'security': getSecurityConfig(),
      'ui': getUIConfig(),
      'business': getBusinessConfig(),
      'validation': getValidationConfig(),
    };
  }
}
