import 'package:flutter/material.dart';
import '../models/traffic_light_state.dart';
import 'traffic_light_overlay_widget.dart';

class DraggableOverlay extends StatefulWidget {
  final TrafficLightState trafficLightState;
  final double transparency;
  final double size;
  final double initialX;
  final double initialY;
  final bool isMinimalistic;
  final Function(double x, double y)? onPositionChanged;
  final VoidCallback? onDoubleTap;

  const DraggableOverlay({
    super.key,
    required this.trafficLightState,
    required this.transparency,
    required this.size,
    required this.initialX,
    required this.initialY,
    required this.isMinimalistic,
    this.onPositionChanged,
    this.onDoubleTap,
  });

  @override
  State<DraggableOverlay> createState() => _DraggableOverlayState();
}

class _DraggableOverlayState extends State<DraggableOverlay> {
  late double _x;
  late double _y;
  bool _isDragging = false;
  bool _hasMoved = false;

  @override
  void initState() {
    super.initState();
    _x = widget.initialX;
    _y = widget.initialY;
  }

  @override
  void didUpdateWidget(DraggableOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialX != widget.initialX || oldWidget.initialY != widget.initialY) {
      setState(() {
        _x = widget.initialX;
        _y = widget.initialY;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Positioned(
      left: _x * screenSize.width - (100 * widget.size),
      top: _y * screenSize.height - (100 * widget.size),
      child: GestureDetector(
        onDoubleTap: () {
          if (!_hasMoved) {
            widget.onDoubleTap?.call();
          }
        },
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
            _hasMoved = false;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            _hasMoved = true;
            _x = (details.globalPosition.dx + (100 * widget.size)) / screenSize.width;
            _y = (details.globalPosition.dy + (100 * widget.size)) / screenSize.height;
            
            // Keep overlay within screen bounds
            _x = _x.clamp(0.1, 0.9);
            _y = _y.clamp(0.1, 0.9);
          });
        },
        onPanEnd: (details) {
          setState(() {
            _isDragging = false;
          });
          widget.onPositionChanged?.call(_x, _y);
          // Reset moved flag after a delay to allow double-tap detection
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {
                _hasMoved = false;
              });
            }
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: _isDragging ? 0 : 200),
          transform: Matrix4.identity()..scale(widget.size),
          child: AnimatedOpacity(
            opacity: widget.transparency,
            duration: const Duration(milliseconds: 200),
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 150,
                  maxHeight: 250,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _isDragging ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ] : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    TrafficLightOverlayWidget(
                      state: widget.trafficLightState,
                      showCountdown: true,
                    ),
                  if (_isDragging)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.drag_indicator,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OverlayManager extends StatelessWidget {
  final Widget child;
  final bool overlayEnabled;
  final TrafficLightState trafficLightState;
  final double transparency;
  final double size;
  final double positionX;
  final double positionY;
  final bool isMinimalistic;
  final Function(double x, double y)? onPositionChanged;
  final VoidCallback? onOverlayDoubleTap;

  const OverlayManager({
    super.key,
    required this.child,
    required this.overlayEnabled,
    required this.trafficLightState,
    required this.transparency,
    required this.size,
    required this.positionX,
    required this.positionY,
    required this.isMinimalistic,
    this.onPositionChanged,
    this.onOverlayDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (overlayEnabled)
          DraggableOverlay(
            trafficLightState: trafficLightState,
            transparency: transparency,
            size: size,
            initialX: positionX,
            initialY: positionY,
            isMinimalistic: isMinimalistic,
            onPositionChanged: onPositionChanged,
            onDoubleTap: onOverlayDoubleTap,
          ),
      ],
    );
  }
}