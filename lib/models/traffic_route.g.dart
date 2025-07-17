// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'traffic_route.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrafficRoute _$TrafficRouteFromJson(Map<String, dynamic> json) => TrafficRoute(
  id: json['id'] as String,
  name: json['name'] as String,
  startLocation: json['startLocation'] as String,
  endLocation: json['endLocation'] as String,
  distance: json['distance'] as String,
  duration: json['duration'] as String,
  frequency: (json['frequency'] as num).toInt(),
  lastUsed: DateTime.parse(json['lastUsed'] as String),
);

Map<String, dynamic> _$TrafficRouteToJson(TrafficRoute instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'startLocation': instance.startLocation,
      'endLocation': instance.endLocation,
      'distance': instance.distance,
      'duration': instance.duration,
      'frequency': instance.frequency,
      'lastUsed': instance.lastUsed.toIso8601String(),
    };
