import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ayamLoc extends StatelessWidget {
  final String location = "Bukit Guling Ayam, Malaysia"; // Place name or query

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black87,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Bukit Guling Ayam Location"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // Go back to the previous screen
            },
          ),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () => _openMap(location),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              "Open in Google Maps",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openMap(String location) async {
    // Construct the Google Maps URL with the location name
    final googleMapUrl = 'https://www.google.com/maps/place/Bukit+Guling+Ayam/@3.2322529,101.6760232,14.5z/data=!4m6!3m5!1s0x31cc38864717b92f:0x22c5ac733c137a21!8m2!3d3.2333333!4d101.7166667!16s%2Fg%2F1thzldbx?entry=ttu&g_ep=EgoyMDI0MTIxMS4wIKXMDSoASAFQAw%3D%3D';

    if (await canLaunch(googleMapUrl)) {
      await launch(googleMapUrl);
    } else {
      throw 'Could not open Google Maps.';
    }
  }
}