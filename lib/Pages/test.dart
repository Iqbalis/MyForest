import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';
import 'package:xml/xml.dart';
import 'package:location/location.dart';
import 'dart:async';
import '../Resources/elevation_profile.dart';

class NuangTrail extends StatefulWidget {
  const NuangTrail({Key? key}) : super(key: key);

  @override
  _NuangTrailScreen createState() => _NuangTrailScreen();
}

class _NuangTrailScreen extends State<NuangTrail> {
  final MapController _mapController = MapController();
  List<LatLng> _gpxRoute = [];
  List<double> _elevations = [];
  bool _isTracking = false; // Tracking state
  bool _isPaused = false; // Pause state
  Timer? _timer;
  int _elapsedSeconds = 0; // Elapsed time
  double _totalDistance = 0.0; // Total distance
  LatLng? _lastLocation;

  final Location _location = Location();

  @override
  void initState() {
    super.initState();
    _loadGPXRoute();
  }

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

      setState(() {
        _gpxRoute = trailCoordinates;
        _elevations = elevations;
      });
    } catch (e) {
      print('Error loading GPX file: $e');
    }
  }

  void _startTracking() {
    setState(() {
      _isTracking = true;
      _isPaused = false;
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
        LatLng currentLocation =
        LatLng(locationData.latitude!, locationData.longitude!);

        if (_lastLocation != null) {
          final double distance = const Distance()
              .as(LengthUnit.Meter, _lastLocation!, currentLocation);
          setState(() {
            _totalDistance += distance / 1000;;
          });
        }
        _lastLocation = currentLocation;
      }
    });
  }

  void _pauseTracking() {
    setState(() {
      _isPaused = true;
      _isTracking = false;
    });
    print("_isPaused: $_isPaused, _isTracking: $_isTracking");
    _timer?.cancel();
  }

  void _resumeTracking() {
    setState(() {
      _isPaused = false;
      _isTracking = true;
    });
    print("_isPaused: $_isPaused, _isTracking: $_isTracking");
    _startTracking(); // Restart tracking
  }

  void _stopTracking() {
    setState(() {
      _isTracking = false;
      _isPaused = false;
      _elapsedSeconds = 0;
      _totalDistance = 0.0;
      _lastLocation = null;
    });
    _timer?.cancel();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuang Trail Map'),
      ),
      body: Stack(
        children: [
          _gpxRoute.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _calculateRouteCenter(_gpxRoute),
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate:
                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _gpxRoute,
                    strokeWidth: 4.0,
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),

          // Bottom Container with Elevation Profile and Time/Distance
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Elevation Profile
                Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: double.infinity,
                  color: Colors.white.withOpacity(0.9),
                  child: _elevations.isNotEmpty
                      ? ElevationProfile(elevations: _elevations)
                      : const Center(child: CircularProgressIndicator()),
                ),

                // Time and Distance with white background
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16), // Adjust padding for better fit
                  width: double.infinity, // Ensure it takes up the full width
                  child: Column(
                    children: [
                      Text(
                        "Time: ${_formatTime(_elapsedSeconds)}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4), // Space between time and distance
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
                      onPressed:
                      _isTracking ? _pauseTracking : _startTracking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        _isTracking ? Colors.red : Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_isTracking ? "Pause" : "Start"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';
import 'package:xml/xml.dart';
import 'package:location/location.dart';
import 'dart:async';
import '../Resources/elevation_profile.dart';

class NuangTrail extends StatefulWidget {
  const NuangTrail({Key? key}) : super(key: key);

  @override
  _NuangTrailScreen createState() => _NuangTrailScreen();
}

class _NuangTrailScreen extends State<NuangTrail> {
  final MapController _mapController = MapController();
  List<LatLng> _gpxRoute = [];
  List<double> _elevations = [];
  bool _isTracking = false; // Tracking state
  bool _isPaused = false; // Pause state
  Timer? _timer;
  int _elapsedSeconds = 0; // Elapsed time
  double _totalDistance = 0.0; // Total distance
  LatLng? _lastLocation;
  LatLng? _currentLocation;  // Add this to store the current location
  bool _isLoading = true;  // To handle loading state

  final Location _locationService = Location();  // Renamed to match variable name

  @override
  void initState() {
    super.initState();
    _loadGPXRoute();
    _initializeLocation(); // Initialize location tracking
  }

  // Initialize and fetch user location
  Future<void> _initializeLocation() async {
    if (!await _checkAndRequestPermissions()) return;

    _locationService.onLocationChanged.listen((LocationData locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        setState(() {
          _currentLocation =
              LatLng(locationData.latitude!, locationData.longitude!);
          _isLoading = false;  // Location is fetched, update loading state
        });
      }
    });
  }

  // Check and request permissions
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

      setState(() {
        _gpxRoute = trailCoordinates;
        _elevations = elevations;
      });
    } catch (e) {
      print('Error loading GPX file: $e');
    }
  }

  void _startTracking() {
    setState(() {
      _isTracking = true;
      _isPaused = false;
    });

    // Start timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });

    // Start location tracking
    _locationService.onLocationChanged.listen((LocationData locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        LatLng currentLocation =
        LatLng(locationData.latitude!, locationData.longitude!);

        if (_lastLocation != null) {
          final double distance = const Distance()
              .as(LengthUnit.Meter, _lastLocation!, currentLocation);
          setState(() {
            _totalDistance += distance / 1000;  // Convert to kilometers
          });
        }
        _lastLocation = currentLocation;
      }
    });
  }

  void _pauseTracking() {
    setState(() {
      _isPaused = true;
      _isTracking = false;
    });
    print("_isPaused: $_isPaused, _isTracking: $_isTracking");
    _timer?.cancel();
  }

  void _resumeTracking() {
    setState(() {
      _isPaused = false;
      _isTracking = true;
    });
    print("_isPaused: $_isPaused, _isTracking: $_isTracking");
    _startTracking(); // Restart tracking
  }

  void _stopTracking() {
    setState(() {
      _isTracking = false;
      _isPaused = false;
      _elapsedSeconds = 0;
      _totalDistance = 0.0;
      _lastLocation = null;
    });
    _timer?.cancel();
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

    centerLat -= 0.025; // Adjust center upwards slightly
    return LatLng(centerLat, centerLon);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuang Trail Map'),
      ),
      body: Stack(
        children: [
          _gpxRoute.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _calculateRouteCenter(_gpxRoute),
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate:
                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _gpxRoute,
                    strokeWidth: 4.0,
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),

          // Bottom Container with Elevation Profile and Time/Distance
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Elevation Profile
                Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: double.infinity,
                  color: Colors.white.withOpacity(0.9),
                  child: _elevations.isNotEmpty
                      ? ElevationProfile(elevations: _elevations)
                      : const Center(child: CircularProgressIndicator()),
                ),

                // Time and Distance with white background
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16), // Adjust padding for better fit
                  width: double.infinity, // Ensure it takes up the full width
                  child: Column(
                    children: [
                      Text(
                        "Time: ${_formatTime(_elapsedSeconds)}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4), // Space between time and distance
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
                        child: const Text("RESUME"),
                      ),
                      ElevatedButton(
                        onPressed: _stopTracking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("STOP"),
                      ),
                    ],
                  )
                      : _isTracking
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _pauseTracking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text("PAUSE"),
                      ),
                      ElevatedButton(
                        onPressed: _stopTracking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("STOP"),
                      ),
                    ],
                  )
                      : ElevatedButton(
                    onPressed: _startTracking,
                    child: const Text("START"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
