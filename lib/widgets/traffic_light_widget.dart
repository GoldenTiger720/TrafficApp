import 'package:flutter/material.dart';
import '../models/traffic_light_state.dart';
import '../l10n/app_localizations.dart';

class TrafficLightWidget extends StatelessWidget {
  final TrafficLightState state;
  final bool isMinimalistic;
  final bool showCountdown;
  final bool showSigns;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;

  const TrafficLightWidget({
    super.key,
    required this.state,
    this.isMinimalistic = false,
    this.showCountdown = true,
    this.showSigns = true,
    this.onLongPress,
    this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onDoubleTap: onDoubleTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[600]!, width: 2),
        ),
        child: isMinimalistic 
            ? _buildMinimalisticView()
            : _buildAdvancedView(context),
      ),
    );
  }

  Widget _buildMinimalisticView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBasicTrafficLight(),
      ],
    );
  }

  Widget _buildAdvancedView(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Text(
          l10n?.trafficLight ?? 'Traffic Light',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Central critical information area
        _buildCentralCriticalArea(context),
        
        // Secondary information: Road signs and lane details
        if (showSigns) ...[
          const SizedBox(height: 16),
          _buildSecondaryInformation(context),
        ],
      ],
    );
  }

  Widget _buildCentralCriticalArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[700]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 3,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          
          if (availableWidth > 320) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Lane markings (left)
                Flexible(
                  flex: 2,
                  child: _buildEnhancedLaneMarkings(true),
                ),
                const SizedBox(width: 20),
                
                // Central critical data: Traffic light + circular timer
                Flexible(
                  flex: 3,
                  child: _buildCentralTrafficDisplay(context),
                ),
                
                const SizedBox(width: 20),
                // Lane markings (right)
                Flexible(
                  flex: 2,
                  child: _buildEnhancedLaneMarkings(false),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                // Central traffic display
                _buildCentralTrafficDisplay(context),
                const SizedBox(height: 16),
                // Compact lane information
                _buildCompactLaneDisplay(context),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildCentralTrafficDisplay(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Traffic light with circular timer positioned next to it
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Main traffic light
            _buildAdvancedTrafficLight(),
            
            // Circular timer (positioned next to traffic light)
            if (showCountdown && state.countdownSeconds != null) ...[
              const SizedBox(width: 16),
              _buildCircularTimer(context),
            ],
          ],
        ),
        
        // Current status indicator
        const SizedBox(height: 12),
        _buildCurrentStatusIndicator(context),
      ],
    );
  }

  Widget _buildCircularTimer(BuildContext context) {
    final countdown = state.countdownSeconds!;
    final color = _getTimerColor();
    final radius = 45.0;
    
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
        border: Border.all(
          color: color,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Circular progress indicator
          Positioned.fill(
            child: CircularProgressIndicator(
              value: countdown <= 60 ? (60 - countdown) / 60 : 0.0,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.3)),
              strokeWidth: 3,
            ),
          ),
          
          // Timer number in center
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$countdown',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                Text(
                  's',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Timer icon at top
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Icon(
                Icons.timer,
                color: color,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatusIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatusColor(), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(),
            color: _getStatusColor(),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            _getStatusText(context),
            style: TextStyle(
              color: _getStatusColor(),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (state.currentColor) {
      case TrafficLightColor.red:
        return Colors.red;
      case TrafficLightColor.yellow:
        return Colors.amber;
      case TrafficLightColor.green:
        return Colors.green;
    }
  }

  IconData _getStatusIcon() {
    switch (state.currentColor) {
      case TrafficLightColor.red:
        return Icons.stop;
      case TrafficLightColor.yellow:
        return Icons.warning;
      case TrafficLightColor.green:
        return Icons.play_arrow;
    }
  }

  String _getStatusText(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (state.currentColor) {
      case TrafficLightColor.red:
        return l10n?.stopSign ?? 'STOP';
      case TrafficLightColor.yellow:
        return 'CAUTION';
      case TrafficLightColor.green:
        return 'GO';
    }
  }

  Widget _buildTrafficControlArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!, width: 1),
      ),
      child: Column(
        children: [
          // Lane markers and traffic light row
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              
              if (availableWidth > 320) {
                // Full layout with side lane markers
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left lane markers
                    Flexible(
                      flex: 1,
                      child: Center(child: _buildLaneMarkers(true)),
                    ),
                    const SizedBox(width: 8),
                    
                    // Traffic light and timer (main content - takes priority)
                    Flexible(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildAdvancedTrafficLight(),
                          if (showCountdown && state.countdownSeconds != null) ...[
                            const SizedBox(height: 8),
                            _buildCountdownTimer(context),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    // Right lane markers
                    Flexible(
                      flex: 1,
                      child: Center(child: _buildLaneMarkers(false)),
                    ),
                  ],
                );
              } else {
                // Compact layout for smaller screens
                return Column(
                  children: [
                    // Traffic light and timer
                    Column(
                      children: [
                        _buildAdvancedTrafficLight(),
                        if (showCountdown && state.countdownSeconds != null) ...[
                          const SizedBox(height: 8),
                          _buildCountdownTimer(context),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Compact lane indicators with available space
                    SizedBox(
                      width: availableWidth - 32, // Leave some margin
                      child: _buildCompactLaneIndicators(),
                    ),
                  ],
                );
              }
            },
          ),
          
          // Road surface with lane dividers
          const SizedBox(height: 16),
          _buildRoadSurface(),
        ],
      ),
    );
  }

  Widget _buildLaneMarkers(bool isLeft) {
    return Column(
      children: [
        // Lane direction arrows
        Container(
          width: 50,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.yellow[700]!, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Direction arrows based on recognized signs
              ..._getLaneDirections().take(2).map((direction) => Icon(
                direction,
                color: Colors.yellow[600],
                size: 16,
              )),
              if (_getLaneDirections().isEmpty)
                Icon(
                  Icons.straight,
                  color: Colors.yellow[600],
                  size: 16,
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isLeft ? 'LEFT' : 'RIGHT',
          style: TextStyle(
            color: Colors.yellow[600],
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedLaneMarkings(bool isLeft) {
    return Container(
      height: 140,
      child: Column(
        children: [
          // Lane direction indicator
          Container(
            width: 60,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.yellow[600]!, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow[600]!.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lane boundary lines
                Container(
                  width: 40,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.yellow[600],
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Direction arrows from recognized signs
                if (_getLaneDirections().isNotEmpty) ...[
                  ..._getLaneDirections().take(2).map((direction) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Icon(
                      direction,
                      color: Colors.yellow[600],
                      size: 20,
                    ),
                  )),
                ] else ...[
                  Icon(
                    Icons.straight,
                    color: Colors.yellow[600],
                    size: 20,
                  ),
                ],
                
                const SizedBox(height: 8),
                // Bottom lane boundary
                Container(
                  width: 40,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.yellow[600],
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          // Lane label
          Text(
            isLeft ? 'LEFT' : 'RIGHT',
            style: TextStyle(
              color: Colors.yellow[600],
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLaneDisplay(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow[700]!, width: 2),
      ),
      child: Column(
        children: [
          Text(
            'LANE GUIDANCE',
            style: TextStyle(
              color: Colors.yellow[600],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Left lane
              Column(
                children: [
                  Icon(Icons.keyboard_arrow_left, color: Colors.yellow[600], size: 20),
                  Text('LEFT', style: TextStyle(color: Colors.yellow[600], fontSize: 8)),
                ],
              ),
              // Center directions
              Row(
                children: [
                  ..._getLaneDirections().take(3).map((direction) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(direction, color: Colors.yellow[600], size: 16),
                  )),
                  if (_getLaneDirections().isEmpty)
                    Icon(Icons.straight, color: Colors.yellow[600], size: 16),
                ],
              ),
              // Right lane
              Column(
                children: [
                  Icon(Icons.keyboard_arrow_right, color: Colors.yellow[600], size: 20),
                  Text('RIGHT', style: TextStyle(color: Colors.yellow[600], fontSize: 8)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryInformation(BuildContext context) {
    return Column(
      children: [
        // Enhanced road signs display
        _buildEnhancedRoadSigns(context),
        const SizedBox(height: 12),
        // Road surface representation
        _buildSimplifiedRoadSurface(),
      ],
    );
  }

  Widget _buildEnhancedRoadSigns(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.4), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n?.recognizedSigns ?? 'DETECTED ROAD SIGNS',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Show content based on whether signs are detected
          if (state.recognizedSigns.isEmpty) ...[
            // Show placeholder when no signs detected
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.visibility_off,
                      size: 40,
                      color: Colors.blue.withOpacity(0.3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n?.noSignsDetected ?? 'No signs detected',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue.withOpacity(0.5),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Priority signs (stop, yield) displayed prominently
            ...state.recognizedSigns.where((sign) => 
              sign == RoadSign.stop || sign == RoadSign.yield || sign == RoadSign.noEntry
            ).map((sign) => _buildPrioritySignDisplay(sign, context)),
            
            // Other signs in a wrapped layout
            if (state.recognizedSigns.where((sign) => 
              sign != RoadSign.stop && sign != RoadSign.yield && sign != RoadSign.noEntry
            ).isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: state.recognizedSigns.where((sign) => 
                  sign != RoadSign.stop && sign != RoadSign.yield && sign != RoadSign.noEntry
                ).map((sign) => _buildEnhancedRoadSignChip(sign, context)).toList(),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPrioritySignDisplay(RoadSign sign, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getSignColor(sign).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getSignColor(sign), width: 3),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getSignColor(sign),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getSignIcon(sign),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getLocalizedSignDisplayName(sign, context),
                  style: TextStyle(
                    color: _getSignColor(sign),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _getSignDescription(sign, context),
                  style: TextStyle(
                    color: _getSignColor(sign).withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedRoadSignChip(RoadSign sign, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getSignColor(sign).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getSignColor(sign), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getSignIcon(sign),
            color: _getSignColor(sign),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _getLocalizedSignDisplayName(sign, context),
            style: TextStyle(
              color: _getSignColor(sign),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getSignDescription(RoadSign sign, BuildContext context) {
    switch (sign) {
      case RoadSign.stop:
        return 'Complete stop required';
      case RoadSign.yield:
        return 'Give way to traffic';
      case RoadSign.noEntry:
        return 'Entry prohibited';
      default:
        return '';
    }
  }

  Widget _buildSimplifiedRoadSurface() {
    return Container(
      height: 30,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Left lane
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.yellow[600]!, width: 2),
                ),
              ),
            ),
          ),
          // Center divider
          Container(
            width: 20,
            child: Center(
              child: Container(
                width: 2,
                height: 20,
                color: Colors.white,
              ),
            ),
          ),
          // Right lane
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.yellow[600]!, width: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLaneIndicators() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        
        if (availableWidth < 200) {
          // Very compact layout for extremely narrow spaces
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.yellow[700]!, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.keyboard_arrow_left, color: Colors.yellow[600], size: 12),
                const SizedBox(width: 4),
                if (_getLaneDirections().isNotEmpty)
                  Icon(
                    _getLaneDirections().first,
                    color: Colors.yellow[600],
                    size: 12,
                  )
                else
                  Icon(
                    Icons.straight,
                    color: Colors.yellow[600],
                    size: 12,
                  ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_right, color: Colors.yellow[600], size: 12),
              ],
            ),
          );
        } else {
          // Regular compact layout
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.yellow[700]!, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Left indicator
                Icon(Icons.keyboard_arrow_left, color: Colors.yellow[600], size: 14),
                const SizedBox(width: 4),
                Text(
                  'L',
                  style: TextStyle(
                    color: Colors.yellow[600],
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                // Direction indicators (limited to prevent overflow)
                ..._getLaneDirections().take(2).map((direction) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Icon(
                    direction,
                    color: Colors.yellow[600],
                    size: 12,
                  ),
                )),
                if (_getLaneDirections().isEmpty)
                  Icon(
                    Icons.straight,
                    color: Colors.yellow[600],
                    size: 12,
                  ),
                const SizedBox(width: 6),
                // Right indicator
                Text(
                  'R',
                  style: TextStyle(
                    color: Colors.yellow[600],
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_right, color: Colors.yellow[600], size: 14),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildRoadSurface() {
    return Container(
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Road texture
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey[800]!,
                  Colors.grey[900]!,
                ],
              ),
            ),
          ),
          // Lane divider lines
          Positioned.fill(
            child: Row(
              children: [
                Expanded(child: Container()),
                Container(
                  width: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.yellow[600],
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                Expanded(child: Container()),
                Container(
                  width: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.yellow[600],
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
          // Dashed center line
          Positioned.fill(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final dashCount = (constraints.maxWidth / 20).floor();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(dashCount, (index) => Container(
                      width: 8,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    )),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<IconData> _getLaneDirections() {
    List<IconData> directions = [];
    for (var sign in state.recognizedSigns) {
      switch (sign) {
        case RoadSign.turnLeft:
          directions.add(Icons.turn_left);
          break;
        case RoadSign.turnRight:
          directions.add(Icons.turn_right);
          break;
        case RoadSign.goStraight:
          directions.add(Icons.straight);
          break;
        default:
          break;
      }
    }
    return directions.take(3).toList(); // Limit to 3 directions per lane
  }

  Widget _buildBasicTrafficLight() {
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

  Widget _buildAdvancedTrafficLight() {
    return Container(
      width: 90,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(45),
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
          _buildAdvancedLight(TrafficLightColor.red, state.currentColor == TrafficLightColor.red),
          _buildAdvancedLight(TrafficLightColor.yellow, state.currentColor == TrafficLightColor.yellow),
          _buildAdvancedLight(TrafficLightColor.green, state.currentColor == TrafficLightColor.green),
        ],
      ),
    );
  }

  Widget _buildAdvancedLight(TrafficLightColor color, bool isActive) {
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
      width: 50,
      height: 50,
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
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: lightColor.withOpacity(0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(-5, -5),
              ),
            ],
          ),
        ),
      ) : null,
    );
  }

  Widget _buildCountdownTimer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getTimerColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getTimerBorderColor(), width: 2),
        boxShadow: [
          BoxShadow(
            color: _getTimerColor().withOpacity(0.3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '${state.countdownSeconds}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            's',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
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
        return Colors.red.withOpacity(0.8);
      case TrafficLightColor.yellow:
        return Colors.amber.withOpacity(0.8);
      case TrafficLightColor.green:
        return Colors.green.withOpacity(0.8);
    }
  }

  Color _getTimerBorderColor() {
    switch (state.currentColor) {
      case TrafficLightColor.red:
        return Colors.red;
      case TrafficLightColor.yellow:
        return Colors.amber;
      case TrafficLightColor.green:
        return Colors.green;
    }
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

  Widget _buildRoadSignsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n?.recognizedSigns ?? 'Recognized Road Signs',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: state.recognizedSigns.map((sign) => _buildRoadSignChip(sign, context)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadSignChip(RoadSign sign, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getSignColor(sign).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getSignColor(sign), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getSignIcon(sign),
            color: _getSignColor(sign),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _getLocalizedSignDisplayName(sign, context),
            style: TextStyle(
              color: _getSignColor(sign),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSignColor(RoadSign sign) {
    switch (sign) {
      case RoadSign.stop:
        return Colors.red;
      case RoadSign.yield:
        return Colors.orange;
      case RoadSign.speedLimit:
        return Colors.blue;
      case RoadSign.noEntry:
        return Colors.red;
      case RoadSign.construction:
        return Colors.amber;
      case RoadSign.pedestrianCrossing:
        return Colors.green;
      case RoadSign.turnLeft:
      case RoadSign.turnRight:
      case RoadSign.goStraight:
        return Colors.blue;
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

  String _getLocalizedSignDisplayName(RoadSign sign, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (sign) {
      case RoadSign.stop:
        return l10n?.stopSign ?? 'STOP';
      case RoadSign.yield:
        return l10n?.yieldSign ?? 'YIELD';
      case RoadSign.speedLimit:
        return l10n?.speedLimitSign ?? 'SPEED LIMIT';
      case RoadSign.noEntry:
        return l10n?.noEntrySign ?? 'NO ENTRY';
      case RoadSign.construction:
        return l10n?.constructionSign ?? 'CONSTRUCTION';
      case RoadSign.pedestrianCrossing:
        return l10n?.pedestrianSign ?? 'PEDESTRIAN';
      case RoadSign.turnLeft:
        return l10n?.turnLeftSign ?? 'TURN LEFT';
      case RoadSign.turnRight:
        return l10n?.turnRightSign ?? 'TURN RIGHT';
      case RoadSign.goStraight:
        return l10n?.goStraightSign ?? 'GO STRAIGHT';
    }
  }
}