import 'package:json_annotation/json_annotation.dart';

part 'traffic_route.g.dart';

@JsonSerializable()
class TrafficRoute {
  final String id;
  final String name;
  final String startLocation;
  final String endLocation;
  final String distance;
  final String duration;
  final int frequency;
  final DateTime lastUsed;

  TrafficRoute({
    required this.id,
    required this.name,
    required this.startLocation,
    required this.endLocation,
    required this.distance,
    required this.duration,
    required this.frequency,
    required this.lastUsed,
  });

  factory TrafficRoute.fromJson(Map<String, dynamic> json) =>
      _$TrafficRouteFromJson(json);

  Map<String, dynamic> toJson() => _$TrafficRouteToJson(this);

  TrafficRoute copyWith({
    String? id,
    String? name,
    String? startLocation,
    String? endLocation,
    String? distance,
    String? duration,
    int? frequency,
    DateTime? lastUsed,
  }) {
    return TrafficRoute(
      id: id ?? this.id,
      name: name ?? this.name,
      startLocation: startLocation ?? this.startLocation,
      endLocation: endLocation ?? this.endLocation,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      frequency: frequency ?? this.frequency,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  @override
  String toString() {
    return 'TrafficRoute(id: $id, name: $name, startLocation: $startLocation, endLocation: $endLocation, distance: $distance, duration: $duration, frequency: $frequency, lastUsed: $lastUsed)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrafficRoute &&
        other.id == id &&
        other.name == name &&
        other.startLocation == startLocation &&
        other.endLocation == endLocation &&
        other.distance == distance &&
        other.duration == duration &&
        other.frequency == frequency &&
        other.lastUsed == lastUsed;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        startLocation.hashCode ^
        endLocation.hashCode ^
        distance.hashCode ^
        duration.hashCode ^
        frequency.hashCode ^
        lastUsed.hashCode;
  }
}