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

  Future<void> updateSetting<T>(String key, T value) async {
    try {
      final currentSettings = _settings.value;
      final updatedSettings = currentSettings.copyWith(
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
        language:
            key == 'language' ? value as String : currentSettings.language,
        theme: key == 'theme' ? value as String : currentSettings.theme,
        autoLocation:
            key == 'autoLocation'
                ? value as bool
                : currentSettings.autoLocation,
        showDistance:
            key == 'showDistance'
                ? value as bool
                : currentSettings.showDistance,
        currency:
            key == 'currency' ? value as String : currentSettings.currency,
        darkMode: key == 'darkMode' ? value as bool : currentSettings.darkMode,
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
        notificationRadius:
            key == 'notificationRadius'
                ? value as int
                : currentSettings.notificationRadius,
        projectNotifications:
            key == 'projectNotifications'
                ? value as bool
                : currentSettings.projectNotifications,
        bookingReminders:
            key == 'bookingReminders'
                ? value as bool
                : currentSettings.bookingReminders,
        serviceUpdates:
            key == 'serviceUpdates'
                ? value as bool
                : currentSettings.serviceUpdates,
        locationBasedServices:
            key == 'locationBasedServices'
                ? value as bool
                : currentSettings.locationBasedServices,
        preferredServiceRadius:
            key == 'preferredServiceRadius'
                ? value as String
                : currentSettings.preferredServiceRadius,
        showTransportCosts:
            key == 'showTransportCosts'
                ? value as bool
                : currentSettings.showTransportCosts,
        autoCalculateQuotes:
            key == 'autoCalculateQuotes'
                ? value as bool
                : currentSettings.autoCalculateQuotes,
      );

      await saveSettings(updatedSettings);
    } catch (e) {
      print('Error updating setting: $e');
    }
  }

  Future<void> updateNotificationPreferences(
    Map<String, bool> preferences,
  ) async {
    try {
      final currentSettings = _settings.value;
      final updatedSettings = currentSettings.copyWith(
        notificationPreferences: preferences,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      print('Error updating notification preferences: $e');
    }
  }

  Future<void> updateFavoriteServiceTypes(List<String> serviceTypes) async {
    try {
      final currentSettings = _settings.value;
      final updatedSettings = currentSettings.copyWith(
        favoriteServiceTypes: serviceTypes,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      print('Error updating favorite service types: $e');
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

  // Getters for easy access to settings
  bool get isDarkMode => _settings.value.darkMode;
  bool get pushNotificationsEnabled => _settings.value.pushNotifications;
  bool get emailNotificationsEnabled => _settings.value.emailNotifications;
  String get currentLanguage => _settings.value.language;
  String get currentCurrency => _settings.value.currency;
  bool get projectNotificationsEnabled => _settings.value.projectNotifications;
  bool get bookingRemindersEnabled => _settings.value.bookingReminders;
  bool get serviceUpdatesEnabled => _settings.value.serviceUpdates;
  bool get locationBasedServicesEnabled =>
      _settings.value.locationBasedServices;
  String get preferredServiceRadius => _settings.value.preferredServiceRadius;
  bool get showTransportCosts => _settings.value.showTransportCosts;
  bool get autoCalculateQuotes => _settings.value.autoCalculateQuotes;
  bool get biometricAuthEnabled => _settings.value.biometricAuth;
  List<String> get favoriteServiceTypes => _settings.value.favoriteServiceTypes;
  Map<String, bool> get notificationPreferences =>
      _settings.value.notificationPreferences;

  // Engineering-specific convenience methods
  Future<void> toggleProjectNotifications() async {
    await updateSetting(
      'projectNotifications',
      !_settings.value.projectNotifications,
    );
  }

  Future<void> toggleBookingReminders() async {
    await updateSetting('bookingReminders', !_settings.value.bookingReminders);
  }

  Future<void> toggleServiceUpdates() async {
    await updateSetting('serviceUpdates', !_settings.value.serviceUpdates);
  }

  Future<void> toggleLocationBasedServices() async {
    await updateSetting(
      'locationBasedServices',
      !_settings.value.locationBasedServices,
    );
  }

  Future<void> setPreferredServiceRadius(String radius) async {
    await updateSetting('preferredServiceRadius', radius);
  }

  Future<void> toggleTransportCosts() async {
    await updateSetting(
      'showTransportCosts',
      !_settings.value.showTransportCosts,
    );
  }

  Future<void> toggleAutoCalculateQuotes() async {
    await updateSetting(
      'autoCalculateQuotes',
      !_settings.value.autoCalculateQuotes,
    );
  }
}
