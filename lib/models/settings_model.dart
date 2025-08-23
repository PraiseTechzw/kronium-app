class UserSettings {
  final String userId;

  // Notification Preferences
  final bool pushNotifications;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool projectUpdates;
  final bool serviceAlerts;
  final bool priceChanges;
  final bool maintenanceReminders;

  // Engineering Service Preferences
  final List<String> preferredServiceCategories;
  final List<String> preferredProjectTypes;
  final bool autoLocationServices;
  final bool showProjectDistance;
  final bool showTransportCosts;
  final bool showProjectProgress;
  final String preferredProjectSize;
  final String preferredBudgetRange;

  // App Preferences
  final String language;
  final String theme;
  final String currency;
  final bool darkMode;
  final bool biometricAuth;
  final bool soundEnabled;
  final bool vibrationEnabled;

  // Project Management Preferences
  final bool autoSaveDrafts;
  final bool showProjectHistory;
  final bool enableProjectSharing;
  final int maxActiveProjects;
  final bool showProjectTimeline;
  final bool enableProjectNotifications;

  // Location & Transport Preferences
  final bool enableLocationTracking;
  final int notificationRadius;
  final bool showNearbyServices;
  final bool enableTransportCalculation;
  final String preferredTransportMode;

  // Custom Preferences
  final Map<String, dynamic> customPreferences;

  UserSettings({
    required this.userId,

    // Notification defaults
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.projectUpdates = true,
    this.serviceAlerts = true,
    this.priceChanges = true,
    this.maintenanceReminders = true,

    // Engineering service defaults
    this.preferredServiceCategories = const [
      'Greenhouse',
      'Solar Systems',
      'Construction',
    ],
    this.preferredProjectTypes = const [
      'Residential',
      'Commercial',
      'Industrial',
    ],
    this.autoLocationServices = true,
    this.showProjectDistance = true,
    this.showTransportCosts = true,
    this.showProjectProgress = true,
    this.preferredProjectSize = 'Medium',
    this.preferredBudgetRange = 'Flexible',

    // App defaults
    this.language = 'en',
    this.theme = 'system',
    this.currency = 'USD',
    this.darkMode = false,
    this.biometricAuth = false,
    this.soundEnabled = true,
    this.vibrationEnabled = true,

    // Project management defaults
    this.autoSaveDrafts = true,
    this.showProjectHistory = true,
    this.enableProjectSharing = false,
    this.maxActiveProjects = 5,
    this.showProjectTimeline = true,
    this.enableProjectNotifications = true,

    // Location defaults
    this.enableLocationTracking = true,
    this.notificationRadius = 50,
    this.showNearbyServices = true,
    this.enableTransportCalculation = true,
    this.preferredTransportMode = 'Auto',

    // Custom preferences
    this.customPreferences = const {},
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      userId: map['userId'] ?? '',

      // Notifications
      pushNotifications: map['pushNotifications'] ?? true,
      emailNotifications: map['emailNotifications'] ?? true,
      smsNotifications: map['smsNotifications'] ?? false,
      projectUpdates: map['projectUpdates'] ?? true,
      serviceAlerts: map['serviceAlerts'] ?? true,
      priceChanges: map['priceChanges'] ?? true,
      maintenanceReminders: map['maintenanceReminders'] ?? true,

      // Engineering services
      preferredServiceCategories: List<String>.from(
        map['preferredServiceCategories'] ??
            ['Greenhouse', 'Solar Systems', 'Construction'],
      ),
      preferredProjectTypes: List<String>.from(
        map['preferredProjectTypes'] ??
            ['Residential', 'Commercial', 'Industrial'],
      ),
      autoLocationServices: map['autoLocationServices'] ?? true,
      showProjectDistance: map['showProjectDistance'] ?? true,
      showTransportCosts: map['showTransportCosts'] ?? true,
      showProjectProgress: map['showProjectProgress'] ?? true,
      preferredProjectSize: map['preferredProjectSize'] ?? 'Medium',
      preferredBudgetRange: map['preferredBudgetRange'] ?? 'Flexible',

      // App preferences
      language: map['language'] ?? 'en',
      theme: map['theme'] ?? 'system',
      currency: map['currency'] ?? 'USD',
      darkMode: map['darkMode'] ?? false,
      biometricAuth: map['biometricAuth'] ?? false,
      soundEnabled: map['soundEnabled'] ?? true,
      vibrationEnabled: map['vibrationEnabled'] ?? true,

      // Project management
      autoSaveDrafts: map['autoSaveDrafts'] ?? true,
      showProjectHistory: map['showProjectHistory'] ?? true,
      enableProjectSharing: map['enableProjectSharing'] ?? false,
      maxActiveProjects: map['maxActiveProjects'] ?? 5,
      showProjectTimeline: map['showProjectTimeline'] ?? true,
      enableProjectNotifications: map['enableProjectNotifications'] ?? true,

      // Location preferences
      enableLocationTracking: map['enableLocationTracking'] ?? true,
      notificationRadius: map['notificationRadius'] ?? 50,
      showNearbyServices: map['showNearbyServices'] ?? true,
      enableTransportCalculation: map['enableTransportCalculation'] ?? true,
      preferredTransportMode: map['preferredTransportMode'] ?? 'Auto',

      // Custom preferences
      customPreferences: Map<String, dynamic>.from(
        map['customPreferences'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,

      // Notifications
      'pushNotifications': pushNotifications,
      'emailNotifications': emailNotifications,
      'smsNotifications': smsNotifications,
      'projectUpdates': projectUpdates,
      'serviceAlerts': serviceAlerts,
      'priceChanges': priceChanges,
      'maintenanceReminders': maintenanceReminders,

      // Engineering services
      'preferredServiceCategories': preferredServiceCategories,
      'preferredProjectTypes': preferredProjectTypes,
      'autoLocationServices': autoLocationServices,
      'showProjectDistance': showProjectDistance,
      'showTransportCosts': showTransportCosts,
      'showProjectProgress': showProjectProgress,
      'preferredProjectSize': preferredProjectSize,
      'preferredBudgetRange': preferredBudgetRange,

      // App preferences
      'language': language,
      'theme': theme,
      'currency': currency,
      'darkMode': darkMode,
      'biometricAuth': biometricAuth,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,

      // Project management
      'autoSaveDrafts': autoSaveDrafts,
      'showProjectHistory': showProjectHistory,
      'enableProjectSharing': enableProjectSharing,
      'maxActiveProjects': maxActiveProjects,
      'showProjectTimeline': showProjectTimeline,
      'enableProjectNotifications': enableProjectNotifications,

      // Location preferences
      'enableLocationTracking': enableLocationTracking,
      'notificationRadius': notificationRadius,
      'showNearbyServices': showNearbyServices,
      'enableTransportCalculation': enableTransportCalculation,
      'preferredTransportMode': preferredTransportMode,

      // Custom preferences
      'customPreferences': customPreferences,
    };
  }

  UserSettings copyWith({
    String? userId,

    // Notifications
    bool? pushNotifications,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? projectUpdates,
    bool? serviceAlerts,
    bool? priceChanges,
    bool? maintenanceReminders,

    // Engineering services
    List<String>? preferredServiceCategories,
    List<String>? preferredProjectTypes,
    bool? autoLocationServices,
    bool? showProjectDistance,
    bool? showTransportCosts,
    bool? showProjectProgress,
    String? preferredProjectSize,
    String? preferredBudgetRange,

    // App preferences
    String? language,
    String? theme,
    String? currency,
    bool? darkMode,
    bool? biometricAuth,
    bool? soundEnabled,
    bool? vibrationEnabled,

    // Project management
    bool? autoSaveDrafts,
    bool? showProjectHistory,
    bool? enableProjectSharing,
    int? maxActiveProjects,
    bool? showProjectTimeline,
    bool? enableProjectNotifications,

    // Location preferences
    bool? enableLocationTracking,
    int? notificationRadius,
    bool? showNearbyServices,
    bool? enableTransportCalculation,
    String? preferredTransportMode,

    // Custom preferences
    Map<String, dynamic>? customPreferences,
  }) {
    return UserSettings(
      userId: userId ?? this.userId,

      // Notifications
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      projectUpdates: projectUpdates ?? this.projectUpdates,
      serviceAlerts: serviceAlerts ?? this.serviceAlerts,
      priceChanges: priceChanges ?? this.priceChanges,
      maintenanceReminders: maintenanceReminders ?? this.maintenanceReminders,

      // Engineering services
      preferredServiceCategories:
          preferredServiceCategories ?? this.preferredServiceCategories,
      preferredProjectTypes:
          preferredProjectTypes ?? this.preferredProjectTypes,
      autoLocationServices: autoLocationServices ?? this.autoLocationServices,
      showProjectDistance: showProjectDistance ?? this.showProjectDistance,
      showTransportCosts: showTransportCosts ?? this.showTransportCosts,
      showProjectProgress: showProjectProgress ?? this.showProjectProgress,
      preferredProjectSize: preferredProjectSize ?? this.preferredProjectSize,
      preferredBudgetRange: preferredBudgetRange ?? this.preferredBudgetRange,

      // App preferences
      language: language ?? this.language,
      theme: theme ?? this.theme,
      currency: currency ?? this.currency,
      darkMode: darkMode ?? this.darkMode,
      biometricAuth: biometricAuth ?? this.biometricAuth,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,

      // Project management
      autoSaveDrafts: autoSaveDrafts ?? this.autoSaveDrafts,
      showProjectHistory: showProjectHistory ?? this.showProjectHistory,
      enableProjectSharing: enableProjectSharing ?? this.enableProjectSharing,
      maxActiveProjects: maxActiveProjects ?? this.maxActiveProjects,
      showProjectTimeline: showProjectTimeline ?? this.showProjectTimeline,
      enableProjectNotifications:
          enableProjectNotifications ?? this.enableProjectNotifications,

      // Location preferences
      enableLocationTracking:
          enableLocationTracking ?? this.enableLocationTracking,
      notificationRadius: notificationRadius ?? this.notificationRadius,
      showNearbyServices: showNearbyServices ?? this.showNearbyServices,
      enableTransportCalculation:
          enableTransportCalculation ?? this.enableTransportCalculation,
      preferredTransportMode:
          preferredTransportMode ?? this.preferredTransportMode,

      // Custom preferences
      customPreferences: customPreferences ?? this.customPreferences,
    );
  }
}
