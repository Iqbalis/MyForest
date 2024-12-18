import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:myforestnew/Pages/savedpage.dart';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class Navigation extends StatefulWidget {
  @override
  _NavigationScreen createState() => new _NavigationScreen();
}

class _NavigationScreen extends State<Navigation> {
  final Location _locationService = Location();

  bool _isLoading = true;
  LatLng? _currentLocation;
  LatLng? _destination;
  List<LatLng> _route = [];
  List<LatLng> _gpxRoute = [];

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
    // Load the GPX file from assets
    final String gpxString = await rootBundle.loadString('assets/gpxFile/iiumTrail.xml');
    final document = XmlDocument.parse(gpxString);

    // Extract coordinates (latitude and longitude) from the GPX file
    final List<LatLng> trailCoordinates = [];
    final waypoints = document.findAllElements('trkpt'); // Assuming GPX format uses 'trkpt' for waypoints

    for (var waypoint in waypoints) {
      final lat = double.parse(waypoint.getAttribute('lat')!);
      final lon = double.parse(waypoint.getAttribute('lon')!);
      trailCoordinates.add(LatLng(lat, lon));
    }

    setState(() {
      _gpxRoute = trailCoordinates; // Store the parsed route
    });
  }

  /// Decode polyline from OSRM response
  List<List<double>> _decodePolyline(String polyline) {
    const factor = 1e5;
    List<List<double>> points = [];
    int index = 0;
    int len = polyline.length;
    int lat = 0;
    int lon = 0;

    while (index < len) {
      int shift = 0;
      int result = 0;
      int byte;
      do {
        byte = polyline.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      lat += dlat;
      shift = 0;
      result = 0;

      do {
        byte = polyline.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);

      int dlng = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      lon += dlng;
      points.add([lat / factor, lon / factor]);
    }
    return points;
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
            Navigator.of(context).pop(); // Navigates back when pressed
          },
        ),
        title: const Text(
          "Map with Directions",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _destination ?? _currentLocation ?? const LatLng(0, 0),
                initialZoom: 15,
                minZoom: 0,
                maxZoom: 100,
                // Disable following the current location continuously
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture) {
                    // If the user interacts with the map, don't reset the map to the user's location
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                ),
                CurrentLocationLayer(
                  alignPositionOnUpdate: AlignOnUpdate.always,
                  alignDirectionOnUpdate: AlignOnUpdate.never,
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
                if (_destination != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _destination!,
                        width: 50,
                        height: 50,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      )
                    ],
                  ),
                if (_currentLocation != null &&
                    _destination != null &&
                    _route.isNotEmpty)
                  PolylineLayer(polylines: [
                    Polyline(
                      points: _route,
                      strokeWidth: 4.0,
                      color: Colors.red,
                    )
                  ]),
                if (_gpxRoute.isNotEmpty)
                  PolylineLayer(polylines: [
                    Polyline(
                      points: _gpxRoute,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    )
                  ]),
              ],
            ),
          ),
          // Add the button
          Positioned(
            bottom: 90,
            right: 20,
            child: ElevatedButton(
              onPressed: () async {
                // Navigate to SavedTrailsPage and wait for the result
                final selectedTrail = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SavedPage(),
                  ),
                );

                // Check if a trail was selected
                if (selectedTrail != null && selectedTrail is List<LatLng>) {
                  setState(() {
                    _gpxRoute = selectedTrail; // Update the GPX route with the selected trail
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(20), // Adjust size
                backgroundColor: Colors.black, // Background color
                shadowColor: Colors.black.withOpacity(0.2), // Shadow effect
                elevation: 6, // Shadow elevation
              ),
              child: Icon(
                Icons.add, // Plus icon
                size: 30, // Adjust size
                color: Colors.white, // Icon color
              ),
            ),
          ),
        ],
      ),
    );
  }
}
