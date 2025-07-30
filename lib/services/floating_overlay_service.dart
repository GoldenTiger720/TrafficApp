import 'package:flutter/material.dart';
import '../models/traffic_light_state.dart';
import '../models/app_settings.dart';
import '../widgets/draggable_floating_overlay.dart';

class FloatingOverlayService {
  static final FloatingOverlayService _instance = FloatingOverlayService._internal();
  factory FloatingOverlayService() => _instance;
  FloatingOverlayService._internal();

  OverlayEntry? _overlayEntry;
  BuildContext? _context;
  AppSettings? _currentSettings;
  TrafficLightState? _currentState;
  Function(double x, double y)? _onPositionChanged;

  bool get isShowing => _overlayEntry != null;

  void initialize(BuildContext context, {Function(double x, double y)? onPositionChanged}) {
    _context = context;
    _onPositionChanged = onPositionChanged;
  }

  void updateSettings(AppSettings settings) {
    _currentSettings = settings;
    debugPrint('FloatingOverlayService: updateSettings called - overlayEnabled: ${settings.overlayEnabled}');
    debugPrint('FloatingOverlayService: Current state - _overlayEntry: ${_overlayEntry != null}, _context: ${_context != null}, _currentState: ${_currentState != null}');
    
    _tryShowOverlay();
  }

  void updateState(TrafficLightState state) {
    _currentState = state;
    debugPrint('FloatingOverlayService: updateState called - color: ${state.currentColor}, countdown: ${state.countdownSeconds}');
    
    if (_overlayEntry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_overlayEntry != null) {
          _overlayEntry!.markNeedsBuild();
        }
      });
    } else {
      _tryShowOverlay();
    }
  }

  void _tryShowOverlay() {
    // Schedule overlay operations for after current build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentSettings?.overlayEnabled == true && _overlayEntry == null && _context != null) {
        debugPrint('FloatingOverlayService: Attempting to show overlay');
        _showOverlay();
      } else if (_currentSettings?.overlayEnabled == false && _overlayEntry != null) {
        debugPrint('FloatingOverlayService: Hiding overlay');
        _hideOverlay();
      } else if (_overlayEntry != null) {
        debugPrint('FloatingOverlayService: Updating existing overlay');
        // Update existing overlay
        _overlayEntry!.markNeedsBuild();
      } else {
        debugPrint('FloatingOverlayService: No action taken - overlayEnabled: ${_currentSettings?.overlayEnabled}, hasEntry: ${_overlayEntry != null}, hasContext: ${_context != null}, hasState: ${_currentState != null}');
      }
    });
  }

  void _showOverlay() {
    debugPrint('FloatingOverlayService: _showOverlay called');
    debugPrint('FloatingOverlayService: _overlayEntry: ${_overlayEntry != null}, _context: ${_context != null}, _currentSettings: ${_currentSettings != null}, _currentState: ${_currentState != null}');
    
    if (_overlayEntry != null || _context == null || _currentSettings == null) {
      debugPrint('FloatingOverlayService: _showOverlay early return - cannot show overlay');
      return;
    }

    // Provide default state if none exists
    _currentState ??= TrafficLightState(
      currentColor: TrafficLightColor.red,
      timestamp: DateTime.now(),
      countdownSeconds: 0,
    );

    try {
      final overlay = Overlay.of(_context!);
      
      _overlayEntry = OverlayEntry(
        builder: (context) => DraggableFloatingOverlay(
          state: _currentState!,
          size: _currentSettings!.overlaySize,
          transparency: _currentSettings!.overlayTransparency,
          initialX: _currentSettings!.overlayPositionX,
          initialY: _currentSettings!.overlayPositionY,
          onPositionChanged: (x, y) {
            updatePosition(x, y);
          },
          onDoubleTap: () {
            // Bring app to foreground
            if (Navigator.canPop(context)) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
        ),
      );

      overlay.insert(_overlayEntry!);
    } catch (e) {
      debugPrint('Failed to show overlay: $e');
      _overlayEntry = null;
    }
  }

  void _hideOverlay() {
    if (_overlayEntry != null) {
      try {
        _overlayEntry!.remove();
      } catch (e) {
        debugPrint('Failed to remove overlay: $e');
      }
      _overlayEntry = null;
    }
  }

  void updatePosition(double x, double y) {
    if (_currentSettings != null) {
      _currentSettings = _currentSettings!.copyWith(
        overlayPositionX: x,
        overlayPositionY: y,
      );
      _onPositionChanged?.call(x, y);
    }
  }

  void dispose() {
    _hideOverlay();
    _context = null;
    _currentSettings = null;
    _currentState = null;
  }
}