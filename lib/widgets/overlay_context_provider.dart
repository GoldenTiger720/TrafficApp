import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/system_overlay_service.dart';
import '../providers/settings_provider.dart';
import '../providers/traffic_light_provider.dart';

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

    debugPrint('OverlayContextProvider: _updateSystemOverlay - overlayEnabled: ${settingsProvider.settings.overlayEnabled}');
    
    if (settingsProvider.settings.overlayEnabled) {
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
          settings: settingsProvider.settings,
          state: trafficLightProvider.currentState,
        );
      } else {
        await SystemOverlayService.updateOverlayState(trafficLightProvider.currentState);
        await SystemOverlayService.updateOverlaySettings(settingsProvider.settings);
      }
    } else {
      // Stop system overlay if running
      if (SystemOverlayService.isServiceRunning) {
        await SystemOverlayService.stopSystemOverlay();
      }
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