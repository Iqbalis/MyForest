import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Nuangloc extends StatelessWidget {
  final String location = "Mount Nuang, Malaysia"; // Place name or query

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
          title: Text("Mount Nuang Location"),
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
    final googleMapUrl = 'https://www.google.com/maps?sca_esv=5564708a59597dc0&biw=1280&bih=557&output=search&q=mount+nuang&source=lnms&fbs=AEQNm0Aa4sjWe7Rqy32pFwRj0UkWd8nbOJfsBGGB5IQQO6L3J3ppPdoHI1O-XvbXbpNjYYxy9nF8_reHIdIO9ZF-Un9ci1-LWsJ8u77b8cWxASa3pFiyhPNiKaWzk1D1EuqM65L0P-s4UqyVnFNPCENlcb9d8imfGlpDOYD3ZJkbNJADhtj5UXIaTZQd9Tl9L-XGLXtFqA6lxGNqjf-5QQh6yj0j_iXpPQ&entry=mc&ved=1t:200715&ictx=111';

    if (await canLaunch(googleMapUrl)) {
      await launch(googleMapUrl);
    } else {
      throw 'Could not open Google Maps.';
    }
  }
}