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
      padding: const EdgeInsets.all(12), // Reduced padding for overlay
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[600]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return _buildTrafficLight();
        },
      ),
    );
  }

  Widget _buildTrafficLight() {
    return Container(
      width: 70, // Reduced from 80 for overlay
      height: 160, // Reduced from 180 for overlay
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
      width: 38, // Reduced from 45 for overlay
      height: 38, // Reduced from 45 for overlay
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
          width: 20, // Reduced from 25 for overlay
          height: 20, // Reduced from 25 for overlay
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

  Widget _buildOverlayCountdownTimer(BuildContext context) {
    final countdown = state.countdownSeconds!;
    final color = _getTimerColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), // Even smaller padding
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12), // Smaller radius
        border: Border.all(color: color, width: 1), // Thinner border
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: color,
            size: 14, // Smaller icon for overlay
          ),
          const SizedBox(width: 4), // Smaller spacing
          Text(
            '$countdown',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14, // Even smaller font for overlay
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