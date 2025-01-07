import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Pauloc extends StatelessWidget {
  final String location = "Bukit Pau, Malaysia"; // Place name or query

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
          title: Text("Bukit Pau Location"),
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
    final googleMapUrl = 'https://www.google.com/maps/place/Bukit+Pau+Peak/@3.2352237,101.7720692,17z/data=!3m1!4b1!4m6!3m5!1s0x31cc39d904625553:0x6b17d751813e1f6f!8m2!3d3.2352183!4d101.7746441!16s%2Fg%2F11jt5hp_nz?entry=ttu&g_ep=EgoyMDI0MTIxMS4wIKXMDSoASAFQAw%3D%3D';
    if (await canLaunch(googleMapUrl)) {
      await launch(googleMapUrl);
    } else {
      throw 'Could not open Google Maps.';
    }
  }
}