import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/traffic_light_state.dart';
import '../models/app_settings.dart';
import 'overlay_service.dart';

class GlobalOverlayManager {
  static final GlobalOverlayManager _instance = GlobalOverlayManager._internal();
  factory GlobalOverlayManager() => _instance;
  GlobalOverlayManager._internal();

  bool _isInitialized = false;
  AppSettings? _currentSettings;
  TrafficLightState? _currentState;

  Future<void> initialize(AppSettings settings) async {
    if (!Platform.isAndroid) return;
    
    _currentSettings = settings;
    _isInitialized = true;
    
    if (settings.overlayEnabled) {
      // Initialize with a default state if no state exists yet
      if (_currentState == null) {
        _currentState = TrafficLightState(
          currentColor: TrafficLightColor.red,
          timestamp: DateTime.now(),
        );
      }
      await _startOverlay();
    }
  }

  Future<void> updateSettings(AppSettings settings) async {
    if (!Platform.isAndroid || !_isInitialized) return;
    
    final wasEnabled = _currentSettings?.overlayEnabled ?? false;
    final isEnabled = settings.overlayEnabled;
    
    _currentSettings = settings;
    
    if (!wasEnabled && isEnabled) {
      // Overlay was just enabled
      // Initialize with a default state if no state exists yet
      if (_currentState == null) {
        _currentState = TrafficLightState(
          currentColor: TrafficLightColor.red,
          timestamp: DateTime.now(),
        );
      }
      await _startOverlay();
    } else if (wasEnabled && !isEnabled) {
      // Overlay was just disabled
      await OverlayService.stopOverlayService();
    } else if (isEnabled && OverlayService.isServiceRunning) {
      // Update overlay settings
      await OverlayService.updateOverlaySettings(
        transparency: settings.overlayTransparency,
        size: settings.overlaySize,
        positionX: settings.overlayPositionX,
        positionY: settings.overlayPositionY,
      );
    }
  }

  Future<void> updateTrafficLightState(TrafficLightState state) async {
    if (!Platform.isAndroid || !_isInitialized) return;
    
    _currentState = state;
    
    if (_currentSettings?.overlayEnabled == true && OverlayService.isServiceRunning) {
      await OverlayService.updateOverlayState(state);
    }
  }

  Future<void> _startOverlay() async {
    if (_currentSettings == null || _currentState == null) return;
    
    await OverlayService.startOverlayService(
      transparency: _currentSettings!.overlayTransparency,
      size: _currentSettings!.overlaySize,
      positionX: _currentSettings!.overlayPositionX,
      positionY: _currentSettings!.overlayPositionY,
    );
    
    // Give the service a moment to fully initialize before sending state
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Always send the current state to the overlay immediately after starting
    await OverlayService.updateOverlayState(_currentState!);
  }

  Future<void> dispose() async {
    if (Platform.isAndroid && OverlayService.isServiceRunning) {
      await OverlayService.stopOverlayService();
    }
  }
}