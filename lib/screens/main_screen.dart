import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/traffic_light_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/traffic_light_widget.dart';
import '../models/app_settings.dart';
import '../models/traffic_light_state.dart';
import '../l10n/app_localizations.dart';
import 'settings_screen.dart';
import 'event_log_screen.dart';
import 'traffic_light_detail_screen.dart';
import 'minimal_mode_screen.dart';

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
        
        return Stack(
          children: [
            _buildBody(context, trafficProvider, settings),
            Positioned(
              right: 16,
              bottom: 16,
              child: _buildFloatingActionButtons(context, trafficProvider, settings),
            ),
          ],
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
              child: _buildNewDesignLayout(context, trafficProvider, settings),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewDesignLayout(BuildContext context, TrafficLightProvider trafficProvider, AppSettings settings) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), width: 3),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row with traffic light, timer/button, and signs section
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Traffic light
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        child: TrafficLightWidget(
                          state: trafficProvider.currentState,
                          isMinimalistic: true,
                          showCountdown: false,
                          onLongPress: () => _navigateToMinimalMode(context),
                          onDoubleTap: () => _openDetailView(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Timer and GO button
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Timer display
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${trafficProvider.currentState.countdownSeconds ?? 0}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // GO button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Toggle to green light when GO is pressed
                                if (trafficProvider.demoMode) {
                                  trafficProvider.testOverlay(TrafficLightColor.green);
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('GO pressed')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF90EE90),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(color: Colors.black, width: 2),
                                ),
                              ),
                              child: const Text(
                                'GO',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // SIGNS section
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'SIGNS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: trafficProvider.currentState.recognizedSigns.isNotEmpty
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: trafficProvider.currentState.recognizedSigns
                                            .take(3)
                                            .map((sign) => Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                                  child: Text(
                                                    _getRoadSignName(sign),
                                                    style: const TextStyle(fontSize: 12),
                                                  ),
                                                ))
                                            .toList(),
                                      )
                                    : Icon(
                                        Icons.remove_red_eye,
                                        size: 40,
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Direction arrows
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Left turn arrow
                    Image.asset(
                      'assets/images/left_turn.png',
                      width: 100,
                      height: 100,
                    ),
                    // Straight arrow
                    Image.asset(
                      'assets/images/straight.png',
                      width: 100,
                      height: 100,
                    ),
                    // Right turn arrow
                    Image.asset(
                      'assets/images/right_turn.png',
                      width: 100,
                      height: 100,
                    ),
                  ],
                ),
              ),
            ],
          ),
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



  Widget _buildFloatingActionButtons(BuildContext context, TrafficLightProvider trafficProvider, AppSettings settings) {
    return FloatingActionButton(
      heroTag: "bug_report",
      onPressed: _reportBug,
      tooltip: AppLocalizations.of(context)?.reportBug ?? 'Report Bug',
      child: const Icon(Icons.bug_report),
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

  void _navigateToMinimalMode(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MinimalModeScreen(),
        fullscreenDialog: true,
      ),
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

  String _getRoadSignName(RoadSign sign) {
    switch (sign) {
      case RoadSign.stop:
        return 'Stop';
      case RoadSign.yield:
        return 'Yield';
      case RoadSign.speedLimit:
        return 'Speed Limit';
      case RoadSign.noEntry:
        return 'No Entry';
      case RoadSign.construction:
        return 'Construction';
      case RoadSign.pedestrianCrossing:
        return 'Pedestrian';
      case RoadSign.turnLeft:
        return 'Turn Left';
      case RoadSign.turnRight:
        return 'Turn Right';
      case RoadSign.goStraight:
        return 'Go Straight';
    }
  }
}