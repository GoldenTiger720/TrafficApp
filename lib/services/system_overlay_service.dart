import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/traffic_light_state.dart';
import '../models/app_settings.dart';

class SystemOverlayService {
  static const MethodChannel _channel = MethodChannel('com.example.traffic_app/overlay');

  static bool _isServiceRunning = false;
  static bool get isServiceRunning => _isServiceRunning;

  /// Check if the app has overlay permission
  static Future<bool> checkOverlayPermission() async {
    if (!Platform.isAndroid) return true;
    
    try {
      final bool hasPermission = await _channel.invokeMethod('checkOverlayPermission');
      return hasPermission;
    } catch (e) {
      debugPrint('SystemOverlayService: Failed to check permission: $e');
      return false;
    }
  }

  /// Request overlay permission from user
  static Future<void> requestOverlayPermission() async {
    if (!Platform.isAndroid) return;
    
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } catch (e) {
      debugPrint('SystemOverlayService: Failed to request permission: $e');
    }
  }

  /// Start the system overlay service
  static Future<bool> startSystemOverlay({
    required AppSettings settings,
    required TrafficLightState state,
  }) async {
    if (!Platform.isAndroid) return false;
    
    try {
      final bool result = await _channel.invokeMethod('startSystemOverlay', {
        'transparency': settings.overlayTransparency,
        'size': settings.overlaySize,
        'positionX': settings.overlayPositionX,
        'positionY': settings.overlayPositionY,
        'color': _getColorString(state.currentColor),
        'countdown': state.countdownSeconds ?? 0,
      });
      
      if (result) {
        _isServiceRunning = true;
        debugPrint('SystemOverlayService: System overlay started successfully');
      }
      
      return result;
    } catch (e) {
      debugPrint('SystemOverlayService: Failed to start system overlay: $e');
      return false;
    }
  }

  /// Stop the system overlay service
  static Future<bool> stopSystemOverlay() async {
    if (!Platform.isAndroid) return false;
    
    try {
      final bool result = await _channel.invokeMethod('stopSystemOverlay');
      if (result) {
        _isServiceRunning = false;
        debugPrint('SystemOverlayService: System overlay stopped successfully');
      }
      return result;
    } catch (e) {
      debugPrint('SystemOverlayService: Failed to stop system overlay: $e');
      return false;
    }
  }

  /// Update the traffic light state in the system overlay
  static Future<bool> updateOverlayState(TrafficLightState state) async {
    if (!Platform.isAndroid || !_isServiceRunning) return false;
    
    try {
      final bool result = await _channel.invokeMethod('updateSystemOverlayState', {
        'color': _getColorString(state.currentColor),
        'countdown': state.countdownSeconds ?? 0,
      });
      
      if (result) {
        debugPrint('SystemOverlayService: Overlay state updated - ${state.currentColor}, ${state.countdownSeconds}');
      }
      
      return result;
    } catch (e) {
      debugPrint('SystemOverlayService: Failed to update overlay state: $e');
      return false;
    }
  }

  /// Update the system overlay settings
  static Future<bool> updateOverlaySettings(AppSettings settings) async {
    if (!Platform.isAndroid || !_isServiceRunning) return false;
    
    try {
      final bool result = await _channel.invokeMethod('updateSystemOverlaySettings', {
        'transparency': settings.overlayTransparency,
        'size': settings.overlaySize,
        'positionX': settings.overlayPositionX,
        'positionY': settings.overlayPositionY,
      });
      
      if (result) {
        debugPrint('SystemOverlayService: Overlay settings updated');
      }
      
      return result;
    } catch (e) {
      debugPrint('SystemOverlayService: Failed to update overlay settings: $e');
      return false;
    }
  }

  /// Update only the system overlay position
  static Future<bool> updateOverlayPosition(double positionX, double positionY) async {
    if (!Platform.isAndroid || !_isServiceRunning) return false;
    
    try {
      final bool result = await _channel.invokeMethod('updateSystemOverlayPosition', {
        'positionX': positionX,
        'positionY': positionY,
      });
      
      if (result) {
        debugPrint('SystemOverlayService: Overlay position updated - x: $positionX, y: $positionY');
      }
      
      return result;
    } catch (e) {
      debugPrint('SystemOverlayService: Failed to update overlay position: $e');
      return false;
    }
  }

  /// Convert TrafficLightColor enum to string
  static String _getColorString(TrafficLightColor color) {
    switch (color) {
      case TrafficLightColor.red:
        return 'red';
      case TrafficLightColor.yellow:
        return 'yellow';
      case TrafficLightColor.green:
        return 'green';
    }
  }

  /// Dispose and clean up resources
  static Future<void> dispose() async {
    if (_isServiceRunning) {
      await stopSystemOverlay();
    }
  }
}