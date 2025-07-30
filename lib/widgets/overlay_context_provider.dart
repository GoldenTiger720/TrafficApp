import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/floating_overlay_service.dart';
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
  final FloatingOverlayService _overlayService = FloatingOverlayService();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize after this widget is built (which means Navigator/Overlay exists)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        debugPrint('OverlayContextProvider: Initializing with Navigator context');
        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
        
        // This context will have access to the Overlay
        _overlayService.initialize(
          context,
          onPositionChanged: (x, y) {
            settingsProvider.updateOverlayPosition(x, y);
          },
        );
        _initialized = true;
        _updateOverlay();
      }
    });
  }

  @override
  void dispose() {
    _overlayService.dispose();
    super.dispose();
  }

  void _updateOverlay() {
    if (!_initialized || !mounted) return;

    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final trafficLightProvider = Provider.of<TrafficLightProvider>(context, listen: false);

    debugPrint('OverlayContextProvider: _updateOverlay - overlayEnabled: ${settingsProvider.settings.overlayEnabled}');
    
    _overlayService.updateState(trafficLightProvider.currentState);
    _overlayService.updateSettings(settingsProvider.settings);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, TrafficLightProvider>(
      builder: (context, settingsProvider, trafficLightProvider, child) {
        // Update overlay when providers change
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_initialized && mounted) {
            _overlayService.updateState(trafficLightProvider.currentState);
            _overlayService.updateSettings(settingsProvider.settings);
          }
        });

        return widget.child;
      },
    );
  }
}