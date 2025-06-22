import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Traffic Light
  String get trafficLight => _localizedString('traffic_light', {
    'en': 'Traffic Light',
    'ru': 'Светофор',
    'pl': 'Sygnalizacja świetlna',
  });

  String get trafficLightMonitor => _localizedString('traffic_light_monitor', {
    'en': 'Traffic Light Monitor',
    'ru': 'Монитор светофора',
    'pl': 'Monitor sygnalizacji',
  });

  // Colors
  String get red => _localizedString('red', {
    'en': 'Red',
    'ru': 'Красный',
    'pl': 'Czerwony',
  });

  String get yellow => _localizedString('yellow', {
    'en': 'Yellow',
    'ru': 'Жёлтый',
    'pl': 'Żółty',
  });

  String get green => _localizedString('green', {
    'en': 'Green',
    'ru': 'Зелёный',
    'pl': 'Zielony',
  });

  // Settings
  String get settings => _localizedString('settings', {
    'en': 'Settings',
    'ru': 'Настройки',
    'pl': 'Ustawienia',
  });

  String get overlaySettings => _localizedString('overlay_settings', {
    'en': 'Overlay Settings',
    'ru': 'Настройки наложения',
    'pl': 'Ustawienia nakładki',
  });

  String get enableOverlay => _localizedString('enable_overlay', {
    'en': 'Enable Overlay',
    'ru': 'Включить наложение',
    'pl': 'Włącz nakładkę',
  });

  String get transparency => _localizedString('transparency', {
    'en': 'Transparency',
    'ru': 'Прозрачность',
    'pl': 'Przezroczystość',
  });

  String get size => _localizedString('size', {
    'en': 'Size',
    'ru': 'Размер',
    'pl': 'Rozmiar',
  });

  String get resetPosition => _localizedString('reset_position', {
    'en': 'Reset Position',
    'ru': 'Сбросить позицию',
    'pl': 'Resetuj pozycję',
  });

  // Connection
  String get connectionSettings => _localizedString('connection_settings', {
    'en': 'Connection Settings',
    'ru': 'Настройки подключения',
    'pl': 'Ustawienia połączenia',
  });

  String get wifi => _localizedString('wifi', {
    'en': 'Wi-Fi',
    'ru': 'Wi-Fi',
    'pl': 'Wi-Fi',
  });

  String get bluetooth => _localizedString('bluetooth', {
    'en': 'Bluetooth',
    'ru': 'Bluetooth',
    'pl': 'Bluetooth',
  });

  String get connected => _localizedString('connected', {
    'en': 'Connected',
    'ru': 'Подключено',
    'pl': 'Połączono',
  });

  String get disconnected => _localizedString('disconnected', {
    'en': 'Disconnected',
    'ru': 'Отключено',
    'pl': 'Rozłączono',
  });

  // Demo Mode
  String get demoMode => _localizedString('demo_mode', {
    'en': 'Demo Mode',
    'ru': 'Демо режим',
    'pl': 'Tryb demo',
  });

  String get testOverlay => _localizedString('test_overlay', {
    'en': 'Test Overlay',
    'ru': 'Тест наложения',
    'pl': 'Test nakładki',
  });

  // Event Log
  String get eventLog => _localizedString('event_log', {
    'en': 'Event Log',
    'ru': 'Журнал событий',
    'pl': 'Dziennik zdarzeń',
  });

  String get exportLog => _localizedString('export_log', {
    'en': 'Export Log',
    'ru': 'Экспорт журнала',
    'pl': 'Eksportuj dziennik',
  });

  String get clearLog => _localizedString('clear_log', {
    'en': 'Clear Log',
    'ru': 'Очистить журнал',
    'pl': 'Wyczyść dziennik',
  });

  // Notifications
  String get notifications => _localizedString('notifications', {
    'en': 'Notifications',
    'ru': 'Уведомления',
    'pl': 'Powiadomienia',
  });

  String get soundNotifications => _localizedString('sound_notifications', {
    'en': 'Sound Notifications',
    'ru': 'Звуковые уведомления',
    'pl': 'Powiadomienia dźwiękowe',
  });

  String get vibrationNotifications => _localizedString('vibration_notifications', {
    'en': 'Vibration Notifications',
    'ru': 'Виброуведомления',
    'pl': 'Powiadomienia wibracjami',
  });

  String _localizedString(String key, Map<String, String> translations) {
    return translations[locale.languageCode] ?? translations['en'] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ru', 'pl'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}