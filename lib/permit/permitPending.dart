import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myforestnew/permit/ePermit.dart';

class PermitStatus extends StatefulWidget {
  @override
  _PermitStatusState createState() => _PermitStatusState();
}

class _PermitStatusState extends State<PermitStatus> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? permitData;

  @override
  void initState() {
    super.initState();
    fetchPermitData();
  }

  Future<void> fetchPermitData() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      // Fetch permit linked to user UID
      final permitQuery = await _firestore
          .collection('permits')
          .doc(user.uid) // Assuming the permit is stored by user UID
          .get();

      if (permitQuery.exists) {
        setState(() {
          permitData = permitQuery.data();
        });
      } else {
        throw Exception("No permit found for the user");
      }
    } catch (e) {
      setState(() {
        permitData = {'error': e.toString()};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F1F1F),
      appBar: AppBar(
        backgroundColor: Color(0xFF1F1F1F),
        iconTheme: IconThemeData(
          color: Colors.white, // Set the back button color to black
        ),
      ),
      body: permitData == null
          ? Center(child: CircularProgressIndicator())
          : permitData!.containsKey('error')
          ? Center(
        child: Text(
          'Error: ${permitData!['error']}',
          style: TextStyle(color: Colors.red),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status with Progress Bar
            Center(
              child: StatusProgressBar(status: permitData!['status']),
            ),
            SizedBox(height: 16),
            // Mountain, Guide Number, and Date in One Box
            buildCombinedDetailCard(
              context,
              title: "Permit Details",
              content: "Mountain: ${permitData!['mountain'] ?? 'Unknown'}\n"
                  "Guide: ${permitData!['guide'] ?? 'No guide specified'}\n"
                  "Date: ${permitData!['date'] ?? 'No date specified'}",
              icon: Icons.info_outline,

            ),
            SizedBox(height: 16),
            // Participants
            Text(
              "Participants",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            ...((permitData!['participants'] as List<dynamic>? ?? [])
                .map((participant) {
              final participantData =
              participant as Map<String, dynamic>;
              return Card(
                color: Color(0xFF333333),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participantData['name'] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.phone,
                              size: 20, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            participantData['phone'] ?? 'N/A',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.emergency,
                              size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            participantData['emergency'] ?? 'N/A',
                            style: TextStyle(fontSize: 16,  color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            })).toList(),
            // Add "Download E Permit" button if approved
            if (permitData!['status'] == 'approved') ...[
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ePermit()),
                    );
                  },
                  child: Text("Download E Permit"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF333333), // Button background color
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    foregroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),// Set text color here
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }


  Widget buildCombinedDetailCard(BuildContext context,
      {required String title, required String content, required IconData icon}) {
    return Card(
      color: Color(0xFF333333),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[400],
              child: Icon(
                icon,
                size: 30,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusProgressBar extends StatelessWidget {
  final String? status; // To define the current status

  StatusProgressBar({required this.status});

  @override
  Widget build(BuildContext context) {
    // Define icons and progress bar color based on status
    Color barColor = Colors.orange;
    Icon statusIcon = Icon(Icons.hourglass_empty, size: 30, color: Colors.orange);
    String statusText = "Pending";
    Icon secondIcon = Icon(Icons.check_circle_outline, size: 30, color: Colors.grey); // Default for pending

    if (status?.toLowerCase() == 'approved') {
      barColor = Colors.green;
      secondIcon = Icon(Icons.check_circle, size: 30, color: Colors.green); // Green for approved
      statusIcon = Icon(Icons.hourglass_empty, size: 30, color: Colors.green); // Pending icon remains
      statusText = "Approved";
    } else if (status?.toLowerCase() == 'rejected') {
      barColor = Colors.red;
      secondIcon = Icon(Icons.cancel, size: 30, color: Colors.red); // Red for rejected
      statusIcon = Icon(Icons.hourglass_empty, size: 30, color: Colors.red); // Pending icon remains
      statusText = "Rejected";
    }

    return Column(
      children: [
        // Icons with Progress Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            statusIcon, // Always pending icon
            SizedBox(width: 8),
            Container(
              height: 3,
              width: 60,
              color: barColor, // Progress bar color
            ),
            SizedBox(width: 8),
            secondIcon, // Changeable second icon (approved/rejected)
          ],
        ),
        SizedBox(height: 10),
        // Status Box
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: barColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: barColor,
            ),
          ),
        ),
      ],
    );
  }
}