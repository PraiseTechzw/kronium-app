import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../models/settings_model.dart';

class SettingsService extends GetxService {
  static SettingsService get to => Get.find();

  final Rx<UserSettings> _settings = UserSettings(userId: '').obs;
  UserSettings get settings => _settings.value;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsData = prefs.getString('user_settings');

      if (settingsData != null) {
        // Parse settings from JSON
        final Map<String, dynamic> settingsMap = Map<String, dynamic>.from(
          settingsData as Map<String, dynamic>,
        );
        _settings.value = UserSettings.fromMap(settingsMap);
      }
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> saveSettings(UserSettings newSettings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_settings', newSettings.toMap().toString());
      _settings.value = newSettings;
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  // Update notification settings
  Future<void> updateNotificationSettings({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? projectUpdates,
    bool? serviceAlerts,
    bool? priceChanges,
    bool? maintenanceReminders,
  }) async {
    try {
      final currentSettings = _settings.value;
      final updatedSettings = currentSettings.copyWith(
        pushNotifications:
            pushNotifications ?? currentSettings.pushNotifications,
        emailNotifications:
            emailNotifications ?? currentSettings.emailNotifications,
        smsNotifications: smsNotifications ?? currentSettings.smsNotifications,
        projectUpdates: projectUpdates ?? currentSettings.projectUpdates,
        serviceAlerts: serviceAlerts ?? currentSettings.serviceAlerts,
        priceChanges: priceChanges ?? currentSettings.priceChanges,
        maintenanceReminders:
            maintenanceReminders ?? currentSettings.maintenanceReminders,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      print('Error updating notification settings: $e');
    }
  }

  // Update engineering service preferences
  Future<void> updateServicePreferences({
    List<String>? preferredServiceCategories,
    List<String>? preferredProjectTypes,
    bool? autoLocationServices,
    bool? showProjectDistance,
    bool? showTransportCosts,
    bool? showProjectProgress,
    String? preferredProjectSize,
    String? preferredBudgetRange,
  }) async {
    try {
      final currentSettings = _settings.value;
      final updatedSettings = currentSettings.copyWith(
        preferredServiceCategories:
            preferredServiceCategories ??
            currentSettings.preferredServiceCategories,
        preferredProjectTypes:
            preferredProjectTypes ?? currentSettings.preferredProjectTypes,
        autoLocationServices:
            autoLocationServices ?? currentSettings.autoLocationServices,
        showProjectDistance:
            showProjectDistance ?? currentSettings.showProjectDistance,
        showTransportCosts:
            showTransportCosts ?? currentSettings.showTransportCosts,
        showProjectProgress:
            showProjectProgress ?? currentSettings.showProjectProgress,
        preferredProjectSize:
            preferredProjectSize ?? currentSettings.preferredProjectSize,
        preferredBudgetRange:
            preferredBudgetRange ?? currentSettings.preferredBudgetRange,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      print('Error updating service preferences: $e');
    }
  }

  // Update app preferences
  Future<void> updateAppPreferences({
    String? language,
    String? theme,
    String? currency,
    bool? darkMode,
    bool? biometricAuth,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) async {
    try {
      final currentSettings = _settings.value;
      final updatedSettings = currentSettings.copyWith(
        language: language ?? currentSettings.language,
        theme: theme ?? currentSettings.theme,
        currency: currency ?? currentSettings.currency,
        darkMode: darkMode ?? currentSettings.darkMode,
        biometricAuth: biometricAuth ?? currentSettings.biometricAuth,
        soundEnabled: soundEnabled ?? currentSettings.soundEnabled,
        vibrationEnabled: vibrationEnabled ?? currentSettings.vibrationEnabled,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      print('Error updating app preferences: $e');
    }
  }

  // Update project management preferences
  Future<void> updateProjectPreferences({
    bool? autoSaveDrafts,
    bool? showProjectHistory,
    bool? enableProjectSharing,
    int? maxActiveProjects,
    bool? showProjectTimeline,
    bool? enableProjectNotifications,
  }) async {
    try {
      final currentSettings = _settings.value;
      final updatedSettings = currentSettings.copyWith(
        autoSaveDrafts: autoSaveDrafts ?? currentSettings.autoSaveDrafts,
        showProjectHistory:
            showProjectHistory ?? currentSettings.showProjectHistory,
        enableProjectSharing:
            enableProjectSharing ?? currentSettings.enableProjectSharing,
        maxActiveProjects:
            maxActiveProjects ?? currentSettings.maxActiveProjects,
        showProjectTimeline:
            showProjectTimeline ?? currentSettings.showProjectTimeline,
        enableProjectNotifications:
            enableProjectNotifications ??
            currentSettings.enableProjectNotifications,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      print('Error updating project preferences: $e');
    }
  }

  // Update location and transport preferences
  Future<void> updateLocationPreferences({
    bool? enableLocationTracking,
    int? notificationRadius,
    bool? showNearbyServices,
    bool? enableTransportCalculation,
    String? preferredTransportMode,
  }) async {
    try {
      final currentSettings = _settings.value;
      final updatedSettings = currentSettings.copyWith(
        enableLocationTracking:
            enableLocationTracking ?? currentSettings.enableLocationTracking,
        notificationRadius:
            notificationRadius ?? currentSettings.notificationRadius,
        showNearbyServices:
            showNearbyServices ?? currentSettings.showNearbyServices,
        enableTransportCalculation:
            enableTransportCalculation ??
            currentSettings.enableTransportCalculation,
        preferredTransportMode:
            preferredTransportMode ?? currentSettings.preferredTransportMode,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      print('Error updating location preferences: $e');
    }
  }

  // Generic update method for any setting
  Future<void> updateSetting<T>(String key, T value) async {
    try {
      final currentSettings = _settings.value;
      UserSettings updatedSettings;

      switch (key) {
        // Notification settings
        case 'pushNotifications':
        case 'emailNotifications':
        case 'smsNotifications':
        case 'projectUpdates':
        case 'serviceAlerts':
        case 'priceChanges':
        case 'maintenanceReminders':
          updatedSettings = currentSettings.copyWith(
            pushNotifications:
                key == 'pushNotifications'
                    ? value as bool
                    : currentSettings.pushNotifications,
            emailNotifications:
                key == 'emailNotifications'
                    ? value as bool
                    : currentSettings.emailNotifications,
            smsNotifications:
                key == 'smsNotifications'
                    ? value as bool
                    : currentSettings.smsNotifications,
            projectUpdates:
                key == 'projectUpdates'
                    ? value as bool
                    : currentSettings.projectUpdates,
            serviceAlerts:
                key == 'serviceAlerts'
                    ? value as bool
                    : currentSettings.serviceAlerts,
            priceChanges:
                key == 'priceChanges'
                    ? value as bool
                    : currentSettings.priceChanges,
            maintenanceReminders:
                key == 'maintenanceReminders'
                    ? value as bool
                    : currentSettings.maintenanceReminders,
          );
          break;

        // Service preferences
        case 'preferredServiceCategories':
        case 'preferredProjectTypes':
        case 'autoLocationServices':
        case 'showProjectDistance':
        case 'showTransportCosts':
        case 'showProjectProgress':
        case 'preferredProjectSize':
        case 'preferredBudgetRange':
          updatedSettings = currentSettings.copyWith(
            preferredServiceCategories:
                key == 'preferredServiceCategories'
                    ? value as List<String>
                    : currentSettings.preferredServiceCategories,
            preferredProjectTypes:
                key == 'preferredProjectTypes'
                    ? value as List<String>
                    : currentSettings.preferredProjectTypes,
            autoLocationServices:
                key == 'autoLocationServices'
                    ? value as bool
                    : currentSettings.autoLocationServices,
            showProjectDistance:
                key == 'showProjectDistance'
                    ? value as bool
                    : currentSettings.showProjectDistance,
            showTransportCosts:
                key == 'showTransportCosts'
                    ? value as bool
                    : currentSettings.showTransportCosts,
            showProjectProgress:
                key == 'showProjectProgress'
                    ? value as bool
                    : currentSettings.showProjectProgress,
            preferredProjectSize:
                key == 'preferredProjectSize'
                    ? value as String
                    : currentSettings.preferredProjectSize,
            preferredBudgetRange:
                key == 'preferredBudgetRange'
                    ? value as String
                    : currentSettings.preferredBudgetRange,
          );
          break;

        // App preferences
        case 'language':
        case 'theme':
        case 'currency':
        case 'darkMode':
        case 'biometricAuth':
        case 'soundEnabled':
        case 'vibrationEnabled':
          updatedSettings = currentSettings.copyWith(
            language:
                key == 'language' ? value as String : currentSettings.language,
            theme: key == 'theme' ? value as String : currentSettings.theme,
            currency:
                key == 'currency' ? value as String : currentSettings.currency,
            darkMode:
                key == 'darkMode' ? value as bool : currentSettings.darkMode,
            biometricAuth:
                key == 'biometricAuth'
                    ? value as bool
                    : currentSettings.biometricAuth,
            soundEnabled:
                key == 'soundEnabled'
                    ? value as bool
                    : currentSettings.soundEnabled,
            vibrationEnabled:
                key == 'vibrationEnabled'
                    ? value as bool
                    : currentSettings.vibrationEnabled,
          );
          break;

        // Project management preferences
        case 'autoSaveDrafts':
        case 'showProjectHistory':
        case 'enableProjectSharing':
        case 'maxActiveProjects':
        case 'showProjectTimeline':
        case 'enableProjectNotifications':
          updatedSettings = currentSettings.copyWith(
            autoSaveDrafts:
                key == 'autoSaveDrafts'
                    ? value as bool
                    : currentSettings.autoSaveDrafts,
            showProjectHistory:
                key == 'showProjectHistory'
                    ? value as bool
                    : currentSettings.showProjectHistory,
            enableProjectSharing:
                key == 'enableProjectSharing'
                    ? value as bool
                    : currentSettings.enableProjectSharing,
            maxActiveProjects:
                key == 'maxActiveProjects'
                    ? value as int
                    : currentSettings.maxActiveProjects,
            showProjectTimeline:
                key == 'showProjectTimeline'
                    ? value as bool
                    : currentSettings.showProjectTimeline,
            enableProjectNotifications:
                key == 'enableProjectNotifications'
                    ? value as bool
                    : currentSettings.enableProjectNotifications,
          );
          break;

        // Location preferences
        case 'enableLocationTracking':
        case 'notificationRadius':
        case 'showNearbyServices':
        case 'enableTransportCalculation':
        case 'preferredTransportMode':
          updatedSettings = currentSettings.copyWith(
            enableLocationTracking:
                key == 'enableLocationTracking'
                    ? value as bool
                    : currentSettings.enableLocationTracking,
            notificationRadius:
                key == 'notificationRadius'
                    ? value as int
                    : currentSettings.notificationRadius,
            showNearbyServices:
                key == 'showNearbyServices'
                    ? value as bool
                    : currentSettings.showNearbyServices,
            enableTransportCalculation:
                key == 'enableTransportCalculation'
                    ? value as bool
                    : currentSettings.enableTransportCalculation,
            preferredTransportMode:
                key == 'preferredTransportMode'
                    ? value as String
                    : currentSettings.preferredTransportMode,
          );
          break;

        default:
          print('Unknown setting key: $key');
          return;
      }

      await saveSettings(updatedSettings);
    } catch (e) {
      print('Error updating setting: $e');
    }
  }

  Future<void> resetToDefaults() async {
    try {
      final defaultSettings = UserSettings(userId: _settings.value.userId);
      await saveSettings(defaultSettings);
    } catch (e) {
      print('Error resetting settings: $e');
    }
  }

  // Getters for commonly used settings
  bool get isDarkMode => _settings.value.darkMode;
  bool get pushNotificationsEnabled => _settings.value.pushNotifications;
  bool get emailNotificationsEnabled => _settings.value.emailNotifications;
  bool get projectUpdatesEnabled => _settings.value.projectUpdates;
  bool get serviceAlertsEnabled => _settings.value.serviceAlerts;
  String get currentLanguage => _settings.value.language;
  String get currentCurrency => _settings.value.currency;
  List<String> get preferredServices =>
      _settings.value.preferredServiceCategories;
  List<String> get preferredProjectTypes =>
      _settings.value.preferredProjectTypes;
  bool get locationTrackingEnabled => _settings.value.enableLocationTracking;
  bool get transportCalculationEnabled =>
      _settings.value.enableTransportCalculation;
}
