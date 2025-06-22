import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/traffic_light_state.dart';
import '../models/event_log.dart';
import '../services/connection_service.dart';
import '../services/notification_service.dart';
import '../services/event_log_service.dart';

class TrafficLightProvider extends ChangeNotifier {
  TrafficLightState _currentState = TrafficLightState(
    currentColor: TrafficLightColor.red,
    timestamp: DateTime.now(),
  );

  bool _isConnected = false;
  bool _demoMode = false;
  Timer? _demoTimer;
  Timer? _countdownTimer;

  final ConnectionService _connectionService;
  final NotificationService _notificationService;
  final EventLogService _eventLogService;

  TrafficLightProvider(
    this._connectionService,
    this._notificationService,
    this._eventLogService,
  ) {
    _connectionService.dataStream.listen(_handleIncomingData);
    _connectionService.connectionStatusStream.listen(_handleConnectionStatus);
  }

  TrafficLightState get currentState => _currentState;
  bool get isConnected => _isConnected;
  bool get demoMode => _demoMode;

  void _handleIncomingData(TrafficLightState newState) {
    final previousColor = _currentState.currentColor;
    _currentState = newState;
    
    if (previousColor != newState.currentColor) {
      _notificationService.showSignalChangeNotification(
        previousColor,
        newState.currentColor,
      );
      
      _eventLogService.addEvent(EventLog.signalChange(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        from: previousColor,
        to: newState.currentColor,
      ));
    }

    if (newState.recognizedSigns.isNotEmpty) {
      _eventLogService.addEvent(EventLog.signRecognition(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        signs: newState.recognizedSigns,
      ));
    }

    notifyListeners();
  }

  void _handleConnectionStatus(bool connected) {
    _isConnected = connected;
    _eventLogService.addEvent(EventLog.connectionChange(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: connected ? 'Connected to device' : 'Disconnected from device',
    ));
    notifyListeners();
  }

  void setDemoMode(bool enabled) {
    _demoMode = enabled;
    if (enabled) {
      _startDemoMode();
    } else {
      _stopDemoMode();
    }
    notifyListeners();
  }

  void _startDemoMode() {
    _demoTimer?.cancel();
    final colors = TrafficLightColor.values;
    var currentIndex = 0;
    
    _demoTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final newColor = colors[currentIndex % colors.length];
      final newState = TrafficLightState(
        currentColor: newColor,
        countdownSeconds: 5,
        recognizedSigns: _getRandomSigns(),
        timestamp: DateTime.now(),
      );
      
      _handleIncomingData(newState);
      currentIndex++;
    });
  }

  void _stopDemoMode() {
    _demoTimer?.cancel();
    _countdownTimer?.cancel();
  }

  List<RoadSign> _getRandomSigns() {
    final random = Random();
    final signs = RoadSign.values;
    final count = random.nextInt(3);
    
    if (count == 0) return [];
    
    final selectedSigns = <RoadSign>[];
    for (int i = 0; i < count; i++) {
      selectedSigns.add(signs[random.nextInt(signs.length)]);
    }
    
    return selectedSigns.toSet().toList();
  }

  void testOverlay(TrafficLightColor color) {
    if (_demoMode) {
      _currentState = TrafficLightState(
        currentColor: color,
        timestamp: DateTime.now(),
      );
      
      _eventLogService.addEvent(EventLog.userAction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: 'Manual overlay test: ${color.name}',
      ));
      
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _demoTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
}