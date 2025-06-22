import 'package:flutter/material.dart';
import '../models/traffic_light_state.dart';

class TrafficLightWidget extends StatelessWidget {
  final TrafficLightState state;
  final bool isMinimalistic;
  final bool showCountdown;
  final bool showSigns;

  const TrafficLightWidget({
    super.key,
    required this.state,
    this.isMinimalistic = false,
    this.showCountdown = true,
    this.showSigns = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[600]!, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isMinimalistic) ...[
            Text(
              'Traffic Light',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
          ],
          _buildTrafficLight(),
          if (showCountdown && state.countdownSeconds != null) ...[
            const SizedBox(height: 16),
            _buildCountdown(context),
          ],
          if (showSigns && state.recognizedSigns.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildRecognizedSigns(context),
          ],
        ],
      ),
    );
  }

  Widget _buildTrafficLight() {
    return Container(
      width: 80,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.grey[600]!, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLight(TrafficLightColor.red, state.currentColor == TrafficLightColor.red),
          _buildLight(TrafficLightColor.yellow, state.currentColor == TrafficLightColor.yellow),
          _buildLight(TrafficLightColor.green, state.currentColor == TrafficLightColor.green),
        ],
      ),
    );
  }

  Widget _buildLight(TrafficLightColor color, bool isActive) {
    Color lightColor;
    Color shadowColor;

    switch (color) {
      case TrafficLightColor.red:
        lightColor = isActive ? Colors.red : Colors.red.withOpacity(0.3);
        shadowColor = isActive ? Colors.red.withOpacity(0.6) : Colors.transparent;
        break;
      case TrafficLightColor.yellow:
        lightColor = isActive ? Colors.amber : Colors.amber.withOpacity(0.3);
        shadowColor = isActive ? Colors.amber.withOpacity(0.6) : Colors.transparent;
        break;
      case TrafficLightColor.green:
        lightColor = isActive ? Colors.green : Colors.green.withOpacity(0.3);
        shadowColor = isActive ? Colors.green.withOpacity(0.6) : Colors.transparent;
        break;
    }

    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: lightColor,
        boxShadow: isActive ? [
          BoxShadow(
            color: shadowColor,
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ] : null,
      ),
    );
  }

  Widget _buildCountdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            '${state.countdownSeconds}s',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecognizedSigns(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recognized Signs:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: state.recognizedSigns.map((sign) => Chip(
              label: Text(_getSignDisplayName(sign)),
              backgroundColor: Colors.blue.withOpacity(0.2),
              labelStyle: const TextStyle(color: Colors.blue, fontSize: 12),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            )).toList(),
          ),
        ],
      ),
    );
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