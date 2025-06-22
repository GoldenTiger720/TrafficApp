import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/traffic_light_state.dart';

class ConnectionService {
  final StreamController<TrafficLightState> _dataController = 
      StreamController<TrafficLightState>.broadcast();
  final StreamController<bool> _connectionStatusController = 
      StreamController<bool>.broadcast();
  
  Stream<TrafficLightState> get dataStream => _dataController.stream;
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  BluetoothDevice? _bluetoothDevice;
  bool _isConnected = false;

  Future<List<BluetoothDevice>> scanForBluetoothDevices() async {
    try {
      if (!await _requestBluetoothPermissions()) {
        return [];
      }

      // Start scanning
      var subscription = FlutterBluePlus.scanResults.listen((results) {
        // Handle scan results
      });
      
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      await FlutterBluePlus.stopScan();
      
      subscription.cancel();

      // Get system devices (bonded devices)
      final List<BluetoothDevice> devices = await FlutterBluePlus.systemDevices([]);

      return devices.where((device) => 
        device.platformName.toLowerCase().contains('raspberry') ||
        device.platformName.toLowerCase().contains('pi') ||
        device.platformName.toLowerCase().contains('traffic')
      ).toList();
    } catch (e) {
      debugPrint('Error scanning for Bluetooth devices: $e');
      return [];
    }
  }

  Future<bool> _requestBluetoothPermissions() async {
    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ];

    for (final permission in permissions) {
      final status = await permission.request();
      if (!status.isGranted) {
        return false;
      }
    }
    return true;
  }

  Future<bool> connectToBluetooth(String deviceId) async {
    try {
      if (_bluetoothDevice?.isConnected == true) {
        await _bluetoothDevice!.disconnect();
      }

      // Find device by remote ID
      final devices = await FlutterBluePlus.systemDevices([]);
      _bluetoothDevice = devices.firstWhere(
        (device) => device.remoteId.toString() == deviceId,
        orElse: () => throw Exception('Device not found'),
      );

      await _bluetoothDevice!.connect();
      _isConnected = true;
      _connectionStatusController.add(true);

      // Listen for disconnection
      _bluetoothDevice!.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _isConnected = false;
          _connectionStatusController.add(false);
        }
      });

      return true;
    } catch (e) {
      debugPrint('Error connecting to Bluetooth: $e');
      _isConnected = false;
      _connectionStatusController.add(false);
      return false;
    }
  }

  void _handleBluetoothData(List<int> data) {
    try {
      final jsonString = String.fromCharCodes(data);
      final jsonData = json.decode(jsonString);
      
      final state = TrafficLightState(
        currentColor: TrafficLightColor.values.firstWhere(
          (color) => color.name == jsonData['color'],
          orElse: () => TrafficLightColor.red,
        ),
        countdownSeconds: jsonData['countdown'],
        recognizedSigns: (jsonData['signs'] as List?)
            ?.map((sign) => RoadSign.values.firstWhere(
                  (s) => s.name == sign,
                  orElse: () => RoadSign.stop,
                ))
            .toList() ?? [],
        timestamp: DateTime.now(),
      );

      _dataController.add(state);
    } catch (e) {
      debugPrint('Error parsing Bluetooth data: $e');
    }
  }

  Future<List<String>> scanForWiFiDevices() async {
    try {
      // Placeholder for WiFi scanning
      // In a real implementation, you would scan for WiFi networks
      // and look for specific Raspberry Pi networks
      return [
        'RaspberryPi-Traffic-001',
        'RaspberryPi-Traffic-002',
        'TrafficLight-WiFi-01',
      ];
    } catch (e) {
      debugPrint('Error scanning for WiFi devices: $e');
      return [];
    }
  }

  Future<bool> connectToWiFi(String networkName) async {
    try {
      // Placeholder for WiFi connection
      // In a real implementation, you would connect to the WiFi network
      // and establish a TCP/UDP connection to the Raspberry Pi
      await Future.delayed(const Duration(seconds: 2));
      
      _isConnected = true;
      _connectionStatusController.add(true);
      
      // Simulate receiving data
      _simulateWiFiData();
      
      return true;
    } catch (e) {
      debugPrint('Error connecting to WiFi: $e');
      _isConnected = false;
      _connectionStatusController.add(false);
      return false;
    }
  }

  void _simulateWiFiData() {
    // This is a placeholder for actual WiFi data reception
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isConnected) {
        timer.cancel();
        return;
      }
      
      // Simulate random traffic light data
      final colors = TrafficLightColor.values;
      final randomColor = colors[DateTime.now().second % colors.length];
      
      final state = TrafficLightState(
        currentColor: randomColor,
        countdownSeconds: 30 - (DateTime.now().second % 30),
        recognizedSigns: [],
        timestamp: DateTime.now(),
      );
      
      _dataController.add(state);
    });
  }

  Future<void> disconnect() async {
    try {
      if (_bluetoothDevice?.isConnected == true) {
        await _bluetoothDevice!.disconnect();
      }
      
      _isConnected = false;
      _connectionStatusController.add(false);
    } catch (e) {
      debugPrint('Error disconnecting: $e');
    }
  }

  bool get isConnected => _isConnected;

  void dispose() {
    disconnect();
    _dataController.close();
    _connectionStatusController.close();
  }
}