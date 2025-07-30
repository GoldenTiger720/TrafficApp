import 'package:flutter/material.dart';
import '../models/traffic_light_state.dart';

class FloatingOverlayWidget extends StatefulWidget {
  final TrafficLightState state;
  final double size;
  final double transparency;
  final VoidCallback? onTap;

  const FloatingOverlayWidget({
    super.key,
    required this.state,
    this.size = 1.0,
    this.transparency = 0.9,
    this.onTap,
  });

  @override
  State<FloatingOverlayWidget> createState() => _FloatingOverlayWidgetState();
}

class _FloatingOverlayWidgetState extends State<FloatingOverlayWidget> {
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.transparency,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: EdgeInsets.all(8 * widget.size),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12 * widget.size),
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
              width: 1 * widget.size,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8 * widget.size,
                spreadRadius: 2 * widget.size,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTrafficLight(),
              SizedBox(width: 12 * widget.size),
              _buildTimer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrafficLight() {
    return Container(
      width: 60 * widget.size,
      height: 140 * widget.size,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8 * widget.size),
        border: Border.all(
          color: Colors.grey[600]!,
          width: 2 * widget.size,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLight(
            TrafficLightColor.red, 
            widget.state.currentColor == TrafficLightColor.red
          ),
          _buildLight(
            TrafficLightColor.yellow, 
            widget.state.currentColor == TrafficLightColor.yellow
          ),
          _buildLight(
            TrafficLightColor.green, 
            widget.state.currentColor == TrafficLightColor.green
          ),
        ],
      ),
    );
  }

  Widget _buildLight(TrafficLightColor color, bool isActive) {
    Color lightColor;
    Color shadowColor;

    switch (color) {
      case TrafficLightColor.red:
        lightColor = isActive ? Colors.red : Colors.grey[700]!;
        shadowColor = Colors.red;
        break;
      case TrafficLightColor.yellow:
        lightColor = isActive ? Colors.amber : Colors.grey[700]!;
        shadowColor = Colors.amber;
        break;
      case TrafficLightColor.green:
        lightColor = isActive ? Colors.green : Colors.grey[700]!;
        shadowColor = Colors.green;
        break;
    }

    return Container(
      width: 32 * widget.size,
      height: 32 * widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: lightColor,
        border: Border.all(
          color: isActive ? shadowColor.withOpacity(0.8) : Colors.grey[600]!,
          width: 1.5 * widget.size,
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: shadowColor.withOpacity(0.6),
            blurRadius: 12 * widget.size,
            spreadRadius: 2 * widget.size,
          ),
        ] : null,
      ),
    );
  }

  Widget _buildTimer() {
    final countdown = widget.state.countdownSeconds ?? 0;
    final timerColor = _getTimerColor();
    
    return Container(
      width: 50 * widget.size,
      height: 40 * widget.size,
      decoration: BoxDecoration(
        color: timerColor,
        borderRadius: BorderRadius.circular(6 * widget.size),
        border: Border.all(
          color: timerColor.withOpacity(0.8),
          width: 2 * widget.size,
        ),
        boxShadow: [
          BoxShadow(
            color: timerColor.withOpacity(0.4),
            blurRadius: 6 * widget.size,
            spreadRadius: 1 * widget.size,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$countdown',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18 * widget.size,
          ),
        ),
      ),
    );
  }

  Color _getTimerColor() {
    switch (widget.state.currentColor) {
      case TrafficLightColor.red:
        return Colors.red;
      case TrafficLightColor.yellow:
        return Colors.amber;
      case TrafficLightColor.green:
        return Colors.green;
    }
  }
}