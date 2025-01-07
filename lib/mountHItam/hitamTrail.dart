import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';


import '../Resources/elevation_profile.dart';

class HitamTrail extends StatefulWidget {
  @override
  _HitamTrailScreen createState() => new _HitamTrailScreen();
}

class _HitamTrailScreen extends State<HitamTrail> {
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
  bool _isDistanceCalculationActive = true; // Flag to control distance calculation
  Timer? _timer;
  int _elapsedSeconds = 0; // Elapsed time
  double _totalDistance = 0.0; // Total distance
  double _totalElevationGain = 0.0; // Elevation gain variable
  LatLng? _lastLocation;

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
      await rootBundle.loadString('assets/gpxFile/hitam.xml');
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

  /// Calculate distance and elevation gain
  void _calculateDistance(LocationData locationData) {
    if (_lastLocation != null) {
      final LatLng currentLocation =
      LatLng(locationData.latitude!, locationData.longitude!);

      // Check if distance threshold (e.g., 10 meters) is reached
      final double distance =
      const Distance().as(LengthUnit.Meter, _lastLocation!, currentLocation);

      if (distance > 10) { // Only update if the user has moved more than 10 meters
        setState(() {
          _totalDistance += distance / 1000; // in km
        });

        // Re-center map if the user moves significantly
        _lastLocation = currentLocation;
        _mapController.move(currentLocation, 19.0); // Adjust zoom level as needed
      }
    } else {
      // Initialize the first location
      _lastLocation = LatLng(locationData.latitude!, locationData.longitude!);
      _mapController.move(_lastLocation!, 19.0); // Initial center
    }
  }

  void _startTracking() {
    setState(() {
      _isTracking = true;
      _isPaused = false;
      _isDistanceCalculationActive = true; // Enable distance calculation
      _isElevationProfileVisible = false;
      _isTrackingStarted = true;
      _isRecenterVisible = true;
    });

    // Start timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });

    // Start location tracking
    _location.onLocationChanged.listen((LocationData locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        setState(() {
          _currentLocation =
              LatLng(locationData.latitude!, locationData.longitude!);
          _isLoading = false;
        });

        if (_isDistanceCalculationActive) {
          _calculateDistance(locationData);
        }
      }
    });
  }

  void _pauseTracking() {
    setState(() {
      _isPaused = true;
      _isDistanceCalculationActive = false; // Disable distance calculation
      _isTracking = false;
    });
    _timer?.cancel();
  }

  void _resumeTracking() {
    setState(() {
      _isPaused = false;
      _isDistanceCalculationActive = true; // Enable distance calculation
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
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Mount Hitam",
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
        backgroundColor: Colors.white,
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
                  // Time, Distance
                  Container(
                    margin: const EdgeInsets.all(0),  // Remove any outer margin
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),  // Curve the top-left corner
                        topRight: Radius.circular(20.0), // Curve the top-right corner
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Time and Distance Box
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Time Section
                            Padding(
                              padding: const EdgeInsets.only(right: 50.0),  // Increase padding here
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Time",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    _formatTime(_elapsedSeconds),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Vertical Line Divider
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              width: 1,
                              height: 40,
                              color: Colors.grey.withOpacity(0.5),
                            ),

                            // Distance Section
                            Padding(
                              padding: const EdgeInsets.only(left: 50.0),  // Increase padding here
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Distance",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    "${_totalDistance.toStringAsFixed(2)} km",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Control Buttons
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1), // Light shadow color
                          blurRadius: 10, // Blur radius
                          offset: Offset(0, -4), // Negative Y offset to push the shadow upwards
                        ),
                      ],
                    ),
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
                          child: const Text("RESUME"),
                        ),
                        ElevatedButton(
                          onPressed: _stopTracking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("FINISH"),
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
                        child: Text(_isTracking ? "PAUSE" : "START"),
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