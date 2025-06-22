import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/traffic_light_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/traffic_light_widget.dart';
import '../widgets/draggable_overlay.dart';
import '../models/app_settings.dart';
import '../models/traffic_light_state.dart';
import 'settings_screen.dart';
import 'event_log_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  @override
  Widget build(BuildContext context) {
    return Consumer2<TrafficLightProvider, SettingsProvider>(
      builder: (context, trafficProvider, settingsProvider, child) {
        final settings = settingsProvider.settings;
        final trafficState = trafficProvider.currentState;
        
        return OverlayManager(
            overlayEnabled: settings.overlayEnabled,
            trafficLightState: trafficState,
            transparency: settings.overlayTransparency,
            size: settings.overlaySize,
            positionX: settings.overlayPositionX,
            positionY: settings.overlayPositionY,
            isMinimalistic: settings.displayMode == DisplayMode.minimalistic,
            onPositionChanged: (x, y) {
              settingsProvider.updateOverlayPosition(x, y);
            },
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Traffic Light Monitor'),
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.history),
                    onPressed: () => _navigateToEventLog(context),
                    tooltip: 'Event Log',
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => _navigateToSettings(context),
                    tooltip: 'Settings',
                  ),
                ],
              ),
              body: _buildBody(context, trafficProvider, settings),
              floatingActionButton: _buildFloatingActionButtons(context, trafficProvider, settings),
            ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, TrafficLightProvider trafficProvider, AppSettings settings) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildStatusBar(context, trafficProvider),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (settings.displayMode == DisplayMode.advanced) ...[
                        _buildConnectionStatus(context, trafficProvider),
                        const SizedBox(height: 32),
                      ],
                      TrafficLightWidget(
                        state: trafficProvider.currentState,
                        isMinimalistic: settings.displayMode == DisplayMode.minimalistic,
                      ),
                      const SizedBox(height: 32),
                      if (trafficProvider.demoMode)
                        _buildDemoModeControls(context, trafficProvider),
                      if (settings.displayMode == DisplayMode.advanced)
                        _buildAdditionalInfo(context, trafficProvider),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(BuildContext context, TrafficLightProvider trafficProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: trafficProvider.isConnected ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: trafficProvider.isConnected ? Colors.green : Colors.red,
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            trafficProvider.isConnected ? Icons.wifi : Icons.wifi_off,
            color: trafficProvider.isConnected ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            trafficProvider.isConnected ? 'Connected' : 'Disconnected',
            style: TextStyle(
              color: trafficProvider.isConnected ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (trafficProvider.demoMode) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'DEMO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(BuildContext context, TrafficLightProvider trafficProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  trafficProvider.isConnected ? Icons.check_circle : Icons.error,
                  color: trafficProvider.isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  trafficProvider.isConnected ? 'Device Connected' : 'Device Disconnected',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: trafficProvider.isConnected ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${_formatTimestamp(trafficProvider.currentState.timestamp)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoModeControls(BuildContext context, TrafficLightProvider trafficProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Demo Mode Controls',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            const Text('Test overlay colors:'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => trafficProvider.testOverlay(TrafficLightColor.red),
                  child: const Text('Red', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  onPressed: () => trafficProvider.testOverlay(TrafficLightColor.yellow),
                  child: const Text('Yellow', style: TextStyle(color: Colors.black)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () => trafficProvider.testOverlay(TrafficLightColor.green),
                  child: const Text('Green', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo(BuildContext context, TrafficLightProvider trafficProvider) {
    final state = trafficProvider.currentState;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(context, 'Signal Color', state.currentColor.name.toUpperCase()),
            if (state.countdownSeconds != null)
              _buildInfoRow(context, 'Time Remaining', '${state.countdownSeconds}s'),
            _buildInfoRow(context, 'Last Update', _formatTimestamp(state.timestamp)),
            if (state.recognizedSigns.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Recognized Signs',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: state.recognizedSigns.map((sign) => Chip(
                  label: Text(sign.name.toUpperCase()),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          )),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons(BuildContext context, TrafficLightProvider trafficProvider, AppSettings settings) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (settings.overlayEnabled)
          FloatingActionButton(
            heroTag: "toggle_overlay",
            onPressed: () {
              context.read<SettingsProvider>().updateOverlayEnabled(!settings.overlayEnabled);
            },
            tooltip: 'Toggle Overlay',
            child: const Icon(Icons.visibility_off),
          ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: "bug_report",
          onPressed: _reportBug,
          tooltip: 'Report Bug',
          child: const Icon(Icons.bug_report),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }


  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _navigateToEventLog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const EventLogScreen()),
    );
  }

  void _reportBug() {
    // In a real app, this would automatically export logs and device info
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bug report feature would export logs and device info'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}