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
  late Offset _position;
  bool _isDragging = false;
  bool _hasMoved = false;
  Offset _pointerOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    // Convert normalized position to actual pixel position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final screenSize = MediaQuery.of(context).size;
        setState(() {
          _position = Offset(
            widget.initialX * screenSize.width,
            widget.initialY * screenSize.height,
          );
        });
      }
    });
    _position = Offset(widget.initialX, widget.initialY);
  }

  @override
  void didUpdateWidget(DraggableOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialX != widget.initialX || oldWidget.initialY != widget.initialY) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final screenSize = MediaQuery.of(context).size;
          setState(() {
            _position = Offset(
              widget.initialX * screenSize.width,
              widget.initialY * screenSize.height,
            );
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    // Calculate actual widget size after scaling
    final widgetWidth = 150 * widget.size;
    final widgetHeight = 250 * widget.size;
    
    // Ensure position is in pixels
    final pixelPosition = _position.dx > 1 ? _position : Offset(
      _position.dx * screenSize.width,
      _position.dy * screenSize.height,
    );
    
    // Calculate position - center the widget at the stored position
    final left = pixelPosition.dx - (widgetWidth / 2);
    final top = pixelPosition.dy - (widgetHeight / 2);
    
    return Positioned(
      left: left,
      top: top,
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
            // Calculate pointer offset from widget center
            _pointerOffset = details.localPosition - Offset(widgetWidth / 2, widgetHeight / 2);
          });
        },
        onPanUpdate: (details) {
          setState(() {
            _hasMoved = true;
            // Update position to where the pointer is, accounting for the offset
            final newPosition = details.globalPosition - _pointerOffset;
            
            // Clamp to screen bounds
            _position = Offset(
              newPosition.dx.clamp(widgetWidth / 2, screenSize.width - widgetWidth / 2),
              newPosition.dy.clamp(widgetHeight / 2, screenSize.height - widgetHeight / 2),
            );
          });
        },
        onPanEnd: (details) {
          setState(() {
            _isDragging = false;
          });
          // Convert back to normalized coordinates for storage
          final normalizedX = _position.dx / screenSize.width;
          final normalizedY = _position.dy / screenSize.height;
          widget.onPositionChanged?.call(normalizedX, normalizedY);
          
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
          child: Transform.scale(
            scale: widget.size,
            alignment: Alignment.center,
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