import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myforestnew/Admin/permitAdmin.dart';
import 'package:myforestnew/Admin/profileadmin.dart';
import 'package:myforestnew/Pages/profile.dart';
import 'package:myforestnew/bukitAyam/bukitAyam.dart';
import 'package:myforestnew/bukitBintang/bukitBintang.dart';
import 'package:myforestnew/bukitLagong/bukitLagong.dart';
import 'package:myforestnew/bukitPau/bukitPau.dart';
import 'package:myforestnew/mountHItam/mountHitam.dart';
import 'package:myforestnew/mountnuang/mountnuang.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class HomeAdmin extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomeAdmin> {
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
      'isSaved': false,
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
      'isSaved': false,
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
      'isSaved': false,
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
      'isSaved': false,
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
      'isSaved': false,
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
      'isSaved': false,
    },
  ];
  bool isSaved = false;
  String? savedDocumentId;
  Stream<List<String>> _getSavedMountainsStream() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection('saved_mounts')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  String userName = '';
  Future<void> fetchUserProfile() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
            .collection('profile')
            .doc(user.uid)
            .get();

        if (profileSnapshot.exists) {
          final profileData = profileSnapshot.data() as Map<String, dynamic>;

          setState(() {
            userName = "${profileData['first_name']} ${profileData['last_name']}";
          });
        } else {
          print("Profile document does not exist for user: ${user.uid}");
          setState(() {
            userName = "User";
          });
        }
      } else {
        print("No user logged in");
      }
    } catch (e) {
      print("Error fetching profile data: $e");
      setState(() {
        userName = "Error";
      });
    }
  }


  List<Map<String, dynamic>> _filteredMountains = [];
  List<int> _currentImageIndex = [];

  @override
  void initState() {
    super.initState();
    _currentImageIndex = List.filled(mountains.length, 0);
    _filteredMountains = mountains;
    _searchController.addListener(_filterMountains);
    _getSavedMountainsStream();
  }


  void _filterMountains() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMountains = mountains.where((mountain) {
        return mountain['name'].toLowerCase().contains(query);
      }).toList();
    });
  }
  void fetchSavedMountains() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final savedDocs = await FirebaseFirestore.instance
        .collection('saved_mounts')
        .where('userId', isEqualTo: user.uid)
        .get();

    final savedNames = savedDocs.docs.map((doc) => doc['name']).toSet();

    setState(() {
      for (var mountain in mountains) { // Assuming 'mountains' is your data list
        mountain['isSaved'] = savedNames.contains(mountain['name']);
      }
    });
  }
  int _currentIndex = 2;
  final PageController _pageController = PageController(initialPage: 2);

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
            color: isSelected ? Color(0xFFFFFFFF) : Color(0xFFB0B0B0),
            size: 30,
          ),
          if (isSelected)
            Text(
              label,
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 10,
                fontWeight: FontWeight.bold,
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
    return StreamBuilder<List<String>>(
      stream: _getSavedMountainsStream(),
      builder: (context, snapshot) {
        final savedMountains = snapshot.data ?? [];

        return Scaffold(
          backgroundColor: Color(0xFF1F1F1F),
          appBar: _currentIndex == 2
              ? AppBar(
            backgroundColor: Color(0xFF1F1F1F),
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
                  PermitAdmin(),
                  ProfilePageAdmin(),
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
                                    'Hello, $userName',
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
                                final isSaved = savedMountains.contains(mountain['name']);
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
                                            // Saved button
                                            Positioned(
                                              top: 10,
                                              right: 10,
                                              child: GestureDetector(
                                                onTap: () async {
                                                  final user = FirebaseAuth.instance.currentUser;

                                                  if (user == null) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Please log in to save mountains')),
                                                    );
                                                    return;
                                                  }

                                                  HapticFeedback.vibrate();

                                                  if (isSaved) {
                                                    // Remove saved mountain
                                                    final querySnapshot = await FirebaseFirestore.instance
                                                        .collection('saved_mounts')
                                                        .where('userId', isEqualTo: user.uid)
                                                        .where('name', isEqualTo: mountain['name'])
                                                        .get();

                                                    for (var doc in querySnapshot.docs) {
                                                      await doc.reference.delete();
                                                    }
                                                  } else {
                                                    // Add saved mountain
                                                    await FirebaseFirestore.instance.collection('saved_mounts').add({
                                                      'userId': user.uid,
                                                      'name': mountain['name'],
                                                      'distance': mountain['distance'],
                                                      'description': mountain['description'],
                                                      'images': mountain['images'],
                                                      'savedAt': DateTime.now(),
                                                    });
                                                  }
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  padding: EdgeInsets.all(6.0),
                                                  child: Icon(
                                                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                                                    color: Colors.white,
                                                    size: 30.0,
                                                  ),
                                                ),
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
                left: 16,
                right: 16,
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Color(0xFF2B2B2B),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(
                        icon: Icons.home,
                        label: 'Home',
                        isSelected: _currentIndex == 2,
                        index: 2,
                      ),
                      _buildNavItem(
                        icon: Icons.insert_drive_file,
                        label: 'Permit',
                        isSelected: _currentIndex == 0,
                        index: 0,
                      ),
                      _buildNavItem(
                        icon: Icons.person,
                        label: 'Profile',
                        isSelected: _currentIndex == 1,
                        index: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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