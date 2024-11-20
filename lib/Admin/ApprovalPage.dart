import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myforestnew/Admin/detailApplication.dart';

class PermitsListPage extends StatefulWidget {
  @override
  _PermitsListPageState createState() => _PermitsListPageState();
}

class _PermitsListPageState extends State<PermitsListPage> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> permits = [];
  List<Map<String, dynamic>> filteredPermits = [];

  @override
  void initState() {
    super.initState();
    fetchPermits();
  }

  /// Fetch permits from Firestore
  Future<void> fetchPermits() async {
    try {
      final QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('permits').get();

      final List<Map<String, dynamic>> fetchedPermits = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'approved': data['approved'] ?? false,
          'date': data['date'] ?? '',
          'guide': data['guide'] ?? '',
          'mountain': data['mountain'] ?? '',
          'participants': data['participants'] ?? [],
        };
      }).toList();

      setState(() {
        permits = fetchedPermits;
        filteredPermits = fetchedPermits;
      });
    } catch (e) {
      print("Error fetching permits: $e");
    }
  }

  /// Update permit status in Firestore
  Future<void> updatePermitStatus(String permitId, String status) async {
    try {
      await FirebaseFirestore.instance.collection('permits').doc(permitId).update({
        'status': status,
      });

      // Refresh data after updating
      fetchPermits();
    } catch (e) {
      print("Error updating permit status: $e");
    }
  }

  /// Filter permits based on search query
  void filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredPermits = permits;
      } else {
        filteredPermits = permits
            .where((permit) =>
        permit['participants']
            .any((participant) => participant['name']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase())) ||
            permit['mountain']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Permits List',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.black,
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search permit',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                      ),
                      onChanged: filterSearch,
                    ),
                  ),
                  Icon(Icons.search, color: Colors.white),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            // Permits List
            Expanded(
              child: filteredPermits.isEmpty
                  ? Center(
                child: Text(
                  "No application found",
                  style: TextStyle(color: Colors.white),
                ),
              )
                  : ListView.builder(
                itemCount: filteredPermits.length,
                itemBuilder: (context, index) {
                  final permit = filteredPermits[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 6.0),
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9.0),
                    ),
                    child: Row(
                      children: [
                        // Placeholder for the icon
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.green[200],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.person,
                              color: Colors.green[800],
                              size: 24,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.0),
                        // Permit details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => detailApplication(
                                        documentId: permit['id'],
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  permit['participants'].isNotEmpty
                                      ? permit['participants'][0]['name'] ?? "Unknown"
                                      : "No Participants", // Fallback if no participants
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              Text(
                                "Location: ${permit['mountain']}",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14.0,
                                ),
                              ),
                              Text(
                                "Date: ${permit['date']}",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.0),
                        // Accept and reject icons
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                updatePermitStatus(permit['id'], "rejected");
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () {
                                updatePermitStatus(permit['id'], "approved");
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

