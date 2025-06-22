import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/traffic_light_state.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  bool _initialized = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  Future<void> init() async {
    if (_initialized) return;

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse notificationResponse) {
    debugPrint('Notification tapped: ${notificationResponse.payload}');
  }

  void updateSettings({bool? sound, bool? vibration}) {
    if (sound != null) _soundEnabled = sound;
    if (vibration != null) _vibrationEnabled = vibration;
  }

  Future<void> showSignalChangeNotification(
    TrafficLightColor from,
    TrafficLightColor to,
  ) async {
    if (!_initialized) await init();

    final colorEmoji = _getColorEmoji(to);
    final title = 'Traffic Light Changed';
    final body = '$colorEmoji Light changed from ${from.name} to ${to.name}';

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'traffic_light_channel',
      'Traffic Light Notifications',
      channelDescription: 'Notifications for traffic light changes',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Traffic Light Update',
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    if (_soundEnabled) {
      await _flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        platformChannelSpecifics,
        payload: 'signal_change:${from.name}:${to.name}',
      );
    }

    if (_vibrationEnabled) {
      await _vibrate(to);
    }
  }

  Future<void> showConnectionNotification(String message) async {
    if (!_initialized) await init();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'connection_channel',
      'Connection Notifications',
      channelDescription: 'Notifications for connection status',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      1,
      'Connection Status',
      message,
      platformChannelSpecifics,
      payload: 'connection_status',
    );
  }

  Future<void> _vibrate(TrafficLightColor color) async {
    try {
      switch (color) {
        case TrafficLightColor.red:
          // Long vibration for red (stop)
          await HapticFeedback.heavyImpact();
          break;
        case TrafficLightColor.yellow:
          // Medium vibration for yellow (caution)
          await HapticFeedback.mediumImpact();
          break;
        case TrafficLightColor.green:
          // Light vibration for green (go)
          await HapticFeedback.lightImpact();
          break;
      }
    } catch (e) {
      debugPrint('Error with haptic feedback: $e');
    }
  }

  String _getColorEmoji(TrafficLightColor color) {
    switch (color) {
      case TrafficLightColor.red:
        return '🔴';
      case TrafficLightColor.yellow:
        return '🟡';
      case TrafficLightColor.green:
        return '🟢';
    }
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}