import 'dart:io';
import 'package:flutter/services.dart';

class OverlayPermissionService {
  static const MethodChannel _channel = MethodChannel('com.example.traffic_app/overlay');

  static Future<bool> checkOverlayPermission() async {
    if (!Platform.isAndroid) return true;
    
    try {
      final bool hasPermission = await _channel.invokeMethod('checkOverlayPermission');
      return hasPermission;
    } catch (e) {
      return false;
    }
  }

  static Future<void> requestOverlayPermission() async {
    if (!Platform.isAndroid) return;
    
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } catch (e) {
      // Handle error silently
    }
  }
}