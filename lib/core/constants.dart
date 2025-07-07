class AppConstants {
  static const String appName = 'KRONIUM PRO';
  static const String appVersion = '1.0.0';
  
  // Animation paths
  static const String splashAnimation = 'assets/animations/splash_wave.json';
  static const String loadingAnimation = 'assets/animations/loading.json';
  static const String successAnimation = 'assets/animations/success.json';
  
  // Image paths
  static const String appLogo = 'assets/images/logo.png';
  static const String loginHeader = 'assets/images/login_header.png';
  
  // API Endpoints (example)
  static const String baseUrl = 'https://api.kronium.com';
  static const String loginEndpoint = '$baseUrl/auth/login';

  static String? loginAnimation;
}