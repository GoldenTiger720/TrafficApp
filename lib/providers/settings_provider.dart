import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class SettingsProvider extends ChangeNotifier {
  AppSettings _settings = const AppSettings();
  late SharedPreferences _prefs;

  AppSettings get settings => _settings;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settingsJson = _prefs.getString('app_settings');
    if (settingsJson != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(settingsJson);
        _settings = AppSettings.fromJson(json);
      } catch (e) {
        debugPrint('Error loading settings: $e');
        debugPrint('Clearing corrupted settings...');
        // Clear corrupted data
        await _prefs.remove('app_settings');
        _settings = const AppSettings();
      }
    }
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    try {
      final settingsJson = jsonEncode(_settings.toJson());
      await _prefs.setString('app_settings', settingsJson);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  Future<void> updateOverlayEnabled(bool enabled) async {
    _settings = _settings.copyWith(overlayEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> updateOverlayTransparency(double transparency) async {
    _settings = _settings.copyWith(overlayTransparency: transparency);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> updateOverlaySize(double size) async {
    _settings = _settings.copyWith(overlaySize: size);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> updateOverlayPosition(double x, double y) async {
    _settings = _settings.copyWith(overlayPositionX: x, overlayPositionY: y);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> resetOverlayPosition() async {
    _settings = _settings.copyWith(overlayPositionX: 0.5, overlayPositionY: 0.5);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> resetOverlaySettings() async {
    _settings = _settings.copyWith(
      overlayTransparency: 0.8,
      overlaySize: 1.0,
      overlayPositionX: 0.5,
      overlayPositionY: 0.5,
    );
    await _saveSettings();
    notifyListeners();
  }

  Future<void> updateConnectionType(ConnectionType type) async {
    _settings = _settings.copyWith(connectionType: type);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> updateSelectedDevice(String? deviceId) async {
    _settings = _settings.copyWith(selectedDeviceId: deviceId);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> updateSoundNotifications(bool enabled) async {
    _settings = _settings.copyWith(soundNotifications: enabled);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> updateVibrationNotifications(bool enabled) async {
    _settings = _settings.copyWith(vibrationNotifications: enabled);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> updateTheme(AppTheme theme) async {
    _settings = _settings.copyWith(theme: theme);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> updateLanguage(Language language) async {
    _settings = _settings.copyWith(language: language);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> updateDisplayMode(DisplayMode mode) async {
    _settings = _settings.copyWith(displayMode: mode);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> updateDemoMode(bool enabled) async {
    _settings = _settings.copyWith(demoMode: enabled);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> updateTotalDuration(int duration) async {
    _settings = _settings.copyWith(totalDuration: duration);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> updateCountdownDuration(int duration) async {
    _settings = _settings.copyWith(countdownDuration: duration);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> resetToDefaults() async {
    _settings = const AppSettings();
    await _saveSettings();
    notifyListeners();
  }
}