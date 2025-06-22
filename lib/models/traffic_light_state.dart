import 'package:json_annotation/json_annotation.dart';

part 'traffic_light_state.g.dart';

enum TrafficLightColor { red, yellow, green }

enum RoadSign {
  stop,
  yield,
  speedLimit,
  noEntry,
  construction,
  pedestrianCrossing,
  turnLeft,
  turnRight,
  goStraight
}

@JsonSerializable()
class TrafficLightState {
  final TrafficLightColor currentColor;
  final int? countdownSeconds;
  final List<RoadSign> recognizedSigns;
  final DateTime timestamp;

  const TrafficLightState({
    required this.currentColor,
    this.countdownSeconds,
    this.recognizedSigns = const [],
    required this.timestamp,
  });

  factory TrafficLightState.fromJson(Map<String, dynamic> json) =>
      _$TrafficLightStateFromJson(json);

  Map<String, dynamic> toJson() => _$TrafficLightStateToJson(this);

  TrafficLightState copyWith({
    TrafficLightColor? currentColor,
    int? countdownSeconds,
    List<RoadSign>? recognizedSigns,
    DateTime? timestamp,
  }) {
    return TrafficLightState(
      currentColor: currentColor ?? this.currentColor,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      recognizedSigns: recognizedSigns ?? this.recognizedSigns,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}