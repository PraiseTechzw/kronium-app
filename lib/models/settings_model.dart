class UserSettings {
  final String userId;
  final bool pushNotifications;
  final bool emailNotifications;
  final bool smsNotifications;
  final String language;
  final String theme;
  final bool autoLocation;
  final bool showDistance;
  final String currency;
  final bool darkMode;
  final bool biometricAuth;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final int notificationRadius;
  final List<String> preferredCategories;
  final Map<String, dynamic> customPreferences;

  UserSettings({
    required this.userId,
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.language = 'en',
    this.theme = 'system',
    this.autoLocation = true,
    this.showDistance = true,
    this.currency = 'USD',
    this.darkMode = false,
    this.biometricAuth = false,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.notificationRadius = 50,
    this.preferredCategories = const [],
    this.customPreferences = const {},
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      userId: map['userId'] ?? '',
      pushNotifications: map['pushNotifications'] ?? true,
      emailNotifications: map['emailNotifications'] ?? true,
      smsNotifications: map['smsNotifications'] ?? false,
      language: map['language'] ?? 'en',
      theme: map['theme'] ?? 'system',
      autoLocation: map['autoLocation'] ?? true,
      showDistance: map['showDistance'] ?? true,
      currency: map['currency'] ?? 'USD',
      darkMode: map['darkMode'] ?? false,
      biometricAuth: map['biometricAuth'] ?? false,
      soundEnabled: map['soundEnabled'] ?? true,
      vibrationEnabled: map['vibrationEnabled'] ?? true,
      notificationRadius: map['notificationRadius'] ?? 50,
      preferredCategories: List<String>.from(map['preferredCategories'] ?? []),
      customPreferences: Map<String, dynamic>.from(
        map['customPreferences'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'pushNotifications': pushNotifications,
      'emailNotifications': emailNotifications,
      'smsNotifications': smsNotifications,
      'language': language,
      'theme': theme,
      'autoLocation': autoLocation,
      'showDistance': showDistance,
      'currency': currency,
      'darkMode': darkMode,
      'biometricAuth': biometricAuth,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'notificationRadius': notificationRadius,
      'preferredCategories': preferredCategories,
      'customPreferences': customPreferences,
    };
  }

  UserSettings copyWith({
    String? userId,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? smsNotifications,
    String? language,
    String? theme,
    bool? autoLocation,
    bool? showDistance,
    String? currency,
    bool? darkMode,
    bool? biometricAuth,
    bool? soundEnabled,
    bool? vibrationEnabled,
    int? notificationRadius,
    List<String>? preferredCategories,
    Map<String, dynamic>? customPreferences,
  }) {
    return UserSettings(
      userId: userId ?? this.userId,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      autoLocation: autoLocation ?? this.autoLocation,
      showDistance: showDistance ?? this.showDistance,
      currency: currency ?? this.currency,
      darkMode: darkMode ?? this.darkMode,
      biometricAuth: biometricAuth ?? this.biometricAuth,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      notificationRadius: notificationRadius ?? this.notificationRadius,
      preferredCategories: preferredCategories ?? this.preferredCategories,
      customPreferences: customPreferences ?? this.customPreferences,
    );
  }
}
