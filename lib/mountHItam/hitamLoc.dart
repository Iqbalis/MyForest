import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class hitamloc extends StatelessWidget {
  final String location = "Mount Hitam, Malaysia"; // Place name or query

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
          title: Text("Mount Hitam Location"),
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
    final googleMapUrl = 'https://www.google.com/maps/place/Gunung+Hitam/@3.1673052,101.8736765,13z/data=!3m1!4b1!4m6!3m5!1s0x31cc2f12bf1bb2bd:0x3517d49408ad4a79!8m2!3d3.1672222!4d101.9475!16s%2Fg%2F121g1wcv?entry=ttu&g_ep=EgoyMDI0MTIxMS4wIKXMDSoASAFQAw%3D%3D';

    if (await canLaunch(googleMapUrl)) {
      await launch(googleMapUrl);
    } else {
      throw 'Could not open Google Maps.';
    }
  }
}