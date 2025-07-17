import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../l10n/app_localizations.dart';

// Alternative Map Screen using a placeholder
// To use OpenStreetMap, add flutter_map package to pubspec.yaml
class MapScreenOSM extends StatefulWidget {
  const MapScreenOSM({super.key});

  @override
  State<MapScreenOSM> createState() => _MapScreenOSMState();
}

class _MapScreenOSMState extends State<MapScreenOSM> 
    with TickerProviderStateMixin {
  Position? _currentPosition;
  bool _isLocationEnabled = false;
  bool _isPermissionGranted = false;
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkLocationPermission();
  }

  void _initializeAnimations() {
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _blinkAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _blinkController,
      curve: Curves.easeInOut,
    ));
    
    _blinkController.repeat(reverse: true);
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLocationEnabled = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isPermissionGranted = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isPermissionGranted = false;
      });
      return;
    }

    setState(() {
      _isLocationEnabled = true;
      _isPermissionGranted = true;
    });

    _getCurrentLocation();
    _startLocationUpdates();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _locationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // Placeholder Map View
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade200,
                  Colors.blue.shade50,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Map View',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_currentPosition != null) ...[
                    Card(
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedBuilder(
                                  animation: _blinkAnimation,
                                  builder: (context, child) {
                                    return Icon(
                                      Icons.my_location,
                                      color: Colors.blue.withOpacity(_blinkAnimation.value),
                                      size: 24,
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n?.currentLocation ?? 'Current Location',
                                  style: theme.textTheme.titleMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    if (!_isLocationEnabled) 
                      Text(
                        l10n?.enableLocationServices ?? 'Please enable location services',
                        style: theme.textTheme.bodyLarge,
                      )
                    else if (!_isPermissionGranted)
                      Text(
                        l10n?.locationPermissionRequired ?? 'Location permission required',
                        style: theme.textTheme.bodyLarge,
                      )
                    else
                      const CircularProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
          
          // Map Info Card
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Map Integration',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'To enable Google Maps:\n'
                      '1. Get an API key from Google Cloud Console\n'
                      '2. Add it to AndroidManifest.xml\n'
                      '3. Enable Maps SDK for Android',
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n?.refresh ?? 'Refresh'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}