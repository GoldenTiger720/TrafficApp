import 'package:flutter/material.dart';
import '../models/traffic_light_state.dart';
import 'traffic_light_overlay_widget.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'dart:async';
import '../services/overlay_service.dart';

class DraggableOverlay extends StatefulWidget {
  final TrafficLightState trafficLightState;
  final double transparency;
  final double size;
  final double initialX; // Normalized coordinates (0-1)
  final double initialY; // Normalized coordinates (0-1)
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
  late Offset _position; // Always store in pixel coordinates
  bool _isDragging = false;
  bool _hasMoved = false;
  Offset _dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    // Initialize with a default position, will be updated in postFrameCallback
    _position = const Offset(0, 0);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updatePositionFromNormalized();
      _ensureAlwaysOnTop();
    });
  }
  
  void _ensureAlwaysOnTop() async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      await windowManager.setAlwaysOnTop(true);
      await windowManager.setSkipTaskbar(false);
    }
  }

  @override
  void didUpdateWidget(DraggableOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialX != widget.initialX || oldWidget.initialY != widget.initialY) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updatePositionFromNormalized();
      });
    }
    _ensureAlwaysOnTop();
  }

  void _updatePositionFromNormalized() {
    if (!mounted) return;
    
    final screenSize = MediaQuery.of(context).size;
    setState(() {
      _position = Offset(
        widget.initialX * screenSize.width,
        widget.initialY * screenSize.height,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    // Calculate actual widget dimensions after scaling
    final widgetWidth = 200 * widget.size; // Increased width to accommodate timer
    final widgetHeight = 250 * widget.size;
    
    // Calculate top-left position for Positioned widget
    // Center the widget at the stored position
    final left = (_position.dx - (widgetWidth / 2))
        .clamp(0.0, screenSize.width - widgetWidth)
        .toDouble();
    final top = (_position.dy - (widgetHeight / 2))
        .clamp(0.0, screenSize.height - widgetHeight)
        .toDouble();
    
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
            // Store the offset from the widget center to the touch point
            _dragOffset = details.localPosition - Offset(widgetWidth / 2, 0);
          });
        },
        onPanUpdate: (details) {
          setState(() {
            _hasMoved = true;
            
            // Calculate new center position
            final newCenterX = details.globalPosition.dx - _dragOffset.dx;
            final newCenterY = details.globalPosition.dy - _dragOffset.dy;
            
            // Clamp to screen bounds (keeping widget fully visible)
            _position = Offset(
              newCenterX.clamp(widgetWidth / 2, screenSize.width - widgetWidth / 2),
              newCenterY.clamp(widgetHeight / 2, screenSize.height - widgetHeight / 2),
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
          child: Transform.scale(
            scale: widget.size,
            alignment: Alignment.center,
            child: AnimatedOpacity(
              opacity: widget.transparency,
              duration: const Duration(milliseconds: 200),
              child: RepaintBoundary( // Optimize repaints
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 200,
                      maxHeight: 250,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _isDragging ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // Reduced opacity
                          blurRadius: 6, // Reduced blur
                          spreadRadius: 1, // Reduced spread
                        ),
                      ] : [], // Remove shadow when not dragging for better performance
                    ),
                    child: Stack(
                      children: [
                        _buildOverlayContent(),
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
      ),
    );
  }

  Widget _buildOverlayContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 3,
          child: TrafficLightOverlayWidget(
            state: widget.trafficLightState,
            showCountdown: false, // Don't show countdown inside the widget
          ),
        ),
        const SizedBox(width: 6), // Reduced spacing
        Flexible(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0), // Align timer with traffic light top
            child: _buildOverlayExternalTimer(),
          ),
        ),
      ],
    );
  }

  Widget _buildOverlayExternalTimer() {
    final countdown = widget.trafficLightState.countdownSeconds ?? 0; // Default to 0 if null
    final color = _getTimerColor();
    
    return Container(
      width: 40, // Reduced size for better fit
      height: 40, // Reduced size for better fit
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle, // Always circular
        border: Border.all(color: color, width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer,
            color: color,
            size: 8,
          ),
          Text(
            '$countdown',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTimerColor() {
    switch (widget.trafficLightState.currentColor) {
      case TrafficLightColor.red:
        return Colors.red;
      case TrafficLightColor.yellow:
        return Colors.amber;
      case TrafficLightColor.green:
        return Colors.green;
    }
  }
}

// OverlayManager with always-on-top support
class OverlayManager extends StatefulWidget {
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
  State<OverlayManager> createState() => _OverlayManagerState();
}

class _OverlayManagerState extends State<OverlayManager> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.overlayEnabled) {
      _ensureAlwaysOnTop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _overlayUpdateTimer?.cancel();
    if (Platform.isAndroid && widget.overlayEnabled) {
      // Stop Android overlay service when disposing
      OverlayService.stopOverlayService();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(OverlayManager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.overlayEnabled != oldWidget.overlayEnabled) {
      if (widget.overlayEnabled) {
        _ensureAlwaysOnTop();
      } else if (Platform.isAndroid) {
        // Stop Android overlay service
        OverlayService.stopOverlayService();
      }
    }
    
    // Update overlay settings and state on Android
    if (Platform.isAndroid && widget.overlayEnabled && OverlayService.isServiceRunning) {
      // Update settings if they changed
      if (oldWidget.transparency != widget.transparency || 
          oldWidget.size != widget.size || 
          oldWidget.positionX != widget.positionX || 
          oldWidget.positionY != widget.positionY) {
        OverlayService.updateOverlaySettings(
          transparency: widget.transparency,
          size: widget.size,
          positionX: widget.positionX,
          positionY: widget.positionY,
        );
      }
      // Update state
      OverlayService.updateOverlayState(widget.trafficLightState);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.overlayEnabled) return;
    
    switch (state) {
      case AppLifecycleState.resumed:
        if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
          _ensureAlwaysOnTop();
        } else if (Platform.isAndroid) {
          // Throttle Android overlay updates - only update every 2 seconds max
          _throttledUpdateOverlay();
        }
        break;
      case AppLifecycleState.paused:
        // Reduce background activity when app is paused
        if (Platform.isAndroid) {
          // Don't continuously update overlay when app is in background
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // Minimal activity when app is inactive
        break;
    }
  }
  
  Timer? _overlayUpdateTimer;
  
  void _throttledUpdateOverlay() {
    _overlayUpdateTimer?.cancel();
    _overlayUpdateTimer = Timer(const Duration(seconds: 2), () {
      if (Platform.isAndroid && OverlayService.isServiceRunning) {
        OverlayService.updateOverlayState(widget.trafficLightState);
      }
    });
  }

  void _ensureAlwaysOnTop() async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      await windowManager.setAlwaysOnTop(true);
      await windowManager.setSkipTaskbar(false);
    } else if (Platform.isAndroid && widget.overlayEnabled) {
      // Start Android overlay service with settings
      await OverlayService.startOverlayService(
        transparency: widget.transparency,
        size: widget.size,
        positionX: widget.positionX,
        positionY: widget.positionY,
      );
      await OverlayService.updateOverlayState(widget.trafficLightState);
    }
  }

  @override
  Widget build(BuildContext context) {
    // No longer showing Flutter overlay - using native Android overlay service instead
    return widget.child;
  }
}