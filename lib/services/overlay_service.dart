import 'package:flutter/services.dart';
import 'dart:io';
import '../models/traffic_light_state.dart';

class OverlayService {
  static const platform = MethodChannel('com.example.traffic_app/overlay');
  static bool _isServiceRunning = false;
  
  static bool get isServiceRunning => _isServiceRunning;
  
  static Future<bool> checkOverlayPermission() async {
    if (!Platform.isAndroid) return true;
    
    try {
      final bool hasPermission = await platform.invokeMethod('checkOverlayPermission');
      return hasPermission;
    } catch (e) {
      print('Error checking overlay permission: $e');
      return false;
    }
  }
  
  static Future<bool> requestOverlayPermission() async {
    if (!Platform.isAndroid) return false;
    
    try {
      final bool requested = await platform.invokeMethod('requestOverlayPermission');
      return requested;
    } catch (e) {
      print('Error requesting overlay permission: $e');
      return false;
    }
  }
  
  static Future<bool> startOverlayService() async {
    if (!Platform.isAndroid) return false;
    
    try {
      final bool hasPermission = await checkOverlayPermission();
      if (!hasPermission) {
        await requestOverlayPermission();
        return false;
      }
      
      final bool success = await platform.invokeMethod('startOverlayService');
      if (success) {
        _isServiceRunning = true;
      }
      return success;
    } catch (e) {
      print('Error starting overlay service: $e');
      return false;
    }
  }
  
  static Future<bool> stopOverlayService() async {
    if (!Platform.isAndroid) return false;
    
    try {
      final bool success = await platform.invokeMethod('stopOverlayService');
      if (success) {
        _isServiceRunning = false;
      }
      return success;
    } catch (e) {
      print('Error stopping overlay service: $e');
      return false;
    }
  }
  
  static Future<bool> updateOverlayState(TrafficLightState state) async {
    if (!Platform.isAndroid || !_isServiceRunning) return false;
    
    try {
      String colorString;
      switch (state.currentColor) {
        case TrafficLightColor.red:
          colorString = 'red';
          break;
        case TrafficLightColor.yellow:
          colorString = 'yellow';
          break;
        case TrafficLightColor.green:
          colorString = 'green';
          break;
      }
      
      final bool success = await platform.invokeMethod('updateOverlayState', {
        'color': colorString,
        'countdown': state.countdownSeconds ?? 0,
      });
      return success;
    } catch (e) {
      print('Error updating overlay state: $e');
      return false;
    }
  }
}