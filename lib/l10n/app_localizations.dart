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

  // Appearance
  String get appearance => _localizedString('appearance', {
    'en': 'Appearance',
    'ru': 'Внешний вид',
    'pl': 'Wygląd',
  });

  String get theme => _localizedString('theme', {
    'en': 'Theme',
    'ru': 'Тема',
    'pl': 'Motyw',
  });

  String get light => _localizedString('light', {
    'en': 'Light',
    'ru': 'Светлая',
    'pl': 'Jasny',
  });

  String get dark => _localizedString('dark', {
    'en': 'Dark',
    'ru': 'Тёмная',
    'pl': 'Ciemny',
  });

  String get system => _localizedString('system', {
    'en': 'System',
    'ru': 'Системная',
    'pl': 'Systemowy',
  });

  String get language => _localizedString('language', {
    'en': 'Language',
    'ru': 'Язык',
    'pl': 'Język',
  });

  String get displayMode => _localizedString('display_mode', {
    'en': 'Display Mode',
    'ru': 'Режим отображения',
    'pl': 'Tryb wyświetlania',
  });

  String get minimalistic => _localizedString('minimalistic', {
    'en': 'Minimalistic',
    'ru': 'Минималистичный',
    'pl': 'Minimalistyczny',
  });

  String get advanced => _localizedString('advanced', {
    'en': 'Advanced',
    'ru': 'Расширенный',
    'pl': 'Zaawansowany',
  });

  // Developer Options
  String get developerOptions => _localizedString('developer_options', {
    'en': 'Developer Options',
    'ru': 'Параметры разработчика',
    'pl': 'Opcje programisty',
  });

  String get manualOverlayTest => _localizedString('manual_overlay_test', {
    'en': 'Manual Overlay Test',
    'ru': 'Ручной тест наложения',
    'pl': 'Ręczny test nakładki',
  });

  String get testOverlayColors => _localizedString('test_overlay_colors', {
    'en': 'Test overlay colors manually',
    'ru': 'Тестировать цвета наложения вручную',
    'pl': 'Testuj kolory nakładki ręcznie',
  });

  // Data & Privacy
  String get dataPrivacy => _localizedString('data_privacy', {
    'en': 'Data & Privacy',
    'ru': 'Данные и конфиденциальность',
    'pl': 'Dane i prywatność',
  });

  String get exportEventLog => _localizedString('export_event_log', {
    'en': 'Export Event Log',
    'ru': 'Экспорт журнала событий',
    'pl': 'Eksportuj dziennik zdarzeń',
  });

  String get shareEventLogForDebugging => _localizedString('share_event_log_for_debugging', {
    'en': 'Share event log for debugging',
    'ru': 'Поделиться журналом событий для отладки',
    'pl': 'Udostępnij dziennik zdarzeń do debugowania',
  });

  String get clearEventLog => _localizedString('clear_event_log', {
    'en': 'Clear Event Log',
    'ru': 'Очистить журнал событий',
    'pl': 'Wyczyść dziennik zdarzeń',
  });

  String get deleteAllLoggedEvents => _localizedString('delete_all_logged_events', {
    'en': 'Delete all logged events',
    'ru': 'Удалить все записанные события',
    'pl': 'Usuń wszystkie zapisane zdarzenia',
  });

  // Connection
  String get availableDevices => _localizedString('available_devices', {
    'en': 'Available Devices',
    'ru': 'Доступные устройства',
    'pl': 'Dostępne urządzenia',
  });

  String get scanning => _localizedString('scanning', {
    'en': 'Scanning...',
    'ru': 'Сканирование...',
    'pl': 'Skanowanie...',
  });

  String devicesFound(int count) => _localizedString('devices_found', {
    'en': '$count devices found',
    'ru': 'Найдено устройств: $count',
    'pl': 'Znaleziono urządzeń: $count',
  });

  String get testConnection => _localizedString('test_connection', {
    'en': 'Test Connection',
    'ru': 'Проверить подключение',
    'pl': 'Testuj połączenie',
  });

  String get test => _localizedString('test', {
    'en': 'Test',
    'ru': 'Тест',
    'pl': 'Test',
  });

  String get reset => _localizedString('reset', {
    'en': 'Reset',
    'ru': 'Сбросить',
    'pl': 'Resetuj',
  });

  String get moveOverlayToCenter => _localizedString('move_overlay_to_center', {
    'en': 'Move overlay to center',
    'ru': 'Переместить наложение в центр',
    'pl': 'Przenieś nakładkę do środka',
  });

  // Dialog messages
  String get pleaseSelectDeviceFirst => _localizedString('please_select_device_first', {
    'en': 'Please select a device first',
    'ru': 'Сначала выберите устройство',
    'pl': 'Najpierw wybierz urządzenie',
  });

  String get connectionSuccessful => _localizedString('connection_successful', {
    'en': 'Connection successful!',
    'ru': 'Подключение успешно!',
    'pl': 'Połączenie udane!',
  });

  String get connectionFailed => _localizedString('connection_failed', {
    'en': 'Connection failed',
    'ru': 'Подключение не удалось',
    'pl': 'Połączenie nieudane',
  });

  String connectionError(String error) => _localizedString('connection_error', {
    'en': 'Connection error: $error',
    'ru': 'Ошибка подключения: $error',
    'pl': 'Błąd połączenia: $error',
  });

  String get eventLogExportedSuccessfully => _localizedString('event_log_exported_successfully', {
    'en': 'Event log exported successfully',
    'ru': 'Журнал событий успешно экспортирован',
    'pl': 'Dziennik zdarzeń wyeksportowany pomyślnie',
  });

  String exportFailed(String error) => _localizedString('export_failed', {
    'en': 'Export failed: $error',
    'ru': 'Экспорт не удался: $error',
    'pl': 'Eksport nieudany: $error',
  });

  String get clearEventLogConfirm => _localizedString('clear_event_log_confirm', {
    'en': 'This will permanently delete all logged events. Continue?',
    'ru': 'Это навсегда удалит все записанные события. Продолжить?',
    'pl': 'To trwale usunie wszystkie zapisane zdarzenia. Kontynuować?',
  });

  String get cancel => _localizedString('cancel', {
    'en': 'Cancel',
    'ru': 'Отмена',
    'pl': 'Anuluj',
  });

  String get clear => _localizedString('clear', {
    'en': 'Clear',
    'ru': 'Очистить',
    'pl': 'Wyczyść',
  });

  String get eventLogCleared => _localizedString('event_log_cleared', {
    'en': 'Event log cleared',
    'ru': 'Журнал событий очищен',
    'pl': 'Dziennik zdarzeń wyczyszczony',
  });

  String errorScanningForDevices(String error) => _localizedString('error_scanning_for_devices', {
    'en': 'Error scanning for devices: $error',
    'ru': 'Ошибка сканирования устройств: $error',
    'pl': 'Błąd skanowania urządzeń: $error',
  });

  // Main Screen
  String get deviceConnected => _localizedString('device_connected', {
    'en': 'Device Connected',
    'ru': 'Устройство подключено',
    'pl': 'Urządzenie połączone',
  });

  String get deviceDisconnected => _localizedString('device_disconnected', {
    'en': 'Device Disconnected',
    'ru': 'Устройство отключено',
    'pl': 'Urządzenie rozłączone',
  });

  String get lastUpdated => _localizedString('last_updated', {
    'en': 'Last updated',
    'ru': 'Последнее обновление',
    'pl': 'Ostatnia aktualizacja',
  });

  String get demoModeControls => _localizedString('demo_mode_controls', {
    'en': 'Demo Mode Controls',
    'ru': 'Управление демо режимом',
    'pl': 'Kontrola trybu demo',
  });

  String get testOverlayColorsShort => _localizedString('test_overlay_colors_short', {
    'en': 'Test overlay colors:',
    'ru': 'Тестировать цвета наложения:',
    'pl': 'Testuj kolory nakładki:',
  });

  String get currentStatus => _localizedString('current_status', {
    'en': 'Current Status',
    'ru': 'Текущий статус',
    'pl': 'Aktualny status',
  });

  String get signalColor => _localizedString('signal_color', {
    'en': 'Signal Color',
    'ru': 'Цвет сигнала',
    'pl': 'Kolor sygnału',
  });

  String get timeRemaining => _localizedString('time_remaining', {
    'en': 'Time Remaining',
    'ru': 'Осталось времени',
    'pl': 'Pozostały czas',
  });

  String get lastUpdate => _localizedString('last_update', {
    'en': 'Last Update',
    'ru': 'Последнее обновление',
    'pl': 'Ostatnia aktualizacja',
  });

  String get recognizedSigns => _localizedString('recognized_signs', {
    'en': 'Recognized Signs',
    'ru': 'Распознанные знаки',
    'pl': 'Rozpoznane znaki',
  });

  String get toggleOverlay => _localizedString('toggle_overlay', {
    'en': 'Toggle Overlay',
    'ru': 'Переключить наложение',
    'pl': 'Przełącz nakładkę',
  });

  String get reportBug => _localizedString('report_bug', {
    'en': 'Report Bug',
    'ru': 'Сообщить об ошибке',
    'pl': 'Zgłoś błąd',
  });

  String get bugReportMessage => _localizedString('bug_report_message', {
    'en': 'Bug report feature would export logs and device info',
    'ru': 'Функция отчета об ошибке экспортирует журналы и информацию об устройстве',
    'pl': 'Funkcja zgłaszania błędów eksportuje dzienniki i informacje o urządzeniu',
  });

  String secondsAgo(int seconds) => _localizedString('seconds_ago', {
    'en': '${seconds}s ago',
    'ru': '$seconds сек. назад',
    'pl': '$seconds sek. temu',
  });

  String minutesAgo(int minutes) => _localizedString('minutes_ago', {
    'en': '${minutes}m ago',
    'ru': '$minutes мин. назад',
    'pl': '$minutes min. temu',
  });

  // Gesture hints and actions
  String get longPressToToggleMode => _localizedString('long_press_to_toggle_mode', {
    'en': 'Long press to toggle display mode',
    'ru': 'Длительное нажатие для переключения режима отображения',
    'pl': 'Długie naciśnięcie aby przełączyć tryb wyświetlania',
  });

  String get doubleTapForDetails => _localizedString('double_tap_for_details', {
    'en': 'Double tap for detailed view',
    'ru': 'Двойное нажатие для подробного просмотра',
    'pl': 'Podwójne dotknięcie dla szczegółowego widoku',
  });

  String displayModeSwitchedTo(String mode) => _localizedString('display_mode_switched_to', {
    'en': 'Display mode switched to $mode',
    'ru': 'Режим отображения переключён на $mode',
    'pl': 'Tryb wyświetlania przełączony na $mode',
  });

  String get quickActions => _localizedString('quick_actions', {
    'en': 'Quick Actions',
    'ru': 'Быстрые действия',
    'pl': 'Szybkie akcje',
  });

  String get hideOverlay => _localizedString('hide_overlay', {
    'en': 'Hide Overlay',
    'ru': 'Скрыть наложение',
    'pl': 'Ukryj nakładkę',
  });

  String get showOverlay => _localizedString('show_overlay', {
    'en': 'Show Overlay',
    'ru': 'Показать наложение',
    'pl': 'Pokaż nakładkę',
  });

  String get detailedView => _localizedString('detailed_view', {
    'en': 'Detailed View',
    'ru': 'Подробный вид',
    'pl': 'Widok szczegółowy',
  });

  String get tapToClose => _localizedString('tap_to_close', {
    'en': 'Tap to close',
    'ru': 'Нажмите для закрытия',
    'pl': 'Dotknij aby zamknąć',
  });

  // Advanced mode elements
  String get leftLane => _localizedString('left_lane', {
    'en': 'LEFT',
    'ru': 'ЛЕВАЯ',
    'pl': 'LEWA',
  });

  String get rightLane => _localizedString('right_lane', {
    'en': 'RIGHT',
    'ru': 'ПРАВАЯ',
    'pl': 'PRAWA',
  });

  String get laneMarkers => _localizedString('lane_markers', {
    'en': 'Lane Markers',
    'ru': 'Разметка полос',
    'pl': 'Oznaczenia pasów',
  });

  String get trafficControl => _localizedString('traffic_control', {
    'en': 'Traffic Control',
    'ru': 'Управление движением',
    'pl': 'Kontrola ruchu',
  });

  String get roadSigns => _localizedString('road_signs', {
    'en': 'Road Signs',
    'ru': 'Дорожные знаки',
    'pl': 'Znaki drogowe',
  });

  // Road sign names
  String get stopSign => _localizedString('stop_sign', {
    'en': 'STOP',
    'ru': 'СТОП',
    'pl': 'STOP',
  });

  String get yieldSign => _localizedString('yield_sign', {
    'en': 'YIELD',
    'ru': 'УСТУПИ',
    'pl': 'USTĄP',
  });

  String get speedLimitSign => _localizedString('speed_limit_sign', {
    'en': 'SPEED LIMIT',
    'ru': 'ОГРАНИЧЕНИЕ СКОРОСТИ',
    'pl': 'OGRANICZENIE PRĘDKOŚCI',
  });

  String get noEntrySign => _localizedString('no_entry_sign', {
    'en': 'NO ENTRY',
    'ru': 'ВЪЕЗД ЗАПРЕЩЁН',
    'pl': 'ZAKAZ WJAZDU',
  });

  String get constructionSign => _localizedString('construction_sign', {
    'en': 'CONSTRUCTION',
    'ru': 'РЕМОНТ',
    'pl': 'ROBOTY',
  });

  String get pedestrianSign => _localizedString('pedestrian_sign', {
    'en': 'PEDESTRIAN',
    'ru': 'ПЕШЕХОДЫ',
    'pl': 'PRZEJŚCIE',
  });

  String get turnLeftSign => _localizedString('turn_left_sign', {
    'en': 'TURN LEFT',
    'ru': 'ПОВОРОТ НАЛЕВО',
    'pl': 'SKRĘĆ W LEWO',
  });

  String get turnRightSign => _localizedString('turn_right_sign', {
    'en': 'TURN RIGHT',
    'ru': 'ПОВОРОТ НАПРАВО',
    'pl': 'SKRĘĆ W PRAWO',
  });

  String get goStraightSign => _localizedString('go_straight_sign', {
    'en': 'GO STRAIGHT',
    'ru': 'ПРЯМО',
    'pl': 'JEDŹ PROSTO',
  });

  String get noSignsDetected => _localizedString('no_signs_detected', {
    'en': 'No signs detected',
    'ru': 'Знаки не обнаружены',
    'pl': 'Nie wykryto znaków',
  });

  // Navigation
  String get home => _localizedString('home', {
    'en': 'Home',
    'ru': 'Главная',
    'pl': 'Strona główna',
  });

  String get map => _localizedString('map', {
    'en': 'Map',
    'ru': 'Карта',
    'pl': 'Mapa',
  });

  String get routes => _localizedString('routes', {
    'en': 'Routes',
    'ru': 'Маршруты',
    'pl': 'Trasy',
  });

  String get about => _localizedString('about', {
    'en': 'About',
    'ru': 'О программе',
    'pl': 'O aplikacji',
  });

  // Map Screen
  String get currentLocation => _localizedString('current_location', {
    'en': 'Current Location',
    'ru': 'Текущее местоположение',
    'pl': 'Bieżąca lokalizacja',
  });

  String get enableLocationServices => _localizedString('enable_location_services', {
    'en': 'Please enable location services',
    'ru': 'Пожалуйста, включите службы геолокации',
    'pl': 'Proszę włączyć usługi lokalizacji',
  });

  String get locationPermissionRequired => _localizedString('location_permission_required', {
    'en': 'Location permission required',
    'ru': 'Требуется разрешение на местоположение',
    'pl': 'Wymagane uprawnienie lokalizacji',
  });

  String get loadingLocation => _localizedString('loading_location', {
    'en': 'Loading location...',
    'ru': 'Загрузка местоположения...',
    'pl': 'Ładowanie lokalizacji...',
  });

  String get tapToAddTrafficLight => _localizedString('tap_to_add_traffic_light', {
    'en': 'Tap on the map to add traffic light markers',
    'ru': 'Нажмите на карте, чтобы добавить маркеры светофоров',
    'pl': 'Dotknij mapę, aby dodać znaczniki sygnalizacji',
  });

  String get refresh => _localizedString('refresh', {
    'en': 'Refresh',
    'ru': 'Обновить',
    'pl': 'Odśwież',
  });

  // Routes Screen
  String get frequentRoutes => _localizedString('frequent_routes', {
    'en': 'Frequent Routes',
    'ru': 'Частые маршруты',
    'pl': 'Częste trasy',
  });

  String get routesDescription => _localizedString('routes_description', {
    'en': 'Your most frequently used traffic routes',
    'ru': 'Ваши наиболее часто используемые маршруты',
    'pl': 'Twoje najczęściej używane trasy',
  });

  String get addRoute => _localizedString('add_route', {
    'en': 'Add Route',
    'ru': 'Добавить маршрут',
    'pl': 'Dodaj trasę',
  });

  String get navigate => _localizedString('navigate', {
    'en': 'Navigate',
    'ru': 'Навигация',
    'pl': 'Nawiguj',
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