import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_app/main.dart';
import 'package:traffic_app/services/notification_service.dart';

void main() {
  testWidgets('Traffic Light App smoke test', (WidgetTester tester) async {
    // Initialize notification service
    final notificationService = NotificationService();
    await notificationService.init();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(TrafficLightApp(notificationService: notificationService));

    // Verify that our app loads
    expect(find.text('Traffic Light Monitor'), findsOneWidget);
  });
}