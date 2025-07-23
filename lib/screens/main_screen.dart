import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/traffic_light_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/traffic_light_widget.dart';
import '../widgets/draggable_overlay.dart';
import '../models/app_settings.dart';
import '../models/traffic_light_state.dart';
import '../l10n/app_localizations.dart';
import 'settings_screen.dart';
import 'event_log_screen.dart';
import 'traffic_light_detail_screen.dart';

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
            onOverlayDoubleTap: () => _openDetailView(context),
            child: Scaffold(
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
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (settings.displayMode == DisplayMode.minimalistic)
                        _buildMinimalisticLayout(context, trafficProvider, settings)
                      else
                        TrafficLightWidget(
                          state: trafficProvider.currentState,
                          isMinimalistic: false,
                          onLongPress: () => _toggleDisplayMode(context),
                          onDoubleTap: () => _openDetailView(context),
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
            trafficProvider.isConnected 
                ? (AppLocalizations.of(context)?.connected ?? 'Connected') 
                : (AppLocalizations.of(context)?.disconnected ?? 'Disconnected'),
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


  Widget _buildDemoModeControls(BuildContext context, TrafficLightProvider trafficProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)?.demoModeControls ?? 'Demo Mode Controls',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)?.testOverlayColorsShort ?? 'Test overlay colors:'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => trafficProvider.testOverlay(TrafficLightColor.red),
                  child: Text(AppLocalizations.of(context)?.red ?? 'Red', style: const TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  onPressed: () => trafficProvider.testOverlay(TrafficLightColor.yellow),
                  child: Text(AppLocalizations.of(context)?.yellow ?? 'Yellow', style: const TextStyle(color: Colors.black)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () => trafficProvider.testOverlay(TrafficLightColor.green),
                  child: Text(AppLocalizations.of(context)?.green ?? 'Green', style: const TextStyle(color: Colors.white)),
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
              AppLocalizations.of(context)?.currentStatus ?? 'Current Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(context, AppLocalizations.of(context)?.signalColor ?? 'Signal Color', _getColorName(state.currentColor, context)),
            if (state.countdownSeconds != null)
              _buildInfoRow(context, AppLocalizations.of(context)?.timeRemaining ?? 'Time Remaining', '${state.countdownSeconds}s'),
            _buildInfoRow(context, AppLocalizations.of(context)?.lastUpdate ?? 'Last Update', _formatTimestamp(state.timestamp, context)),
            if (state.recognizedSigns.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)?.recognizedSigns ?? 'Recognized Signs',
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

  Widget _buildMinimalisticLayout(BuildContext context, TrafficLightProvider trafficProvider, AppSettings settings) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TrafficLightWidget(
          state: trafficProvider.currentState,
          isMinimalistic: true,
          showCountdown: false, // Don't show countdown inside the widget
          onLongPress: () => _toggleDisplayMode(context),
          onDoubleTap: () => _openDetailView(context),
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(top: 16.0), // Align timer with traffic light top
          child: _buildExternalTimer(context, trafficProvider.currentState),
        ),
      ],
    );
  }

  Widget _buildExternalTimer(BuildContext context, TrafficLightState state) {
    final countdown = state.countdownSeconds ?? 0; // Default to 0 if null
    final color = _getTimerColor(state.currentColor);
    
    return Container(
      width: 80, // Fixed width
      height: 80, // Fixed height - perfect circle
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle, // Always circular
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer,
            color: color,
            size: 16,
          ),
          const SizedBox(height: 2),
          Text(
            '$countdown',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTimerColor(TrafficLightColor color) {
    switch (color) {
      case TrafficLightColor.red:
        return Colors.red;
      case TrafficLightColor.yellow:
        return Colors.amber;
      case TrafficLightColor.green:
        return Colors.green;
    }
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
            tooltip: AppLocalizations.of(context)?.toggleOverlay ?? 'Toggle Overlay',
            child: const Icon(Icons.visibility_off),
          ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: "bug_report",
          onPressed: _reportBug,
          tooltip: AppLocalizations.of(context)?.reportBug ?? 'Report Bug',
          child: const Icon(Icons.bug_report),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    final l10n = AppLocalizations.of(context);
    
    if (difference.inSeconds < 60) {
      return l10n?.secondsAgo(difference.inSeconds) ?? '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return l10n?.minutesAgo(difference.inMinutes) ?? '${difference.inMinutes}m ago';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  String _getColorName(TrafficLightColor color, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (color) {
      case TrafficLightColor.red:
        return l10n?.red ?? 'RED';
      case TrafficLightColor.yellow:
        return l10n?.yellow ?? 'YELLOW';
      case TrafficLightColor.green:
        return l10n?.green ?? 'GREEN';
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

  void _toggleDisplayMode(BuildContext context) {
    final settingsProvider = context.read<SettingsProvider>();
    final currentMode = settingsProvider.settings.displayMode;
    final newMode = currentMode == DisplayMode.minimalistic 
        ? DisplayMode.advanced 
        : DisplayMode.minimalistic;
    
    settingsProvider.updateDisplayMode(newMode);
    
    final l10n = AppLocalizations.of(context);
    final modeName = newMode == DisplayMode.minimalistic 
        ? (l10n?.minimalistic ?? 'Minimalistic')
        : (l10n?.advanced ?? 'Advanced');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n?.displayModeSwitchedTo(modeName) ?? 'Display mode switched to $modeName'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openDetailView(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TrafficLightDetailScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  void _reportBug() {
    // In a real app, this would automatically export logs and device info
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)?.bugReportMessage ?? 'Bug report feature would export logs and device info'),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}