import 'package:flutter/material.dart';
import 'package:myforestnew/Admin/permitAdmin.dart';
import 'package:myforestnew/Pages/HomPage.dart';
import 'package:myforestnew/permit/Permit.dart';
import 'package:myforestnew/Pages/savedpage.dart';
import 'package:myforestnew/Pages/setting.dart';
import 'package:myforestnew/permit/permitPending.dart'; // Add the Setting page import

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 4; // Set initial index to "Profile" tab
  final PageController _pageController = PageController(initialPage: 4);

  void _onNavItemTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required int index,
  }) {
    return GestureDetector(
      onTap: () => _onNavItemTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.black87 : Colors.black45,
            size: 30,
          ),
          if (isSelected)
            Container(
              margin: EdgeInsets.only(top: 2),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFF81b1ce),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: Color(0xFF000035),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double nameFontSize = 24.0;
    const double detailsFontSize = 16.0;

    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Main content
            PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(), // Disable swipe
              children: [
                HomePage(),
                Permit(),
                PermitAdmin(),
                SavedPage(),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 95.0),
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
                                      MaterialPageRoute(
                                          builder: (context) => Setting()),
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
                                SizedBox(width: 8.0),
                                Image.asset(
                                  'assets/my.png', // Replace with actual flag image path
                                  width: 24,
                                  height: 24,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Text(
                              'adibsaid@gmail.com',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: detailsFontSize,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 4.0),
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
                              // Replace permitStatus with your actual permit status page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => permitStatus()),
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
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Permit Status',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: detailsFontSize,
                                        ),
                                      ),
                                      Icon(Icons.arrow_forward,
                                          color: Colors.black),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 8,
              left: 24,
              right: 24,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Color(0xFFaad6ec),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      icon: Icons.home,
                      label: 'Home',
                      isSelected: _currentIndex == 0,
                      index: 0,
                    ),
                    _buildNavItem(
                      icon: Icons.insert_drive_file,
                      label: 'Permit',
                      isSelected: _currentIndex == 1,
                      index: 1,
                    ),
                    _buildNavItem(
                      icon: Icons.navigation,
                      label: 'Admin',
                      isSelected: _currentIndex == 2,
                      index: 2,
                    ),
                    _buildNavItem(
                      icon: Icons.bookmark,
                      label: 'Saved',
                      isSelected: _currentIndex == 3,
                      index: 3,
                    ),
                    _buildNavItem(
                      icon: Icons.person,
                      label: 'Profile',
                      isSelected: _currentIndex == 4,
                      index: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}