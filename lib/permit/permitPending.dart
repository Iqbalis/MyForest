import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myforestnew/Pages/profile.dart';

class permitStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: PermitApplicationScreen(),
    );
  }
}

class PermitApplicationScreen extends StatefulWidget {
  @override
  _PermitApplicationScreenState createState() =>
      _PermitApplicationScreenState();
}

class _PermitApplicationScreenState extends State<PermitApplicationScreen> {
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
      appBar: AppBar(
        title: Text('Permit Application Status'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: permitData == null
            ? Center(child: CircularProgressIndicator())
            : permitData!.containsKey('error')
            ? Text(
          'Error: ${permitData!['error']}',
          style: TextStyle(color: Colors.red),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StepIndicator(), // Top indicator
            SizedBox(height: 20),
            Align(
              alignment: Alignment.topCenter,
              child: StatusBox(
                status: permitData!['status'] == "approved"
                    ? 'Approved'
                    : permitData!['status'] == "rejected"
                    ? 'Rejected'
                    : 'Pending',
                date: permitData!['date'],
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.topCenter,
              child: ApplicationDetails(
                mountain: permitData!['mountain'],
                date: permitData!['date'],
                guide: permitData!['guide'],
                participants: permitData!['participants'],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusBox extends StatelessWidget {
  final String status;
  final String date;

  StatusBox({required this.status, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            status,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Date: $date',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class StepIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: Colors.grey[800],
          child: Text(
            '1',
            style: TextStyle(color: Colors.white),
          ),
        ),
        SizedBox(width: 10),
        Container(width: 50, height: 2, color: Colors.grey),
        SizedBox(width: 10),
        CircleAvatar(
          radius: 15,
          backgroundColor: Colors.grey,
          child: Text(
            '2',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class ApplicationDetails extends StatelessWidget {
  final String mountain;
  final String date;
  final String guide;
  final List<dynamic> participants;

  ApplicationDetails({
    required this.mountain,
    required this.guide,
    required this.date,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Mount: $mountain',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            'Guide Number : $guide',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            'Date: $date',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 5),
          Text(
            'No. of Participants: ${participants.length}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          Divider(color: Colors.grey),
          SizedBox(height: 5),
          ...participants.map((participant) {
            final participantData = participant as Map<String, dynamic>;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Full Name: ',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                      ),
                      TextSpan(
                        text: participantData['name'],
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Phone Number: ',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                      ),
                      TextSpan(
                        text: participantData['phone'],
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Emergency Number: ',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                      ),
                      TextSpan(
                        text: participantData['emergency'],
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
              ],
            );
          }).toList(),
          Divider(color: Colors.grey),
          SizedBox(height: 5),
        ],
      ),
    );
  }
}