import 'package:flutter/material.dart';
import '../models/traffic_light_state.dart';

class TrafficLightOverlayWidget extends StatelessWidget {
  final TrafficLightState state;
  final bool showCountdown;

  const TrafficLightOverlayWidget({
    super.key,
    required this.state,
    this.showCountdown = true,
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
          _buildTrafficLight(),
          if (showCountdown && state.countdownSeconds != null) ...[
            const SizedBox(height: 12),
            _buildCountdownTimer(context),
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
        border: Border.all(color: Colors.grey[600]!, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
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
        shadowColor = Colors.red;
        break;
      case TrafficLightColor.yellow:
        lightColor = isActive ? Colors.amber : Colors.amber.withOpacity(0.3);
        shadowColor = Colors.amber;
        break;
      case TrafficLightColor.green:
        lightColor = isActive ? Colors.green : Colors.green.withOpacity(0.3);
        shadowColor = Colors.green;
        break;
    }

    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: lightColor,
        border: Border.all(
          color: isActive ? shadowColor : Colors.grey[700]!,
          width: 2,
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: shadowColor.withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: shadowColor.withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ] : null,
      ),
      child: isActive ? Center(
        child: Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: lightColor.withOpacity(0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(-3, -3),
              ),
            ],
          ),
        ),
      ) : null,
    );
  }

  Widget _buildCountdownTimer(BuildContext context) {
    final countdown = state.countdownSeconds!;
    final color = _getTimerColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '$countdown',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            's',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTimerColor() {
    switch (state.currentColor) {
      case TrafficLightColor.red:
        return Colors.red;
      case TrafficLightColor.yellow:
        return Colors.amber;
      case TrafficLightColor.green:
        return Colors.green;
    }
  }
}