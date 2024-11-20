import 'package:flutter/material.dart';
import 'package:myforestnew/Pages/HomPage.dart';
import 'package:myforestnew/permit/Permit.dart';
import 'package:myforestnew/Pages/savedpage.dart';
import 'package:myforestnew/Pages/setting.dart';
import 'package:myforestnew/permit/permitstatus1.dart';

import '../permit/permitPending.dart';

class ProfilePage extends StatelessWidget {
  final double nameFontSize;
  final double detailsFontSize;

  ProfilePage({
    this.nameFontSize = 30.0,
    this.detailsFontSize = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(); // Navigates back when pressed
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
          children: [
            Center(
              child: CircleAvatar(
                radius: 130,
                backgroundImage: AssetImage(
                    'assets/profile.jpg'), // Replace with actual image path
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Adib Said',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: nameFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Setting()),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    '21 Years Old',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: detailsFontSize,
                    ),
                  ),
                  SizedBox(width: 8.0), // Added spacing between the text and the flag
                  Image.asset(
                    'assets/my.png', // Replace with actual flag image path
                    width: 24, // Adjust the size as needed
                    height: 24,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'adibsaid@gmail.com',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: detailsFontSize,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Text(
                'Port Dickson, Malaysia',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: detailsFontSize,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Replace with the action you want, e.g., navigate to a PermitStatus page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => permitStatus()), // Example action
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Permit Status',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: detailsFontSize,
                          ),
                        ),
                        Icon(Icons.arrow_forward, color: Colors.black),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Add more sections like mountain history here
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          _buildBottomNavigationBarItem(
            'assets/icon/home.jpg', // Replace with your custom icon path
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
          _buildBottomNavigationBarItem(
            'assets/icon/permit.png',
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Permit()),
              );
            },
          ),
          _buildBottomNavigationBarItem(
            'assets/icon/navi.png',
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Permit()),
              );
            },
          ),
          _buildBottomNavigationBarItem(
            'assets/icon/save.png',
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SavedPage()),
              );
            },
          ),
          _buildBottomNavigationBarItem(
            'assets/icon/profile.png',
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper function to build BottomNavigationBarItem with tap gesture
  BottomNavigationBarItem _buildBottomNavigationBarItem(
      String assetPath, VoidCallback onTap) {
    return BottomNavigationBarItem(
      icon: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.only(top: 3.0),
          child: Image.asset(
            assetPath, // Use provided asset path
            height: 40,
          ),
        ),
      ),
      label: '', // Empty label for custom icons
    );
  }

  Widget buildImageCard(String title, String distance, String imagePath) {
    return Card(
      color: Colors.grey[850],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(imagePath),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text(
              distance,
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }
}

