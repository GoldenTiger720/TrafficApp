// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'traffic_light_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrafficLightState _$TrafficLightStateFromJson(Map<String, dynamic> json) =>
    TrafficLightState(
      currentColor: $enumDecode(
        _$TrafficLightColorEnumMap,
        json['currentColor'],
      ),
      countdownSeconds: (json['countdownSeconds'] as num?)?.toInt(),
      recognizedSigns:
          (json['recognizedSigns'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$RoadSignEnumMap, e))
              .toList() ??
          const [],
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$TrafficLightStateToJson(TrafficLightState instance) =>
    <String, dynamic>{
      'currentColor': _$TrafficLightColorEnumMap[instance.currentColor]!,
      'countdownSeconds': instance.countdownSeconds,
      'recognizedSigns': instance.recognizedSigns
          .map((e) => _$RoadSignEnumMap[e]!)
          .toList(),
      'timestamp': instance.timestamp.toIso8601String(),
    };

const _$TrafficLightColorEnumMap = {
  TrafficLightColor.red: 'red',
  TrafficLightColor.yellow: 'yellow',
  TrafficLightColor.green: 'green',
};

const _$RoadSignEnumMap = {
  RoadSign.stop: 'stop',
  RoadSign.yield: 'yield',
  RoadSign.speedLimit: 'speedLimit',
  RoadSign.noEntry: 'noEntry',
  RoadSign.construction: 'construction',
  RoadSign.pedestrianCrossing: 'pedestrianCrossing',
  RoadSign.turnLeft: 'turnLeft',
  RoadSign.turnRight: 'turnRight',
  RoadSign.goStraight: 'goStraight',
};
