import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/traffic_light_provider.dart';
import 'providers/settings_provider.dart';
import 'services/connection_service.dart';
import 'services/notification_service.dart';
import 'services/event_log_service.dart';
import 'screens/main_screen.dart';
import 'models/app_settings.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final notificationService = NotificationService();
  await notificationService.init();
  
  runApp(TrafficLightApp(notificationService: notificationService));
}

class TrafficLightApp extends StatelessWidget {
  final NotificationService notificationService;
  
  const TrafficLightApp({
    super.key,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ConnectionService>(
          create: (_) => ConnectionService(),
          dispose: (_, service) => service.dispose(),
        ),
        Provider<NotificationService>.value(value: notificationService),
        ChangeNotifierProvider<EventLogService>(
          create: (_) {
            final service = EventLogService();
            service.loadEventsFromFile();
            return service;
          },
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) {
            final provider = SettingsProvider();
            provider.init();
            return provider;
          },
        ),
        ChangeNotifierProxyProvider3<ConnectionService, NotificationService, EventLogService, TrafficLightProvider>(
          create: (context) => TrafficLightProvider(
            context.read<ConnectionService>(),
            context.read<NotificationService>(),
            context.read<EventLogService>(),
          ),
          update: (context, connectionService, notificationService, eventLogService, previous) =>
              previous ?? TrafficLightProvider(
                connectionService,
                notificationService,
                eventLogService,
              ),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'Traffic Light Monitor',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(settingsProvider.settings.theme, false),
            darkTheme: _buildTheme(settingsProvider.settings.theme, true),
            themeMode: _getThemeMode(settingsProvider.settings.theme),
            locale: _getLocale(settingsProvider.settings.language),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('ru', ''),
              Locale('pl', ''),
            ],
            home: const MainScreen(),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(AppTheme appTheme, bool isDark) {
    final colorScheme = isDark
        ? ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          )
        : ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 2,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  ThemeMode _getThemeMode(AppTheme appTheme) {
    switch (appTheme) {
      case AppTheme.light:
        return ThemeMode.light;
      case AppTheme.dark:
        return ThemeMode.dark;
      case AppTheme.system:
        return ThemeMode.system;
    }
  }

  Locale _getLocale(Language language) {
    switch (language) {
      case Language.en:
        return const Locale('en', '');
      case Language.ru:
        return const Locale('ru', '');
      case Language.pl:
        return const Locale('pl', '');
    }
  }
}