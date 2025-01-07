import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class lagongLoc extends StatelessWidget {
  final String location = "Bukit Lagong, Malaysia"; // Place name or query

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
          title: Text("Bukit Lagong Location"),
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
    final googleMapUrl = 'https://www.google.com/maps/place/Bukit+Lagong,+68100+Batu+Caves,+Selangor/@3.2594078,101.611623,14.25z/data=!4m6!3m5!1s0x31cc46c71e849857:0x50b481984a0e2f8e!8m2!3d3.258545!4d101.6394368!16s%2Fg%2F1hhgm0t9q?entry=ttu&g_ep=EgoyMDI0MTIxMS4wIKXMDSoASAFQAw%3D%3D';

    if (await canLaunch(googleMapUrl)) {
      await launch(googleMapUrl);
    } else {
      throw 'Could not open Google Maps.';
    }
  }
}