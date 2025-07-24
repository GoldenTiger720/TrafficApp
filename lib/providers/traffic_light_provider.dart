import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/traffic_light_state.dart';
import '../models/event_log.dart';
import '../services/connection_service.dart';
import '../services/notification_service.dart';
import '../services/event_log_service.dart';
import '../providers/settings_provider.dart';

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
  final SettingsProvider _settingsProvider;

  TrafficLightProvider(
    this._connectionService,
    this._notificationService,
    this._eventLogService,
    this._settingsProvider,
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
    _countdownTimer?.cancel();
    
    final colors = TrafficLightColor.values;
    var currentIndex = 0;
    final totalDuration = _settingsProvider.settings.totalDuration;
    final countdownDuration = _settingsProvider.settings.countdownDuration;
    
    // Start first signal immediately
    _setDemoSignal(colors[currentIndex % colors.length], totalDuration, countdownDuration);
    _startCountdownTimer(totalDuration, countdownDuration);
    
    _demoTimer = Timer.periodic(Duration(seconds: totalDuration), (timer) {
      currentIndex++;
      final newColor = colors[currentIndex % colors.length];
      _setDemoSignal(newColor, totalDuration, countdownDuration);
      _startCountdownTimer(totalDuration, countdownDuration);
    });
  }
  
  void _setDemoSignal(TrafficLightColor color, int totalDuration, int countdownDuration) {
    final newState = TrafficLightState(
      currentColor: color,
      countdownSeconds: totalDuration,
      recognizedSigns: _getRandomSigns(),
      timestamp: DateTime.now(),
    );
    
    _handleIncomingData(newState);
  }
  
  void _startCountdownTimer(int totalDuration, int countdownDuration) {
    _countdownTimer?.cancel();
    int remainingSeconds = totalDuration;
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remainingSeconds--;
      
      if (remainingSeconds <= 0) {
        timer.cancel();
        return;
      }
      
      // Only show countdown for the last N seconds AND only update UI when needed
      int? displaySeconds;
      bool shouldUpdate = false;
      
      if (remainingSeconds <= countdownDuration) {
        displaySeconds = remainingSeconds;
        shouldUpdate = true;
      } else if (_currentState.countdownSeconds != null) {
        // Clear countdown when not in countdown period
        displaySeconds = null;
        shouldUpdate = true;
      }
      
      // Only update UI if countdown value actually changed
      if (shouldUpdate) {
        final updatedState = TrafficLightState(
          currentColor: _currentState.currentColor,
          countdownSeconds: displaySeconds,
          recognizedSigns: _currentState.recognizedSigns,
          timestamp: _currentState.timestamp,
        );
        
        _currentState = updatedState;
        notifyListeners();
      }
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