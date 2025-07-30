import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/traffic_light_provider.dart';
import '../widgets/traffic_light_widget.dart';
import '../models/traffic_light_state.dart';
import '../constants/colors.dart';

class MinimalModeScreen extends StatelessWidget {
  const MinimalModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onLongPress: () {
            // Navigate back to main screen on long press
            Navigator.of(context).pop();
          },
          child: Consumer<TrafficLightProvider>(
            builder: (context, trafficProvider, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Traffic light and timer in horizontal layout
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Traffic light widget - reduced width
                        Container(
                          width: 120, // Fixed width (1/4 of previous effective width)
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
                          child: Transform.scale(
                            scale: 2.0, // Double the size
                            child: TrafficLightWidget(
                              state: trafficProvider.currentState,
                              isMinimalistic: true,
                              showCountdown: false,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 80),
                        
                        // Timer display - reduced height
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getTimerColor(trafficProvider.currentState.currentColor),
                              width: 3,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer,
                                color: _getTimerColor(trafficProvider.currentState.currentColor),
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${trafficProvider.currentState.countdownSeconds ?? 0}',
                                style: TextStyle(
                                  color: _getTimerColor(trafficProvider.currentState.currentColor),
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 80),
                    
                    // Instructions
                    Text(
                      'Long press to exit minimal mode',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  
  Color _getTimerColor(TrafficLightColor color) {
    switch (color) {
      case TrafficLightColor.red:
        return TrafficLightColors.vividRed;
      case TrafficLightColor.yellow:
        return TrafficLightColors.vividYellow;
      case TrafficLightColor.green:
        return TrafficLightColors.vividGreen;
    }
  }
}