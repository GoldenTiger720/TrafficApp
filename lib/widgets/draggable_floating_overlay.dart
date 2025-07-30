import 'package:flutter/material.dart';
import '../models/traffic_light_state.dart';
import 'floating_overlay_widget.dart';

class DraggableFloatingOverlay extends StatefulWidget {
  final TrafficLightState state;
  final double size;
  final double transparency;
  final double initialX;
  final double initialY;
  final Function(double x, double y)? onPositionChanged;
  final VoidCallback? onDoubleTap;

  const DraggableFloatingOverlay({
    super.key,
    required this.state,
    this.size = 1.0,
    this.transparency = 0.9,
    this.initialX = 0.5,
    this.initialY = 0.5,
    this.onPositionChanged,
    this.onDoubleTap,
  });

  @override
  State<DraggableFloatingOverlay> createState() => _DraggableFloatingOverlayState();
}

class _DraggableFloatingOverlayState extends State<DraggableFloatingOverlay> {
  late Offset _position;
  bool _isDragging = false;
  bool _hasMoved = false;

  @override
  void initState() {
    super.initState();
    _position = Offset(widget.initialX, widget.initialY);
  }

  @override
  void didUpdateWidget(DraggableFloatingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialX != widget.initialX || oldWidget.initialY != widget.initialY) {
      setState(() {
        _position = Offset(widget.initialX, widget.initialY);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    // Calculate widget dimensions - responsive sizing
    final baseWidth = 130.0; // Base width for traffic light + timer + spacing
    final baseHeight = 156.0; // Base height for traffic light container
    
    final scaledWidth = baseWidth * widget.size;
    final scaledHeight = baseHeight * widget.size;
    
    // Convert normalized position to screen coordinates
    final left = (_position.dx * screenSize.width - scaledWidth / 2)
        .clamp(0.0, screenSize.width - scaledWidth);
    final top = (_position.dy * screenSize.height - scaledHeight / 2)
        .clamp(0.0, screenSize.height - scaledHeight);

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
          });
        },
        onPanUpdate: (details) {
          setState(() {
            _hasMoved = true;
            
            // Calculate new normalized position
            final newX = (details.globalPosition.dx / screenSize.width)
                .clamp(0.0, 1.0);
            final newY = (details.globalPosition.dy / screenSize.height)
                .clamp(0.0, 1.0);
            
            _position = Offset(newX, newY);
          });
        },
        onPanEnd: (details) {
          setState(() {
            _isDragging = false;
          });
          
          // Notify parent of position change
          widget.onPositionChanged?.call(_position.dx, _position.dy);
          
          // Reset moved flag after a delay
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              setState(() {
                _hasMoved = false;
              });
            }
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: _isDragging ? 0 : 200),
          child: Stack(
            children: [
              FloatingOverlayWidget(
                state: widget.state,
                size: widget.size,
                transparency: widget.transparency,
              ),
              if (_isDragging)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: EdgeInsets.all(4 * widget.size),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4 * widget.size),
                    ),
                    child: Icon(
                      Icons.drag_indicator,
                      color: Colors.white,
                      size: 16 * widget.size,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}