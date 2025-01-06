import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myforestnew/bukitAyam/bukitAyam.dart';
import 'package:myforestnew/bukitBintang/bukitBintang.dart';
import 'package:myforestnew/bukitLagong/bukitLagong.dart';
import 'package:myforestnew/bukitPau/bukitPau.dart';
import 'package:myforestnew/mountHItam/mountHitam.dart';
import 'package:myforestnew/mountnuang/mountnuang.dart';

class SavedPage extends StatefulWidget {
  @override
  _SavedPageState createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget? _getMountainPage(String mountainName) {
    switch (mountainName) {
      case 'Bukit Lagong':
        return bukitLagong();
      case 'Bukit Pau':
        return bukitPau();
      case 'Mount Hitam':
        return mountHitam();
      case 'Mount Nuang':
        return MountNuangPage();
      case 'Bukit Guling Ayam':
        return bukitAyam();
      case 'Bukit Sri Bintang':
        return bukitBintang();
      default:
        return null; // Return null if no match is found
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F1F1F),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF1F1F1F),
        elevation: 0,
        title: Text(
          'Saved',
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.white,
          tabs: [
            Tab(icon: Icon(Icons.list), text: "List"),
            Tab(icon: Icon(Icons.download), text: "Download"),
          ],
        ),
        toolbarHeight: 80,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListView(),
          _buildDownloadView(),
        ],
      ),
    );
  }

  Widget _buildListView() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Text(
          'Please log in to view saved mountains.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('saved_mounts')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final savedMountains = snapshot.data?.docs ?? [];

        if (savedMountains.isEmpty) {
          return Center(
            child: Text(
              'No saved mountains yet.',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: savedMountains.length + 1,
          itemBuilder: (context, index) {
            if (index == savedMountains.length) {
              return SizedBox(height: 65);
            }

            final mountain = savedMountains[index].data() as Map<String, dynamic>;
            return GestureDetector(
              onTap: () {
                final String mountainName = mountain['name'];
                final mountainPage = _getMountainPage(mountainName);

                if (mountainPage != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => mountainPage),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Page for $mountainName not found.')),
                  );
                }
              },
              child: MountainCard(mountain: mountain),
            );
          },
        );
      },
    );
  }

  Widget _buildDownloadView() {
    return Center(
      child: Text(
        "It seems like you haven't downloaded anything yet.",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class MountainCard extends StatefulWidget {
  final Map<String, dynamic> mountain;

  const MountainCard({Key? key, required this.mountain}) : super(key: key);

  @override
  _MountainCardState createState() => _MountainCardState();
}

class _MountainCardState extends State<MountainCard> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final String name = widget.mountain['name'] ?? 'Unknown Mountain';
    final String distance = widget.mountain['distance'] ?? 'N/A';
    final String description = widget.mountain['description'] ?? 'No description available';
    final List<String> images = (widget.mountain['images'] as List<dynamic>?)?.cast<String>() ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                      _currentImageIndex = pageIndex;
                    });
                  },
                  itemBuilder: (context, pageIndex) {
                    return ClipRRect(
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
                    );
                  },
                )
                    : Center(
                  child: Text(
                    'No images available',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                if (images.isNotEmpty)
                  Positioned(
                    bottom: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        images.length,
                            (dotIndex) => buildDot(dotIndex, _currentImageIndex),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 5),
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