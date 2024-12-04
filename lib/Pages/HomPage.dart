import 'package:flutter/material.dart';
import 'package:myforestnew/Admin/homeadmin.dart';
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
    _filteredMountains = mountains; // Start with the full list
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

  @override
  void dispose() {
    _searchController.dispose(); // Clean up the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: TextField(
          controller: _searchController, // Set the controller
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search for a mountain',
            hintStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white12,
            prefixIcon: Icon(Icons.search, color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 16.0), // Fixed height box at the top
          Expanded(
            child: SingleChildScrollView( // Allow scrolling for the rest of the content
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start, // Align text to the left
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
                    physics: NeverScrollableScrollPhysics(), // Disable scrolling for the inner ListView
                    shrinkWrap: true, // Prevent ListView from taking infinite height
                    itemCount: _filteredMountains.length, // Use filtered list
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
                                              builder: (context) => mountain['detailPage'],
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
                                            (dotIndex) => buildDot(dotIndex, _currentImageIndex[index]),
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
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => mountain['detailPage'],
                                      ),
                                    );
                                  },
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  distance,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              description,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.only(top: 3.0),
                child: Image.asset(
                  'assets/icon/home.jpg',
                  height: 40,
                ),
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Permit()),
                );
              },
              child: Image.asset(
                'assets/icon/permit.png',
                height: 40,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Navigation()),
                );
              },
              child: Image.asset(
                'assets/icon/navi.png',
                height: 40,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SavedPage()),
                );
              },
              child: Image.asset(
                'assets/icon/save.png',
                height: 40,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              child: Image.asset(
                'assets/icon/profile.png',
                height: 40,
              ),
            ),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index, int currentIndex) {
    return Container(
      height: 8,
      width: currentIndex == index ? 12 : 8,
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: currentIndex == index ? Colors.white : Colors.grey,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}



