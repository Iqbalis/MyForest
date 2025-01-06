
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:myforestnew/Pages/navisaved.dart';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

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

  // Flag to track if the user has interacted with the map
  bool _hasUserInteracted = false;

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

        // Only recenter if the user hasn't interacted with the map
        if (!_hasUserInteracted && _currentLocation != null) {
          _mapController.move(_currentLocation!, 15.0); // Recenter to user's current location
        }
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
    final String gpxString = await rootBundle.loadString('assets/gpxFile/iiumTrail.xml');
    final document = XmlDocument.parse(gpxString);

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

  /// Recenter map to user's location
  void _recenterToUserLocation() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15.0); // Recenter to user's current location
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                initialCenter: _currentLocation ?? const LatLng(0, 0),
                initialZoom: 15,
                minZoom: 0,
                maxZoom: 100,
                onPositionChanged: (position, hasGesture) {
                  // Track if the user interacted with the map
                  _hasUserInteracted = hasGesture;
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                ),
                // Disable auto-recentering
                CurrentLocationLayer(
                  alignPositionOnUpdate: AlignOnUpdate.never, // Prevent auto-recentering
                  alignDirectionOnUpdate: AlignOnUpdate.never, // Prevent auto-direction updates
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
                // Display destination marker if available
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
                // Display route if available
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
                // Display GPX route if available
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
          // Recenter button (top-right)
          Positioned(
            bottom: 200, // Set to 16 for some padding from the top of the screen
            right: 20,
            child: SizedBox(
              width: 68, // Set the width
              height: 68, // Set the height
              child: FloatingActionButton(
                onPressed: _recenterToUserLocation,
                backgroundColor: Colors.blue,
                child: const Icon(
                  Icons.my_location,
                  color: Colors.white,
                  size: 30, // Adjust the icon size
                ),
                shape: const CircleBorder(),
              ),
            ),

          ),
          // Add trail button (bottom-right)
          Positioned(
            bottom: 110,
            right: 20,
            child: SizedBox(
              width: 70, // Adjust the width to give space for the shadow
              height: 70, // Adjust the height similarly
              child: Material(
                shape: const CircleBorder(), // Circular shape
                elevation: 10, // Shadow elevation for a visible shadow
                shadowColor: Colors.black.withOpacity(0.5), // Shadow color
                color: Colors.transparent, // No background color for Material itself
                child: InkWell(
                  borderRadius: BorderRadius.circular(34), // Matches the circular shape
                  onTap: () async {
                    final selectedTrail = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => navisaved(),
                      ),
                    );

                    if (selectedTrail != null && selectedTrail is List<LatLng>) {
                      setState(() {
                        _gpxRoute = selectedTrail;
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black, // Button background color
                      shape: BoxShape.circle, // Ensures the container is circular
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30, // Adjust the icon size
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
