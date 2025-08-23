class UserSettings {
  final String userId;
  
  // Essential App Settings
  final bool darkMode;
  final String language;
  final String currency;
  
  // Engineering App Specific Settings
  final bool showProjectProgress;
  final bool showServicePricing;
  final bool showTransportCosts;
  final bool showEngineeringSpecs;
  final bool showTechnicalDrawings;
  final bool locationBasedServices;
  final int notificationRadius;
  
  // Notification Settings
  final bool pushNotifications;
  final bool emailNotifications;
  final bool projectUpdatesNotifications;
  final bool quoteNotifications;

  UserSettings({
    required this.userId,
    
    // Essential App Settings
    this.darkMode = false,
    this.language = 'en',
    this.currency = 'USD',
    
    // Engineering App Specific Settings
    this.showProjectProgress = true,
    this.showServicePricing = true,
    this.showTransportCosts = true,
    this.showEngineeringSpecs = true,
    this.showTechnicalDrawings = true,
    this.locationBasedServices = true,
    this.notificationRadius = 50,
    
    // Notification Settings
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.projectUpdatesNotifications = true,
    this.quoteNotifications = true,
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      userId: map['userId'] ?? '',
      
      // Essential App Settings
      darkMode: map['darkMode'] ?? false,
      language: map['language'] ?? 'en',
      currency: map['currency'] ?? 'USD',
      
      // Engineering App Specific Settings
      showProjectProgress: map['showProjectProgress'] ?? true,
      showServicePricing: map['showServicePricing'] ?? true,
      showTransportCosts: map['showTransportCosts'] ?? true,
      showEngineeringSpecs: map['showEngineeringSpecs'] ?? true,
      showTechnicalDrawings: map['showTechnicalDrawings'] ?? true,
      locationBasedServices: map['locationBasedServices'] ?? true,
      notificationRadius: map['notificationRadius'] ?? 50,
      
      // Notification Settings
      pushNotifications: map['pushNotifications'] ?? true,
      emailNotifications: map['emailNotifications'] ?? true,
      projectUpdatesNotifications: map['projectUpdatesNotifications'] ?? true,
      quoteNotifications: map['quoteNotifications'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      
      // Essential App Settings
      'darkMode': darkMode,
      'language': language,
      'currency': currency,
      
      // Engineering App Specific Settings
      'showProjectProgress': showProjectProgress,
      'showServicePricing': showServicePricing,
      'showTransportCosts': showTransportCosts,
      'showEngineeringSpecs': showEngineeringSpecs,
      'showTechnicalDrawings': showTechnicalDrawings,
      'locationBasedServices': locationBasedServices,
      'notificationRadius': notificationRadius,
      
      // Notification Settings
      'pushNotifications': pushNotifications,
      'emailNotifications': emailNotifications,
      'projectUpdatesNotifications': projectUpdatesNotifications,
      'quoteNotifications': quoteNotifications,
    };
  }

  UserSettings copyWith({
    String? userId,
    
    // Essential App Settings
    bool? darkMode,
    String? language,
    String? currency,
    
    // Engineering App Specific Settings
    bool? showProjectProgress,
    bool? showServicePricing,
    bool? showTransportCosts,
    bool? showEngineeringSpecs,
    bool? showTechnicalDrawings,
    bool? locationBasedServices,
    int? notificationRadius,
    
    // Notification Settings
    bool? pushNotifications,
    bool? emailNotifications,
    bool? projectUpdatesNotifications,
    bool? quoteNotifications,
  }) {
    return UserSettings(
      userId: userId ?? this.userId,
      
      // Essential App Settings
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      
      // Engineering App Specific Settings
      showProjectProgress: showProjectProgress ?? this.showProjectProgress,
      showServicePricing: showServicePricing ?? this.showServicePricing,
      showTransportCosts: showTransportCosts ?? this.showTransportCosts,
      showEngineeringSpecs: showEngineeringSpecs ?? this.showEngineeringSpecs,
      showTechnicalDrawings: showTechnicalDrawings ?? this.showTechnicalDrawings,
      locationBasedServices: locationBasedServices ?? this.locationBasedServices,
      notificationRadius: notificationRadius ?? this.notificationRadius,
      
      // Notification Settings
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      projectUpdatesNotifications: projectUpdatesNotifications ?? this.projectUpdatesNotifications,
      quoteNotifications: quoteNotifications ?? this.quoteNotifications,
    );
  }
}
