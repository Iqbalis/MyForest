import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myforestnew/Admin/detailApplication.dart';

class PermitsListPage extends StatefulWidget {
  @override
  _PermitsListPageState createState() => _PermitsListPageState();
}


class _PermitsListPageState extends State<PermitsListPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> permits = [];
  List<Map<String, dynamic>> pendingPermits = [];
  List<Map<String, dynamic>> approvedPermits = [];
  List<Map<String, dynamic>> rejectedPermits = [];
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    fetchPermits();
  }

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
          'status': data['status'] ?? 'pending',
        };
      }).toList();

      setState(() {
        permits = fetchedPermits;
        categorizePermits();
      });
    } catch (e) {
      print("Error fetching permits: $e");
    }
  }

  void categorizePermits() {
    pendingPermits = permits.where((permit) => permit['status'] == 'pending').toList();
    approvedPermits = permits.where((permit) => permit['status'] == 'approved').toList();
    rejectedPermits = permits.where((permit) => permit['status'] == 'rejected').toList();
  }

  Future<void> updatePermitStatus(String permitId, String status) async {
    try {
      await FirebaseFirestore.instance.collection('permits').doc(permitId).update({
        'status': status,
      });

      fetchPermits();
    } catch (e) {
      print("Error updating permit status: $e");
    }
  }

  Widget buildPermitCard(Map<String, dynamic> permit) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[400],
              child: Icon(Icons.person, color: Colors.grey[800], size: 30),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              detailApplication(documentId: permit['id']),
                        ),
                      );
                    },
                    child: Text(
                      permit['participants'].isNotEmpty
                          ? permit['participants'][0]['name'] ?? "Unknown"
                          : "No Participants",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Location: ${permit['mountain']}",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  Text(
                    "Date: ${permit['date']}",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            if (permit['status'] == 'pending')
              Row(
                children: [
                  // Rejection Circle
                  GestureDetector(
                    onTap: () {
                      updatePermitStatus(permit['id'], "rejected");
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.red),
                    ),
                  ),
                  SizedBox(width: 8),
                  // Approval Circle
                  GestureDetector(
                    onTap: () {
                      updatePermitStatus(permit['id'], "approved");
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check, color: Colors.green),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget buildPermitList(List<Map<String, dynamic>> permits) {
    if (permits.isEmpty) {
      return Center(
        child: Text(
          "No applications found",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: permits.length,
      itemBuilder: (context, index) {
        return buildPermitCard(permits[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Permit List",
          style: TextStyle(
            fontFamily: 'OpenSans', // Apply OpenSans font
            color: Colors.white, // Title text color
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.black87,
        iconTheme: IconThemeData(
          color: Colors.white, // Set the back button color to white
        ),
        bottom: TabBar(
          controller: tabController,
          indicatorColor: Colors.white,
          unselectedLabelColor: Colors.grey[500],
          labelStyle: TextStyle(
            fontFamily: 'OpenSans', // Apply OpenSans font to tab labels
            color: Colors.white,
            fontSize: 16,
          ),
          tabs: [
            Tab(text: "Pending"),
            Tab(text: "Approved"),
            Tab(text: "Rejected"),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: buildPermitList(pendingPermits),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: buildPermitList(approvedPermits),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: buildPermitList(rejectedPermits),
          ),
        ],
      ),
    );
  }
}