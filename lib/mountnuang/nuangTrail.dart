import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';


import '../Resources/elevation_profile.dart';

class NuangTrail extends StatefulWidget {
  @override
  _NuangTrailScreen createState() => new _NuangTrailScreen();
}

class _NuangTrailScreen extends State<NuangTrail> {
  final Location _locationService = Location();
  final Location _location = Location();

  bool _isLoading = true;
  bool _isElevationProfileVisible = true;
  bool _isTrackingStarted = false;
  bool _isRecenterVisible = true;
  LatLng? _currentLocation;
  LatLng? _destination;
  List<LatLng> _route = [];
  List<LatLng> _gpxRoute = [];
  List<double> _elevations = [];
  bool _isTracking = false; // Tracking state
  bool _isPaused = false; // Pause state
  Timer? _timer;
  int _elapsedSeconds = 0; // Elapsed time
  double _totalDistance = 0.0; // Total distance
  LatLng? _lastLocation;
  StreamSubscription<LocationData>? _locationSubscription;

  // Controller for the map
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _loadGPXRoute();
  }

  /// Initialize and fetch user location
  Future<void> _initializeLocation() async {
    if (!await _checkAndRequestPermissions()) return;

    _locationService.onLocationChanged.listen((LocationData locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        setState(() {
          _currentLocation =
              LatLng(locationData.latitude!, locationData.longitude!);
          _isLoading = false;
        });
      }
    });
  }

  /// Check and request permissions
  Future<bool> _checkAndRequestPermissions() async {
    bool serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) return false;
    }
    PermissionStatus permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted == await _locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return false;
    }
    return true;
  }

  /// Load GPX file and parse coordinates
  Future<void> _loadGPXRoute() async {
    try {
      final String gpxString =
      await rootBundle.loadString('assets/gpxFile/nuang.xml');
      final document = XmlDocument.parse(gpxString);

      final List<LatLng> trailCoordinates = [];
      final List<double> elevations = [];

      final waypoints = document.findAllElements('trkpt');
      for (var waypoint in waypoints) {
        final lat = double.parse(waypoint.getAttribute('lat')!);
        final lon = double.parse(waypoint.getAttribute('lon')!);
        final ele =
            double.tryParse(waypoint.findElements('ele').first.text) ?? 0.0;

        trailCoordinates.add(LatLng(lat, lon));
        elevations.add(ele);
      }

      // Calculate the center of the trail
      LatLng center = _calculateRouteCenter(trailCoordinates);

      setState(() {
        _gpxRoute = trailCoordinates;
        _elevations = elevations;
        _destination = center; // Set the trail center as the initial destination
      });
    } catch (e) {
      print('Error loading GPX file: $e');
    }
  }


  void _startTracking() {
    setState(() {
      _isTracking = true;
      _isPaused = false;
      _isElevationProfileVisible = false;
      _isTrackingStarted = true;
    });

    // Start timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });

    // Start location tracking only if not paused
    _location.onLocationChanged.listen((LocationData locationData) {
      if (_isPaused) return; // Skip location updates if paused

      if (locationData.latitude != null && locationData.longitude != null) {
        LatLng currentLocation = LatLng(locationData.latitude!, locationData.longitude!);

        if (_lastLocation != null) {
          final double distance = const Distance().as(LengthUnit.Meter, _lastLocation!, currentLocation);

          setState(() {
            _totalDistance += distance / 1000; // in km
          });

          // Only re-center the map if the user has moved significantly (e.g., 10 meters or more)
          if (distance > 10) {
            _lastLocation = currentLocation;
            _mapController.move(currentLocation, 19.0);  // Adjust zoom level as needed
          }
        } else {
          _lastLocation = currentLocation;
          _mapController.move(currentLocation, 19.0);  // Initial center
        }
      }
    });
  }


  void _pauseTracking() {
    setState(() {
      _isPaused = true;
      _isTracking = false;
    });
    _timer?.cancel();

    // Cancel the location tracking subscription
    _locationSubscription?.cancel();
  }

  void _resumeTracking() {
    setState(() {
      _isPaused = false;
      _isTracking = true;
    });
    _startTracking(); // Restart tracking
  }

  void _stopTracking() {
    setState(() {
      _isTracking = false;
      _isPaused = false;
      _elapsedSeconds = 0;
      _totalDistance = 0.0;
      _lastLocation = null;
      _isElevationProfileVisible = true;
      _isRecenterVisible = false;
    });
    _timer?.cancel();

    // Reset map to the initial view (before tracking started)
    if (_gpxRoute.isNotEmpty) {
      _mapController.move(_calculateRouteCenter(_gpxRoute), 13.0); // Center map on the route
    }
  }

  String _formatTime(int seconds) {
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    final int secs = seconds % 60;
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  LatLng _calculateRouteCenter(List<LatLng> route) {
    double latSum = 0;
    double lonSum = 0;

    for (var point in route) {
      latSum += point.latitude;
      lonSum += point.longitude;
    }

    double centerLat = latSum / route.length;
    double centerLon = lonSum / route.length;

    centerLat -= 0.018; // Adjust center upwards slightly
    return LatLng(centerLat, centerLon);
  }

  /// Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Mount Nuang",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          _gpxRoute.isEmpty
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _calculateRouteCenter(_gpxRoute), // Default to trail center
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              CurrentLocationLayer(
                //alignPositionOnUpdate: AlignOnUpdate.always,
                //alignDirectionOnUpdate: AlignOnUpdate.never,
                style: const LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    child: Icon(
                      Icons.navigation,
                      color: Colors.white,
                    ),
                  ),
                  markerSize: Size(40, 40),
                  markerDirection: MarkerDirection.heading,
                ),
              ),
              if (_currentLocation != null && _gpxRoute.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    // Outer dark polyline (border)
                    Polyline(
                      points: _gpxRoute,
                      strokeWidth: 7.0, // Slightly thicker stroke width
                      color: Colors.blue.shade900, // Outer dark color
                    ),
                    // Inner light polyline (main line)
                    Polyline(
                      points: _gpxRoute,
                      strokeWidth: 4.0, // Slightly thinner stroke width
                      color: Colors.blue.shade300, // Inner light color
                    ),
                  ],
                ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _isElevationProfileVisible
                        ? MediaQuery.of(context).size.height * 0.25
                        : 0,
                    curve: Curves.easeInOut,
                    child: _isElevationProfileVisible
                        ? _elevations.isNotEmpty
                        ? ElevationProfile(elevations: _elevations)
                        : const Center(child: CircularProgressIndicator())
                        : const SizedBox(),
                  ),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    width: double.infinity,
                    child: Column(
                      children: [
                        Text(
                          "Time: ${_formatTime(_elapsedSeconds)}",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Distance: ${_totalDistance.toStringAsFixed(2)} km",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  // Start, Pause, Resume, Stop Buttons
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    width: double.infinity,
                    child: _isPaused
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _resumeTracking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Resume"),
                        ),
                        ElevatedButton(
                          onPressed: _stopTracking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Stop"),
                        ),
                      ],
                    )
                        : Center(
                      child: ElevatedButton(
                        onPressed: _isTracking ? _pauseTracking : _startTracking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isTracking ? Colors.red : Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(_isTracking ? "Pause" : "Start"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Re-center button appears only after tracking starts
          if (_isTrackingStarted && _isRecenterVisible)
            Positioned(
              bottom: 170, // Set to 16 for some padding from the top of the screen
              right: 19,
              child: FloatingActionButton(
                onPressed: _recenterToUserLocation,
                backgroundColor: Colors.blue,
                child: const Icon(Icons.my_location, color: Colors.white),
                shape: CircleBorder(),
              ),
            ),
        ],
      ),
    );
  }

  /// Function to recenter map to user's current location
  void _recenterToUserLocation() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 19.0); // Adjust the zoom level as needed
    } else {
      _showError("Current location not available");
    }
  }
}