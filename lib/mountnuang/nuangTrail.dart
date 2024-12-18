import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';
import 'package:xml/xml.dart';
import 'package:location/location.dart';
import '../Resources/elevation_profile.dart'; // Import the ElevationProfile widget

class NuangTrail extends StatefulWidget {
  const NuangTrail({Key? key}) : super(key: key);

  @override
  _NuangTrailScreen createState() => _NuangTrailScreen();
}

class _NuangTrailScreen extends State<NuangTrail> {
  final MapController _mapController = MapController();
  List<LatLng> _gpxRoute = [];
  List<double> _elevations = []; // Store elevation data

  @override
  void initState() {
    super.initState();
    _loadGPXRoute();
  }

  Future<void> _loadGPXRoute() async {
    try {
      // Load GPX file
      final String gpxString =
      await rootBundle.loadString('assets/gpxFile/nuang.xml');
      final document = XmlDocument.parse(gpxString);

      // Extract route points and elevations
      final List<LatLng> trailCoordinates = [];
      final List<double> elevations = [];

      final waypoints = document.findAllElements('trkpt');
      for (var waypoint in waypoints) {
        final lat = double.parse(waypoint.getAttribute('lat')!);
        final lon = double.parse(waypoint.getAttribute('lon')!);
        final ele = double.tryParse(waypoint.findElements('ele').first.text) ?? 0.0;

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

  LatLng _calculateRouteCenter(List<LatLng> route) {
    double latSum = 0;
    double lonSum = 0;

    for (var point in route) {
      latSum += point.latitude;
      lonSum += point.longitude;
    }

    double centerLat = latSum / route.length;
    double centerLon = lonSum / route.length;

    // Adjust the center latitude upwards slightly
    centerLat -= 0.018; // Adjust this value as needed

    return LatLng(centerLat, centerLon);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuang Trail Map'),
      ),
      body: _gpxRoute.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // Map View
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _calculateRouteCenter(_gpxRoute),
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
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

          // Elevation Profile and Start Button at the Bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min, // Ensures it fits the content
              children: [
                // Elevation Profile Container
                Container(
                  height: MediaQuery.of(context).size.height * 0.30,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: _elevations.isNotEmpty
                      ? ElevationProfile(elevations: _elevations)
                      : const Center(child: CircularProgressIndicator()),
                ),

                // "Start" Button Below the Elevation Profile
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 20.0), // Spacing
                  child: ElevatedButton(
                    onPressed: () {
                      // Define action when the button is pressed
                      print("Start button pressed!");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Button background color
                      foregroundColor: Colors.white, // Button text color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12), // Button padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Rounded corners
                      ),
                    ),
                    child: const Text(
                      "Start",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
