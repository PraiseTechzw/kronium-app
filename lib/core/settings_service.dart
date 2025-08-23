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

  // Simple update setting method
  Future<void> updateSetting<T>(String key, T value) async {
    try {
      final currentSettings = _settings.value;
      UserSettings updatedSettings;

      switch (key) {
        // Essential App Settings
        case 'darkMode':
          updatedSettings = currentSettings.copyWith(darkMode: value as bool);
          break;
        case 'language':
          updatedSettings = currentSettings.copyWith(language: value as String);
          break;
        case 'currency':
          updatedSettings = currentSettings.copyWith(currency: value as String);
          break;

        // Engineering App Specific Settings
        case 'showProjectProgress':
          updatedSettings = currentSettings.copyWith(
            showProjectProgress: value as bool,
          );
          break;
        case 'showServicePricing':
          updatedSettings = currentSettings.copyWith(
            showServicePricing: value as bool,
          );
          break;
        case 'showTransportCosts':
          updatedSettings = currentSettings.copyWith(
            showTransportCosts: value as bool,
          );
          break;
        case 'showEngineeringSpecs':
          updatedSettings = currentSettings.copyWith(
            showEngineeringSpecs: value as bool,
          );
          break;
        case 'showTechnicalDrawings':
          updatedSettings = currentSettings.copyWith(
            showTechnicalDrawings: value as bool,
          );
          break;
        case 'locationBasedServices':
          updatedSettings = currentSettings.copyWith(
            locationBasedServices: value as bool,
          );
          break;
        case 'notificationRadius':
          updatedSettings = currentSettings.copyWith(
            notificationRadius: value as int,
          );
          break;

        // Notification Settings
        case 'pushNotifications':
          updatedSettings = currentSettings.copyWith(
            pushNotifications: value as bool,
          );
          break;
        case 'emailNotifications':
          updatedSettings = currentSettings.copyWith(
            emailNotifications: value as bool,
          );
          break;
        case 'projectUpdatesNotifications':
          updatedSettings = currentSettings.copyWith(
            projectUpdatesNotifications: value as bool,
          );
          break;
        case 'quoteNotifications':
          updatedSettings = currentSettings.copyWith(
            quoteNotifications: value as bool,
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

  // Convenience methods for common settings
  Future<void> toggleDarkMode() async {
    await updateSetting('darkMode', !_settings.value.darkMode);
  }

  Future<void> updateLanguage(String language) async {
    await updateSetting('language', language);
  }

  Future<void> updateCurrency(String currency) async {
    await updateSetting('currency', currency);
  }

  Future<void> toggleProjectProgressVisibility() async {
    await updateSetting(
      'showProjectProgress',
      !_settings.value.showProjectProgress,
    );
  }

  Future<void> toggleServicePricingVisibility() async {
    await updateSetting(
      'showServicePricing',
      !_settings.value.showServicePricing,
    );
  }

  Future<void> toggleTransportCostsVisibility() async {
    await updateSetting(
      'showTransportCosts',
      !_settings.value.showTransportCosts,
    );
  }

  Future<void> toggleEngineeringSpecsVisibility() async {
    await updateSetting(
      'showEngineeringSpecs',
      !_settings.value.showEngineeringSpecs,
    );
  }

  Future<void> toggleTechnicalDrawingsVisibility() async {
    await updateSetting(
      'showTechnicalDrawings',
      !_settings.value.showTechnicalDrawings,
    );
  }

  Future<void> toggleLocationBasedServices() async {
    await updateSetting(
      'locationBasedServices',
      !_settings.value.locationBasedServices,
    );
  }

  Future<void> updateNotificationRadius(int radius) async {
    await updateSetting('notificationRadius', radius);
  }

  Future<void> togglePushNotifications() async {
    await updateSetting(
      'pushNotifications',
      !_settings.value.pushNotifications,
    );
  }

  Future<void> toggleEmailNotifications() async {
    await updateSetting(
      'emailNotifications',
      !_settings.value.emailNotifications,
    );
  }

  Future<void> toggleProjectUpdatesNotifications() async {
    await updateSetting(
      'projectUpdatesNotifications',
      !_settings.value.projectUpdatesNotifications,
    );
  }

  Future<void> toggleQuoteNotifications() async {
    await updateSetting(
      'quoteNotifications',
      !_settings.value.quoteNotifications,
    );
  }

  Future<void> resetToDefaults() async {
    try {
      final defaultSettings = UserSettings(userId: _settings.value.userId);
      await saveSettings(defaultSettings);
    } catch (e) {
      print('Error resetting settings: $e');
    }
  }

  // Getters for easy access to settings
  bool get isDarkMode => _settings.value.darkMode;
  String get currentLanguage => _settings.value.language;
  String get currentCurrency => _settings.value.currency;

  bool get showProjectProgress => _settings.value.showProjectProgress;
  bool get showServicePricing => _settings.value.showServicePricing;
  bool get showTransportCosts => _settings.value.showTransportCosts;
  bool get showEngineeringSpecs => _settings.value.showEngineeringSpecs;
  bool get showTechnicalDrawings => _settings.value.showTechnicalDrawings;
  bool get locationBasedServices => _settings.value.locationBasedServices;
  int get notificationRadius => _settings.value.notificationRadius;

  bool get pushNotificationsEnabled => _settings.value.pushNotifications;
  bool get emailNotificationsEnabled => _settings.value.emailNotifications;
  bool get projectUpdatesEnabled => _settings.value.projectUpdatesNotifications;
  bool get quoteNotificationsEnabled => _settings.value.quoteNotifications;
}
