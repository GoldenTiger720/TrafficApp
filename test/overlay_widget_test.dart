import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/models/traffic_light_state.dart';
import '../lib/widgets/floating_overlay_widget.dart';

void main() {
  group('FloatingOverlayWidget Tests', () {
    testWidgets('Widget renders with basic properties', (WidgetTester tester) async {
      final testState = TrafficLightState(
        currentColor: TrafficLightColor.red,
        timestamp: DateTime.now(),
        countdownSeconds: 15,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: FloatingOverlayWidget(
            state: testState,
            size: 1.0,
            transparency: 0.9,
          ),
        ),
      );

      expect(find.byType(FloatingOverlayWidget), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('Widget scales properly with size parameter', (WidgetTester tester) async {
      final testState = TrafficLightState(
        currentColor: TrafficLightColor.green,
        timestamp: DateTime.now(),
        countdownSeconds: 30,
      );

      // Test with small size
      await tester.pumpWidget(
        MaterialApp(
          home: FloatingOverlayWidget(
            state: testState,
            size: 0.5,
            transparency: 0.8,
          ),
        ),
      );

      // Widget should render and scale appropriately
      expect(find.byType(FloatingOverlayWidget), findsOneWidget);
      expect(find.text('30'), findsOneWidget);

      // Test with large size
      await tester.pumpWidget(
        MaterialApp(
          home: FloatingOverlayWidget(
            state: testState,
            size: 1.5,
            transparency: 0.9,
          ),
        ),
      );

      expect(find.byType(FloatingOverlayWidget), findsOneWidget);
    });

    testWidgets('Widget responds to traffic light state changes', (WidgetTester tester) async {
      final redState = TrafficLightState(
        currentColor: TrafficLightColor.red,
        timestamp: DateTime.now(),
        countdownSeconds: 25,
      );

      final yellowState = TrafficLightState(
        currentColor: TrafficLightColor.yellow,
        timestamp: DateTime.now(),
        countdownSeconds: 5,
      );

      // Start with red
      await tester.pumpWidget(
        MaterialApp(
          home: FloatingOverlayWidget(
            state: redState,
            size: 1.0,
            transparency: 0.9,
          ),
        ),
      );

      expect(find.text('25'), findsOneWidget);

      // Change to yellow
      await tester.pumpWidget(
        MaterialApp(
          home: FloatingOverlayWidget(
            state: yellowState,
            size: 1.0,
            transparency: 0.9,
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });
  });
}