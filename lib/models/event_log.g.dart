// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventLog _$EventLogFromJson(Map<String, dynamic> json) => EventLog(
  id: json['id'] as String,
  type: $enumDecode(_$EventTypeEnumMap, json['type']),
  message: json['message'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  previousColor: $enumDecodeNullable(
    _$TrafficLightColorEnumMap,
    json['previousColor'],
  ),
  newColor: $enumDecodeNullable(_$TrafficLightColorEnumMap, json['newColor']),
  recognizedSigns: (json['recognizedSigns'] as List<dynamic>?)
      ?.map((e) => $enumDecode(_$RoadSignEnumMap, e))
      .toList(),
  additionalData: json['additionalData'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$EventLogToJson(EventLog instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$EventTypeEnumMap[instance.type]!,
  'message': instance.message,
  'timestamp': instance.timestamp.toIso8601String(),
  'previousColor': _$TrafficLightColorEnumMap[instance.previousColor],
  'newColor': _$TrafficLightColorEnumMap[instance.newColor],
  'recognizedSigns': instance.recognizedSigns
      ?.map((e) => _$RoadSignEnumMap[e]!)
      .toList(),
  'additionalData': instance.additionalData,
};

const _$EventTypeEnumMap = {
  EventType.signalChange: 'signalChange',
  EventType.signRecognition: 'signRecognition',
  EventType.connectionStatusChange: 'connectionStatusChange',
  EventType.error: 'error',
  EventType.userAction: 'userAction',
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
