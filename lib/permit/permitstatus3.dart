import 'package:flutter/material.dart';
import 'package:myforestnew/permit/paymentGateway.dart';

class Permitstatus3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: PermitApplicationScreen(),
    );
  }
}

class PermitApplicationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permit Application Status'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Navigates back when pressed
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  StepIndicator(),
                  SizedBox(height: 20),
                  StatusBox(), // First box "In Queue"
                ],
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Application Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ApplicationDetails(), // Second box
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PaymentGatewayScreen()), // Example action
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Downloading E-Permit...')),
            );
          },
          child: Container(
            height: 60, // Fixed height for the rounded box
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Download E-Permit',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.black,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
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
        Container(width: 50, height: 2, color: Colors.grey[800]),
        SizedBox(width: 10),
        CircleAvatar(
          radius: 15,
          backgroundColor: Colors.grey[800],
          child: Text(
            '2',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class StatusBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300, // Fixed width for consistency
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            'Application Completed',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Permit Approved !',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 10),
          Text(
            'Download your E-permit below',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          Text('Date: 14/8/2024'),
          Text('Time: 2:00 P.M'),
        ],
      ),
    );
  }
}

class ApplicationDetails extends StatelessWidget {
  final List<Map<String, String>> participants = [
    {
      'name': 'Adib Said',
      'phone': '019-5617286',
      'emergency': '019-5617287',
    },
    {
      'name': 'Hanif Kamal',
      'phone': '019-5617286',
      'emergency': '019-5617287',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300, // Same fixed width as StatusBox for consistency
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mount: Mount Nuang'),
          Text('Date: 15/8/2024 to 16/8/2024'),
          Text('No. of Participants: 5'),
          Divider(color: Colors.grey),
          ...participants.map((participant) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Full Name: ${participant['name']}'),
                Text('Phone Number: ${participant['phone']}'),
                Text('Emergency Number: ${participant['emergency']}'),
                SizedBox(height: 10),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}
