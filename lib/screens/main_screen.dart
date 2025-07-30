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
                          isDemoMode: trafficProvider.demoMode,
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
                          // Traffic Signal Status Display
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                            decoration: BoxDecoration(
                              color: _getSignalStatusColor(trafficProvider.currentState.currentColor),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _getSignalStatusText(trafficProvider.currentState.currentColor),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _getSignalTextColor(trafficProvider.currentState.currentColor),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getSignalDescription(trafficProvider.currentState.currentColor),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _getSignalTextColor(trafficProvider.currentState.currentColor),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
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
                              child: trafficProvider.currentState.recognizedSigns.isNotEmpty
                                  ? ListView.builder(
                                      padding: const EdgeInsets.all(8),
                                      itemCount: trafficProvider.currentState.recognizedSigns.length,
                                      itemBuilder: (context, index) {
                                        final sign = trafficProvider.currentState.recognizedSigns[index];
                                        return Container(
                                          margin: const EdgeInsets.symmetric(vertical: 2),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                _getRoadSignIcon(sign),
                                                size: 16,
                                                color: Colors.blue,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  _getRoadSignName(sign),
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                                  : const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.remove_red_eye,
                                            size: 36,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'No signs\ndetected',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
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

  IconData _getRoadSignIcon(RoadSign sign) {
    switch (sign) {
      case RoadSign.stop:
        return Icons.stop;
      case RoadSign.yield:
        return Icons.warning;
      case RoadSign.speedLimit:
        return Icons.speed;
      case RoadSign.noEntry:
        return Icons.do_not_disturb;
      case RoadSign.construction:
        return Icons.construction;
      case RoadSign.pedestrianCrossing:
        return Icons.accessibility;
      case RoadSign.turnLeft:
        return Icons.turn_left;
      case RoadSign.turnRight:
        return Icons.turn_right;
      case RoadSign.goStraight:
        return Icons.straight;
    }
  }

  Color _getSignalStatusColor(TrafficLightColor color) {
    switch (color) {
      case TrafficLightColor.red:
        return const Color(0xFFFFCDD2); // Light red background
      case TrafficLightColor.yellow:
        return const Color(0xFFFFF9C4); // Light yellow background
      case TrafficLightColor.green:
        return const Color(0xFFC8E6C9); // Light green background
    }
  }

  Color _getSignalTextColor(TrafficLightColor color) {
    switch (color) {
      case TrafficLightColor.red:
        return const Color(0xFFB71C1C); // Dark red text
      case TrafficLightColor.yellow:
        return const Color(0xFFE65100); // Dark orange text
      case TrafficLightColor.green:
        return const Color(0xFF1B5E20); // Dark green text
    }
  }

  String _getSignalStatusText(TrafficLightColor color) {
    switch (color) {
      case TrafficLightColor.red:
        return 'STOP';
      case TrafficLightColor.yellow:
        return 'CAUTION';
      case TrafficLightColor.green:
        return 'GO';
    }
  }

  String _getSignalDescription(TrafficLightColor color) {
    switch (color) {
      case TrafficLightColor.red:
        return 'Complete stop\nrequired';
      case TrafficLightColor.yellow:
        return 'Prepare to stop\nif safe';
      case TrafficLightColor.green:
        return 'Proceed when\nsafe';
    }
  }
}