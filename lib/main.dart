import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'providers/traffic_light_provider.dart';
import 'providers/settings_provider.dart';
import 'services/connection_service.dart';
import 'services/notification_service.dart';
import 'services/event_log_service.dart';
import 'services/app_lifecycle_observer.dart';
import 'widgets/app_navigation_scaffold.dart';
import 'screens/splash_screen.dart';
import 'models/app_settings.dart';
import 'l10n/app_localizations.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize window manager for desktop platforms only
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      await windowManager.ensureInitialized();
      
      WindowOptions windowOptions = const WindowOptions(
        size: Size(800, 600),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
        alwaysOnTop: false, // Disable always on top for stability
        fullScreen: false,
      );
      
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }
    
    // Initialize services with error handling
    NotificationService? notificationService;
    try {
      notificationService = NotificationService();
      await notificationService.init();
    } catch (e) {
      debugPrint('Notification service failed to initialize: $e');
      notificationService = NotificationService(); // Use without init
    }
    
    // Initialize app lifecycle observer
    AppLifecycleObserver().initialize();
    
    runApp(TrafficLightApp(notificationService: notificationService));
  } catch (e) {
    debugPrint('Main initialization error: $e');
    // Run minimal app on failure
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('App initialization failed'),
        ),
      ),
    ));
  }
}

class TrafficLightApp extends StatelessWidget {
  final NotificationService notificationService;
  
  const TrafficLightApp({
    super.key,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SettingsProvider>(
      future: _initializeSettings(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return MaterialApp(
            home: const SplashScreen(autoNavigate: false),
          );
        }
        
        final settingsProvider = snapshot.data!;
        
        return MultiProvider(
          providers: [
            Provider<ConnectionService>(
              create: (_) => ConnectionService(),
              dispose: (_, service) => service.dispose(),
              lazy: true,
            ),
            Provider<NotificationService>.value(value: notificationService),
            ChangeNotifierProvider<EventLogService>(
              create: (_) => EventLogService(),
              lazy: true,
            ),
            ChangeNotifierProvider<SettingsProvider>.value(
              value: settingsProvider,
            ),
            ChangeNotifierProxyProvider4<ConnectionService, NotificationService, EventLogService, SettingsProvider, TrafficLightProvider>(
              create: (context) => TrafficLightProvider(
                context.read<ConnectionService>(),
                context.read<NotificationService>(),
                context.read<EventLogService>(),
                context.read<SettingsProvider>(),
              ),
              update: (context, connectionService, notificationService, eventLogService, settingsProvider, previous) =>
                  previous ?? TrafficLightProvider(
                    connectionService,
                    notificationService,
                    eventLogService,
                    settingsProvider,
                  ),
              lazy: true,
            ),
          ],
          child: Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              return MaterialApp(
                title: 'TURIST',
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
                home: const SplashScreen(),
              );
            },
          ),
        );
      },
    );
  }
  
  Future<SettingsProvider> _initializeSettings() async {
    final provider = SettingsProvider();
    await provider.init();
    return provider;
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