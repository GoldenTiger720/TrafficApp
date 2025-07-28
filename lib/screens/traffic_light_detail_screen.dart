import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/traffic_light_state.dart';
import '../models/app_settings.dart';
import '../providers/traffic_light_provider.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';

class TrafficLightDetailScreen extends StatelessWidget {
  const TrafficLightDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocalizations.of(context)?.trafficLightMonitor ?? 'TURIST',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Consumer2<TrafficLightProvider, SettingsProvider>(
        builder: (context, trafficProvider, settingsProvider, child) {
          final state = trafficProvider.currentState;
          final settings = settingsProvider.settings;
          
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildLargeTrafficLight(context, state),
                  const SizedBox(height: 32),
                  _buildDetailedInfo(context, state, trafficProvider),
                  const SizedBox(height: 24),
                  if (trafficProvider.demoMode)
                    _buildDemoControls(context, trafficProvider),
                  const SizedBox(height: 24),
                  _buildQuickActions(context, settingsProvider, trafficProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLargeTrafficLight(BuildContext context, TrafficLightState state) {
    return Center(
      child: Container(
        width: 160,
        height: 360,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(80),
          border: Border.all(color: Colors.grey[600]!, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLargeLight(TrafficLightColor.red, state.currentColor == TrafficLightColor.red),
            _buildLargeLight(TrafficLightColor.yellow, state.currentColor == TrafficLightColor.yellow),
            _buildLargeLight(TrafficLightColor.green, state.currentColor == TrafficLightColor.green),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeLight(TrafficLightColor color, bool isActive) {
    Color lightColor;
    Color shadowColor;

    switch (color) {
      case TrafficLightColor.red:
        lightColor = isActive ? Colors.red : Colors.red.withOpacity(0.2);
        shadowColor = Colors.red;
        break;
      case TrafficLightColor.yellow:
        lightColor = isActive ? Colors.amber : Colors.amber.withOpacity(0.2);
        shadowColor = Colors.amber;
        break;
      case TrafficLightColor.green:
        lightColor = isActive ? Colors.green : Colors.green.withOpacity(0.2);
        shadowColor = Colors.green;
        break;
    }

    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: lightColor,
        border: Border.all(
          color: isActive ? shadowColor : Colors.grey[700]!,
          width: 3,
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: shadowColor.withOpacity(0.8),
            blurRadius: 30,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: shadowColor.withOpacity(0.6),
            blurRadius: 60,
            spreadRadius: 20,
          ),
        ] : null,
      ),
      child: isActive ? Center(
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: lightColor.withOpacity(0.9),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(-10, -10),
              ),
            ],
          ),
        ),
      ) : null,
    );
  }

  Widget _buildDetailedInfo(BuildContext context, TrafficLightState state, TrafficLightProvider provider) {
    final l10n = AppLocalizations.of(context);
    
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.currentStatus ?? 'Current Status',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              Icons.traffic,
              l10n?.signalColor ?? 'Signal Color',
              _getColorName(state.currentColor, context),
              _getColorForSignal(state.currentColor),
            ),
            if (state.countdownSeconds != null)
              _buildInfoRow(
                context,
                Icons.timer,
                l10n?.timeRemaining ?? 'Time Remaining',
                '${state.countdownSeconds}s',
                Colors.orange,
              ),
            _buildInfoRow(
              context,
              Icons.update,
              l10n?.lastUpdate ?? 'Last Update',
              _formatTimestamp(state.timestamp, context),
              Colors.blue,
            ),
            _buildInfoRow(
              context,
              Icons.wifi,
              l10n?.connected ?? 'Connection',
              provider.isConnected ? (l10n?.connected ?? 'Connected') : (l10n?.disconnected ?? 'Disconnected'),
              provider.isConnected ? Colors.green : Colors.red,
            ),
            if (state.recognizedSigns.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                l10n?.recognizedSigns ?? 'Recognized Signs',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: state.recognizedSigns.map((sign) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _getSignWidget(sign, color: Colors.blue, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _getSignDisplayName(sign),
                        style: const TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoControls(BuildContext context, TrafficLightProvider provider) {
    final l10n = AppLocalizations.of(context);
    
    return Card(
      color: Colors.orange.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              l10n?.demoModeControls ?? 'Demo Mode Controls',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDemoButton(
                  l10n?.red ?? 'Red',
                  Colors.red,
                  () => provider.testOverlay(TrafficLightColor.red),
                ),
                _buildDemoButton(
                  l10n?.yellow ?? 'Yellow',
                  Colors.amber,
                  () => provider.testOverlay(TrafficLightColor.yellow),
                ),
                _buildDemoButton(
                  l10n?.green ?? 'Green',
                  Colors.green,
                  () => provider.testOverlay(TrafficLightColor.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }

  Widget _buildQuickActions(BuildContext context, SettingsProvider settingsProvider, TrafficLightProvider trafficProvider) {
    final l10n = AppLocalizations.of(context);
    final settings = settingsProvider.settings;
    
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.quickActions ?? 'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      settingsProvider.updateDisplayMode(
                        settings.displayMode == DisplayMode.minimalistic 
                            ? DisplayMode.advanced 
                            : DisplayMode.minimalistic
                      );
                    },
                    icon: Icon(settings.displayMode == DisplayMode.minimalistic 
                        ? Icons.expand_more 
                        : Icons.expand_less),
                    label: Text(settings.displayMode == DisplayMode.minimalistic 
                        ? (l10n?.advanced ?? 'Advanced')
                        : (l10n?.minimalistic ?? 'Minimalistic')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      settingsProvider.updateOverlayEnabled(!settings.overlayEnabled);
                    },
                    icon: Icon(settings.overlayEnabled ? Icons.visibility_off : Icons.visibility),
                    label: Text(settings.overlayEnabled 
                        ? (l10n?.hideOverlay ?? 'Hide Overlay')
                        : (l10n?.showOverlay ?? 'Show Overlay')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: settings.overlayEnabled ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForSignal(TrafficLightColor color) {
    switch (color) {
      case TrafficLightColor.red:
        return Colors.red;
      case TrafficLightColor.yellow:
        return Colors.amber;
      case TrafficLightColor.green:
        return Colors.green;
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

  IconData _getSignIcon(RoadSign sign) {
    switch (sign) {
      case RoadSign.stop:
        return Icons.stop;
      case RoadSign.yield:
        return Icons.warning;
      case RoadSign.speedLimit:
        return Icons.speed;
      case RoadSign.noEntry:
        return Icons.block;
      case RoadSign.construction:
        return Icons.construction;
      case RoadSign.pedestrianCrossing:
        return Icons.directions_walk;
      case RoadSign.turnLeft:
        return Icons.turn_left;
      case RoadSign.turnRight:
        return Icons.turn_right;
      case RoadSign.goStraight:
        return Icons.straight;
    }
  }

  Widget _getSignWidget(RoadSign sign, {Color? color, double? size}) {
    switch (sign) {
      case RoadSign.turnLeft:
        return Image.asset(
          'assets/images/left_turn.png',
          width: size ?? 48,
          height: size ?? 48,
        );
      case RoadSign.turnRight:
        return Image.asset(
          'assets/images/right_turn.png',
          width: size ?? 48,
          height: size ?? 48,
        );
      case RoadSign.goStraight:
        return Image.asset(
          'assets/images/straight.png',
          width: size ?? 48,
          height: size ?? 48,
        );
      default:
        return Icon(
          _getSignIcon(sign),
          color: color ?? Colors.white,
          size: size ?? 24,
        );
    }
  }

  String _getSignDisplayName(RoadSign sign) {
    switch (sign) {
      case RoadSign.stop:
        return 'STOP';
      case RoadSign.yield:
        return 'YIELD';
      case RoadSign.speedLimit:
        return 'SPEED LIMIT';
      case RoadSign.noEntry:
        return 'NO ENTRY';
      case RoadSign.construction:
        return 'CONSTRUCTION';
      case RoadSign.pedestrianCrossing:
        return 'PEDESTRIAN';
      case RoadSign.turnLeft:
        return 'TURN LEFT';
      case RoadSign.turnRight:
        return 'TURN RIGHT';
      case RoadSign.goStraight:
        return 'GO STRAIGHT';
    }
  }
}