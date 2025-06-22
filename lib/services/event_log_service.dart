import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/event_log.dart';

class EventLogService extends ChangeNotifier {
  final List<EventLog> _events = [];
  static const int _maxEvents = 1000;

  List<EventLog> get events => List.unmodifiable(_events);

  void addEvent(EventLog event) {
    _events.insert(0, event);
    
    if (_events.length > _maxEvents) {
      _events.removeRange(_maxEvents, _events.length);
    }
    
    notifyListeners();
    _saveEventsToFile();
  }

  void clearEvents() {
    _events.clear();
    notifyListeners();
    _saveEventsToFile();
  }

  List<EventLog> getEventsByType(EventType type) {
    return _events.where((event) => event.type == type).toList();
  }

  List<EventLog> getEventsInDateRange(DateTime start, DateTime end) {
    return _events.where((event) =>
        event.timestamp.isAfter(start) && event.timestamp.isBefore(end)).toList();
  }

  Future<void> _saveEventsToFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/event_log.json');
      
      final eventsJson = _events.map((event) => event.toJson()).toList();
      await file.writeAsString(json.encode(eventsJson));
    } catch (e) {
      debugPrint('Error saving events to file: $e');
    }
  }

  Future<void> loadEventsFromFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/event_log.json');
      
      if (!await file.exists()) return;
      
      final jsonString = await file.readAsString();
      final List<dynamic> eventsJson = json.decode(jsonString);
      
      _events.clear();
      _events.addAll(
        eventsJson.map((json) => EventLog.fromJson(json as Map<String, dynamic>)),
      );
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading events from file: $e');
    }
  }

  Future<String> exportEventsAsText() async {
    final buffer = StringBuffer();
    buffer.writeln('Traffic Light App - Event Log Export');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Total Events: ${_events.length}');
    buffer.writeln('${'=' * 50}');
    buffer.writeln();

    for (final event in _events) {
      buffer.writeln('Timestamp: ${event.timestamp.toIso8601String()}');
      buffer.writeln('Type: ${event.type.name}');
      buffer.writeln('Message: ${event.message}');
      
      if (event.previousColor != null && event.newColor != null) {
        buffer.writeln('Color Change: ${event.previousColor!.name} → ${event.newColor!.name}');
      }
      
      if (event.recognizedSigns?.isNotEmpty == true) {
        buffer.writeln('Signs: ${event.recognizedSigns!.map((s) => s.name).join(', ')}');
      }
      
      if (event.additionalData?.isNotEmpty == true) {
        buffer.writeln('Additional Data: ${event.additionalData}');
      }
      
      buffer.writeln('-' * 30);
      buffer.writeln();
    }

    return buffer.toString();
  }

  Future<void> shareEventLog() async {
    try {
      final logText = await exportEventsAsText();
      
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/traffic_light_event_log.txt');
      await file.writeAsString(logText);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Traffic Light App Event Log',
        subject: 'Event Log Export - ${DateTime.now().toIso8601String()}',
      );
    } catch (e) {
      debugPrint('Error sharing event log: $e');
    }
  }

  Map<EventType, int> getEventTypeCounts() {
    final counts = <EventType, int>{};
    for (final event in _events) {
      counts[event.type] = (counts[event.type] ?? 0) + 1;
    }
    return counts;
  }

  List<EventLog> getRecentEvents({int limit = 50}) {
    return _events.take(limit).toList();
  }
}