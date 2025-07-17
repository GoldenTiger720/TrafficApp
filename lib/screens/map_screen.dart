import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../l10n/app_localizations.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> 
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLocationEnabled = false;
  bool _isPermissionGranted = false;
  Set<Marker> _markers = {};
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
        _updateCurrentLocationMarker();
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _getCurrentLocation();
    });
  }

  void _updateCurrentLocationMarker() {
    if (_currentPosition != null) {
      setState(() {
        _markers.removeWhere((marker) => marker.markerId.value == 'current_location');
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            infoWindow: InfoWindow(
              title: AppLocalizations.of(context)?.currentLocation ?? 'Current Location',
              snippet: 'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, '
                      'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      });
    }
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
    
    return Scaffold(
      body: Stack(
        children: [
          // Map
          if (_isLocationEnabled && _isPermissionGranted && _currentPosition != null)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                zoom: 15.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              compassEnabled: true,
              trafficEnabled: false, // Disable traffic layer to reduce rendering load
              mapType: MapType.normal,
              buildingsEnabled: false, // Disable 3D buildings
              liteModeEnabled: false, // Full map mode
              mapToolbarEnabled: false, // Disable map toolbar
              onTap: (LatLng position) {
                _addTrafficLightMarker(position);
              },
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    !_isLocationEnabled 
                        ? (l10n?.enableLocationServices ?? 'Please enable location services')
                        : !_isPermissionGranted 
                            ? (l10n?.locationPermissionRequired ?? 'Location permission required')
                            : (l10n?.loadingLocation ?? 'Loading location...'),
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          
          // Blinking Current Location Indicator
          if (_currentPosition != null && _isLocationEnabled && _isPermissionGranted)
            Positioned(
              top: 80,
              right: 20,
              child: AnimatedBuilder(
                animation: _blinkAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(_blinkAnimation.value),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.my_location, color: Colors.white),
                      onPressed: () {
                        if (_mapController != null && _currentPosition != null) {
                          _mapController!.animateCamera(
                            CameraUpdate.newLatLng(
                              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          
          // Traffic Light Controls
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
                      l10n?.trafficControl ?? 'Traffic Control',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n?.tapToAddTrafficLight ?? 'Tap on the map to add traffic light markers',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _clearMarkers,
                          icon: const Icon(Icons.clear),
                          label: Text(l10n?.clear ?? 'Clear'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addTrafficLightMarker(LatLng position) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('traffic_light_${DateTime.now().millisecondsSinceEpoch}'),
          position: position,
          infoWindow: InfoWindow(
            title: AppLocalizations.of(context)?.trafficLight ?? 'Traffic Light',
            snippet: 'Lat: ${position.latitude.toStringAsFixed(6)}, '
                    'Lng: ${position.longitude.toStringAsFixed(6)}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });
  }

  void _clearMarkers() {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value != 'current_location');
    });
  }
}