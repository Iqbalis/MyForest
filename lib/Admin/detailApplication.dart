import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class detailApplication extends StatelessWidget {
  final String documentId;

  detailApplication({required this.documentId});

  Future<Map<String, dynamic>> fetchPermitDetails() async {
    try {
      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('permits')
          .doc(documentId)
          .get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        throw Exception("Document does not exist");
      }
    } catch (e) {
      throw Exception("Error fetching permit details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Application Details"),
        backgroundColor: Colors.black87,
        iconTheme: IconThemeData(
          color: Colors.white, // Set the back button color to white
        ),
        titleTextStyle: TextStyle(
          color: Colors.white, // Set the title text color to white
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchPermitDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(
                "No data available",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final data = snapshot.data!;
          final participants = data['participants'] as List<dynamic>? ?? [];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mountain Name
                  buildDetailCard(
                    context,
                    title: "Mountain Name",
                    content: data['mountain'] ?? 'Unknown Mountain',
                    icon: Icons.terrain,
                  ),
                  SizedBox(height: 16),
                  // Guide Number
                  buildDetailCard(
                    context,
                    title: "Guide Number",
                    content: data['guide'] ?? 'No guide specified',
                    icon: Icons.person_outline,
                  ),
                  SizedBox(height: 16),
                  // Date
                  buildDetailCard(
                    context,
                    title: "Date",
                    content: data['date'] ?? 'No date specified',
                    icon: Icons.calendar_today,
                  ),
                  SizedBox(height: 16),
                  // Participants
                  Text(
                    "Participants",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  ...participants.map((participant) {
                    final participantData = participant as Map<String, dynamic>;
                    return Card(
                      color: Colors.white,
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
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.phone, size: 20, color: Colors.grey[800]),
                                SizedBox(width: 8),
                                Text(
                                  participantData['phone'] ?? 'N/A',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.contact_phone, size: 20, color: Colors.grey[800]),
                                SizedBox(width: 8),
                                Text(
                                  participantData['emergency'] ?? 'N/A',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildDetailCard(BuildContext context,
      {required String title, required String content, required IconData icon}) {
    return Card(
      color: Colors.white,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
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