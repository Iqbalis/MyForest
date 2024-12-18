import 'package:flutter/material.dart';
import 'package:myforestnew/Pages/navigation.dart';
import 'package:myforestnew/permit/Permit.dart';
import 'package:myforestnew/Pages/profile.dart';
import 'package:myforestnew/Pages/savedpage.dart';
import 'package:myforestnew/bukitAyam/bukitAyam.dart';
import 'package:myforestnew/bukitBintang/bukitBintang.dart';
import 'package:myforestnew/bukitLagong/bukitLagong.dart';
import 'package:myforestnew/bukitPau/bukitPau.dart';
import 'package:myforestnew/mountHItam/mountHitam.dart';
import 'package:myforestnew/mountnuang/mountnuang.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> mountains = [
    {
      'name': 'Mount Nuang',
      'distance': '17.9 KM',
      'description': 'Bukit Sungai Putih Forest Reserve',
      'images': [
        'assets/nuang/nuang1.png',
        'assets/nuang/nuang2.jpeg',
        'assets/nuang/nuang3.jpg',
      ],
      'detailPage': MountNuangPage(),
    },
    {
      'name': 'Mount Hitam',
      'distance': '13.2 KM',
      'description': 'Bukit Sungai Putih Forest Reserve',
      'images': [
        'assets/hitam/hitam1.jpg',
        'assets/hitam/hitam2.jpg',
        'assets/hitam/hitam3.jpg',
      ],
      'detailPage': mountHitam(),
    },
    {
      'name': 'Bukit Lagong',
      'distance': '4.3 KM',
      'description': 'Bukit Lagong Forest Reserve',
      'images': [
        'assets/lagong/lagong1.jpg',
        'assets/lagong/lagong2.jpg',
        'assets/lagong/lagong3.jpg',
      ],
      'detailPage': bukitLagong(),
    },
    {
      'name': 'Bukit Pau',
      'distance': '8.9 KM',
      'description': 'Bukit Sungai Putih Forest Reserve',
      'images': [
        'assets/pau/pau1.jpg',
        'assets/pau/pau2.jpg',
        'assets/pau/pau3.jpg',
      ],
      'detailPage': bukitPau(),
    },
    {
      'name': 'Bukit Guling Ayam',
      'distance': '1 KM',
      'description': 'Gombak, Selangor Malaysia',
      'images': [
        'assets/ayam/ayam1.jpg',
        'assets/ayam/ayam2.jpg',
        'assets/ayam/ayam3.jpg',
      ],
      'detailPage': bukitAyam(),
    },
    {
      'name': 'Bukit Sri Bintang',
      'distance': '11 KM',
      'description': 'Bukit Kiara Forest Reserve',
      'images': [
        'assets/bintang/bintang1.jpg',
        'assets/bintang/bintang2.jpg',
        'assets/bintang/bintang3.png',
      ],
      'detailPage': bukitBintang(),
    },
  ];
  List<Map<String, dynamic>> _filteredMountains = [];
  List<int> _currentImageIndex = [];

  @override
  void initState() {
    super.initState();
    _currentImageIndex = List.filled(mountains.length, 0);
    _filteredMountains = mountains;
    _searchController.addListener(_filterMountains);
  }

  void _filterMountains() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMountains = mountains.where((mountain) {
        return mountain['name'].toLowerCase().contains(query);
      }).toList();
    });
  }

  int _currentIndex = 4;
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _currentIndex == 4
          ? AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search for a mountain',
                hintStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                prefixIcon: Icon(Icons.search, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        toolbarHeight: 90, // Adjust this to control the AppBar's overall height
      )
          : null,

      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              Permit(),
              Navigation(),
              SavedPage(),
              ProfilePage(),
              SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                'Hello, Adib said',
                                style: TextStyle(color: Colors.white, fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _filteredMountains.length,
                          itemBuilder: (context, index) {
                            final mountain = _filteredMountains[index];
                            final String name = mountain['name'] ?? 'Unknown Mountain';
                            final String distance = mountain['distance'] ?? 'N/A';
                            final String description = mountain['description'] ?? 'No description available';
                            final List<String> images = mountain['images']?.cast<String>() ?? [];

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 250,
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        images.isNotEmpty
                                            ? PageView.builder(
                                          itemCount: images.length,
                                          onPageChanged: (pageIndex) {
                                            setState(() {
                                              _currentImageIndex[index] = pageIndex;
                                            });
                                          },
                                          itemBuilder: (context, pageIndex) {
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                    mountain['detailPage'],
                                                  ),
                                                );
                                              },
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(10.0),
                                                child: Image.asset(
                                                  images[pageIndex],
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Center(
                                                      child: Text(
                                                        'Image not found',
                                                        style: TextStyle(color: Colors.white),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                            : Center(
                                          child: Text(
                                            'No images available',
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 10,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: List.generate(
                                              images.length,
                                                  (dotIndex) =>
                                                  buildDot(dotIndex, _currentImageIndex[index]),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        distance,
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    description,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  SizedBox(height: 5),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 70.0),
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
                    isSelected: _currentIndex == 4,
                    index: 4,
                  ),
                  _buildNavItem(
                    icon: Icons.insert_drive_file,
                    label: 'Permit',
                    isSelected: _currentIndex == 0,
                    index: 0,
                  ),
                  _buildNavItem(
                    icon: Icons.navigation,
                    label: 'Navigation',
                    isSelected: _currentIndex == 1,
                    index: 1,
                  ),
                  _buildNavItem(
                    icon: Icons.bookmark,
                    label: 'Saved',
                    isSelected: _currentIndex == 2,
                    index: 2,
                  ),
                  _buildNavItem(
                    icon: Icons.person,
                    label: 'Profile',
                    isSelected: _currentIndex == 3,
                    index: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index, int currentIndex) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 5),
      height: 8.0,
      width: currentIndex == index ? 16.0 : 8.0,
      decoration: BoxDecoration(
        color: currentIndex == index ? Colors.white : Colors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}