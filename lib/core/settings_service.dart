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
      );

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

  bool get isDarkMode => _settings.value.darkMode;
  bool get pushNotificationsEnabled => _settings.value.pushNotifications;
  bool get emailNotificationsEnabled => _settings.value.emailNotifications;
  String get currentLanguage => _settings.value.language;
  String get currentCurrency => _settings.value.currency;
}
