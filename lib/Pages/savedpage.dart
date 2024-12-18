
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SavedPage extends StatefulWidget {
  @override
  _SavedPageState createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentImageIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Saved',
          style: TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.list), text: "List"),
            Tab(icon: Icon(Icons.download), text: "Download"),
          ],
        ),
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
          itemCount: savedMountains.length + 1, // Add 1 for the SizedBox
          itemBuilder: (context, index) {
            if (index == savedMountains.length) {
              return SizedBox(height: 65); // Add space at the bottom
            }

            final mountain = savedMountains[index].data() as Map<String, dynamic>;
            return _buildMountainCard(mountain);
          },
        );
      },
    );
  }

  Widget _buildMountainCard(Map<String, dynamic> mountain) {
    final String name = mountain['name'] ?? 'Unknown Mountain';
    final String distance = mountain['distance'] ?? 'N/A';
    final String description = mountain['description'] ?? 'No description available';
    final List<String> images = (mountain['images'] as List<dynamic>?)?.cast<String>() ?? [];

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


  Widget _buildDownloadView() {
    return Center(
      child: Text(
        "Download Section",
        style: TextStyle(color: Colors.white),
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
