import 'package:json_annotation/json_annotation.dart';
import 'traffic_light_state.dart';

part 'event_log.g.dart';

enum EventType {
  signalChange,
  signRecognition,
  connectionStatusChange,
  error,
  userAction
}

@JsonSerializable()
class EventLog {
  final String id;
  final EventType type;
  final String message;
  final DateTime timestamp;
  final TrafficLightColor? previousColor;
  final TrafficLightColor? newColor;
  final List<RoadSign>? recognizedSigns;
  final Map<String, dynamic>? additionalData;

  const EventLog({
    required this.id,
    required this.type,
    required this.message,
    required this.timestamp,
    this.previousColor,
    this.newColor,
    this.recognizedSigns,
    this.additionalData,
  });

  factory EventLog.fromJson(Map<String, dynamic> json) =>
      _$EventLogFromJson(json);

  Map<String, dynamic> toJson() => _$EventLogToJson(this);

  static EventLog signalChange({
    required String id,
    required TrafficLightColor from,
    required TrafficLightColor to,
  }) {
    return EventLog(
      id: id,
      type: EventType.signalChange,
      message: 'Traffic light changed from ${from.name} to ${to.name}',
      timestamp: DateTime.now(),
      previousColor: from,
      newColor: to,
    );
  }

  static EventLog signRecognition({
    required String id,
    required List<RoadSign> signs,
  }) {
    return EventLog(
      id: id,
      type: EventType.signRecognition,
      message: 'Recognized signs: ${signs.map((s) => s.name).join(', ')}',
      timestamp: DateTime.now(),
      recognizedSigns: signs,
    );
  }

  static EventLog connectionChange({
    required String id,
    required String message,
  }) {
    return EventLog(
      id: id,
      type: EventType.connectionStatusChange,
      message: message,
      timestamp: DateTime.now(),
    );
  }

  static EventLog error({
    required String id,
    required String message,
    Map<String, dynamic>? additionalData,
  }) {
    return EventLog(
      id: id,
      type: EventType.error,
      message: message,
      timestamp: DateTime.now(),
      additionalData: additionalData,
    );
  }

  static EventLog userAction({
    required String id,
    required String message,
  }) {
    return EventLog(
      id: id,
      type: EventType.userAction,
      message: message,
      timestamp: DateTime.now(),
    );
  }
}