import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class detailApplication extends StatelessWidget {
  final String documentId; // Pass the document ID from the previous screen

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
      appBar: AppBar(
        title: Text("Mountain Trip Details"),
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
                style: TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(
                "No data available",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final data = snapshot.data!;
          final participants = data['participants'] as List<dynamic>? ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Mountain Name
                Text(
                  'Name of Mountain:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  data['mountain'] ?? 'Unknown Mountain',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                // Guide Number
                Text(
                  'Guide Number:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  data['guide'] ?? 'No guide specified',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                // Date
                Text(
                  'Date:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  data['date'] ?? 'No date specified',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                // Participants
                Text(
                  'Participants:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 8),
                ...participants.map((participant) {
                  final participantData = participant as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name: ${participantData['name'] ?? 'Unknown'}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Phone: ${participantData['phone'] ?? 'N/A'}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Emergency Contact: ${participantData['emergency'] ?? 'N/A'}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}