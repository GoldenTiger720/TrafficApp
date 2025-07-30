import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/system_overlay_service.dart';
import '../providers/settings_provider.dart';
import '../providers/traffic_light_provider.dart';
import '../models/app_settings.dart';
import '../models/traffic_light_state.dart';

class OverlayContextProvider extends StatefulWidget {
  final Widget child;

  const OverlayContextProvider({
    super.key,
    required this.child,
  });

  @override
  State<OverlayContextProvider> createState() => _OverlayContextProviderState();
}

class _OverlayContextProviderState extends State<OverlayContextProvider> {
  bool _initialized = false;
  AppSettings? _lastSettings;
  TrafficLightState? _lastState;

  @override
  void initState() {
    super.initState();
    
    // Initialize system overlay after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        debugPrint('OverlayContextProvider: Initializing system overlay');
        _initialized = true;
        _updateSystemOverlay();
      }
    });
  }

  @override
  void dispose() {
    SystemOverlayService.dispose();
    super.dispose();
  }

  void _updateSystemOverlay() async {
    if (!_initialized || !mounted) return;

    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final trafficLightProvider = Provider.of<TrafficLightProvider>(context, listen: false);

    final currentSettings = settingsProvider.settings;
    final currentState = trafficLightProvider.currentState;

    debugPrint('OverlayContextProvider: _updateSystemOverlay - overlayEnabled: ${currentSettings.overlayEnabled}');
    
    if (currentSettings.overlayEnabled) {
      // Check permission first
      final hasPermission = await SystemOverlayService.checkOverlayPermission();
      if (!hasPermission) {
        debugPrint('OverlayContextProvider: No overlay permission, requesting...');
        await SystemOverlayService.requestOverlayPermission();
        return;
      }

      // Start or update system overlay
      if (!SystemOverlayService.isServiceRunning) {
        await SystemOverlayService.startSystemOverlay(
          settings: currentSettings,
          state: currentState,
        );
        _lastSettings = currentSettings;
        _lastState = currentState;
      } else {
        // Only update what has changed
        bool stateChanged = _lastState == null ||
          _lastState!.currentColor != currentState.currentColor ||
          _lastState!.countdownSeconds != currentState.countdownSeconds;
          
        bool positionChanged = _lastSettings == null ||
          _lastSettings!.overlayPositionX != currentSettings.overlayPositionX ||
          _lastSettings!.overlayPositionY != currentSettings.overlayPositionY;
          
        bool nonPositionSettingsChanged = _lastSettings == null ||
          _lastSettings!.overlayTransparency != currentSettings.overlayTransparency ||
          _lastSettings!.overlaySize != currentSettings.overlaySize;

        if (stateChanged) {
          debugPrint('OverlayContextProvider: Updating overlay state only');
          await SystemOverlayService.updateOverlayState(currentState);
          _lastState = currentState;
        }
        
        if (positionChanged && !nonPositionSettingsChanged) {
          debugPrint('OverlayContextProvider: Updating overlay position only');
          await SystemOverlayService.updateOverlayPosition(
            currentSettings.overlayPositionX,
            currentSettings.overlayPositionY,
          );
          _lastSettings = currentSettings;
        } else if (nonPositionSettingsChanged) {
          debugPrint('OverlayContextProvider: Updating overlay settings (including position)');
          await SystemOverlayService.updateOverlaySettings(currentSettings);
          _lastSettings = currentSettings;
        } else if (positionChanged) {
          // This handles the case where both position and non-position settings changed
          debugPrint('OverlayContextProvider: Updating overlay settings (including position)');
          await SystemOverlayService.updateOverlaySettings(currentSettings);
          _lastSettings = currentSettings;
        }
      }
    } else {
      // Stop system overlay if running
      if (SystemOverlayService.isServiceRunning) {
        await SystemOverlayService.stopSystemOverlay();
      }
      _lastSettings = null;
      _lastState = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, TrafficLightProvider>(
      builder: (context, settingsProvider, trafficLightProvider, child) {
        // Update system overlay when providers change
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_initialized && mounted) {
            _updateSystemOverlay();
          }
        });

        return widget.child;
      },
    );
  }
}