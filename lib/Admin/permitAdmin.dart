import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myforestnew/Admin/ApprovalPage.dart';
import 'package:myforestnew/Resources/permit_method.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class PermitAdmin extends StatefulWidget {
  @override
  _PermitAdminState createState() => _PermitAdminState();
}

class _PermitAdminState extends State<PermitAdmin> {
  final TextEditingController _dateController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final PermitMethods _permitMethods = PermitMethods();

  String? _selectedMountain;
  final TextEditingController _guideNumberController = TextEditingController();
  List<Map<String, TextEditingController>> _participants = [];

  final List<String> _mountains = [
    "Mount Nuang",
    "Mount Hitam",
    "Bukit Lagong",
    "Bukit Pau"
  ];

  @override
  void initState() {
    super.initState();
    _addParticipant();
  }

  void _addParticipant() {
    setState(() {
      _participants.add({
        'name': TextEditingController(),
        'phone': TextEditingController(),
        'emergency': TextEditingController(),
      });
    });
  }

  void _removeParticipant(int index) {
    setState(() {
      _participants.removeAt(index);
    });
  }
  final userUID = FirebaseAuth.instance.currentUser!.uid;
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      print("Form is valid, submitting...");

      final String date = _dateController.text.trim();
      final String mountain = _selectedMountain!;
      final String guide = _guideNumberController.text.trim();

      List<Map<String, String>> participantData = _participants.map((p) {
        return {
          'name': p['name']!.text.trim(),
          'phone': p['phone']!.text.trim(),
          'emergency': p['emergency']!.text.trim(),
        };
      }).toList();

      String response = await _permitMethods.permitUser(
        mountain: mountain,
        guide: guide.isNotEmpty ? guide : "No guide specified",
        date: date,
        participantsNo: participantData.length.toString(),
        participants: participantData,
      );

      print("Response from API: $response");

      // Generate a new serial number
      String newSiriNumber = (Random().nextInt(90000) + 10000).toString();

      print("Generated Serial Number: $newSiriNumber");

      try {
        final userUID = FirebaseAuth.instance.currentUser!.uid;

        // Check if a document already exists for this user
        final docSnapshot = await FirebaseFirestore.instance
            .collection('siri_number')
            .doc(userUID)
            .get();

        if (docSnapshot.exists) {
          // Delete the existing document
          await FirebaseFirestore.instance
              .collection('siri_number')
              .doc(userUID)
              .delete();

          print("Deleted old No Siri document for user: $userUID");
        }

        // Save the new serial number
        await FirebaseFirestore.instance.collection('siri_number').doc(userUID).set({
          'user_uid': userUID,
          'siri_number': newSiriNumber,
          'timestamp': FieldValue.serverTimestamp(),
        });

        print("New serial number saved to Firestore successfully.");
      } catch (e) {
        print("Error saving to Firestore: $e");
      }

      _showSubmissionPopup();
      _resetForm();
    } else {
      print("Form validation failed");
    }
  }



  void _showSubmissionPopup() {
    Future.delayed(Duration(milliseconds: 200), () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xFF333333), // Background color of the dialog
            titleTextStyle: TextStyle(
              color: Colors.white, // Title text color
              fontWeight: FontWeight.bold, // Optional: Make the title bold
            ),
            contentTextStyle: TextStyle(
              color: Colors.white, // Content text color
            ),
            title: Text('Submission Successful'),
            content: Text('Your application has been submitted successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white, // Text color of the button
                  backgroundColor: Color(0xFF555555), // Background color of the button
                ),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }



  void _resetForm() {
    setState(() {
      _dateController.clear();
      _guideNumberController.clear();
      _selectedMountain = null;

      for (var participant in _participants) {
        participant['name']!.clear();
        participant['phone']!.clear();
        participant['emergency']!.clear();
      }
      _participants = [];
      _addParticipant();
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    _guideNumberController.dispose();
    for (var participant in _participants) {
      participant['name']!.dispose();
      participant['phone']!.dispose();
      participant['emergency']!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F1F1F),
      appBar: AppBar(
        title: Text("Permit Form"),
        backgroundColor: Color(0xFF1F1F1F),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PermitsListPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25), // Rounded corners
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text('Permit List'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Name of Mountain',
                    labelStyle: TextStyle(fontSize: 16, color: Colors.white),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white), // White border on focus
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey), // Grey border when not focused
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  dropdownColor: Color(0xFF333333),
                  items: _mountains.map((mountain) {
                    return DropdownMenuItem<String>(
                      value: mountain,
                      child: Text(
                        mountain,
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMountain = value;
                    });
                  },
                  value: _selectedMountain,
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
                ),
              ),
              if (_selectedMountain != null &&
                  _selectedMountain!.startsWith("Mount"))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    cursorColor: Colors.white,
                    controller: _guideNumberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Guide Number',
                      labelStyle: TextStyle(color: Colors.white),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // White border on focus
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey), // Grey border when not focused
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
                  ),
                ),
              SizedBox(height: 8),
              TextFormField(
                cursorColor: Colors.white,
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Date',
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // White border on focus
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey), // Grey border when not focused
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                onTap: () async {
                  DateTimeRange? pickedRange = await showDateRangePicker(
                    context: context,
                    initialDateRange: DateTimeRange(
                      start: DateTime.now(),
                      end: DateTime.now(),
                    ),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: ThemeData(
                          colorScheme: ColorScheme.light(
                            primary: Color(0xFF81b1ce), // Selected date's background color
                            onPrimary: Colors.white, // Text color for selected date
                            surface:  Color(0xFF1F1F1F), // Background color of the calendar
                            onSurface: Colors.white,
                            secondary: Colors.white30,// Text color for unselected dates
                          ),
                          textTheme: TextTheme(
                            bodyLarge: TextStyle(color: Colors.white), // Default text color for the calendar
                          ),
                          buttonTheme: ButtonThemeData(
                            buttonColor: Colors.blue, // Button background color
                            textTheme: ButtonTextTheme.primary, // Button text color
                          ),
                        ),
                        child: child!, // Apply the custom theme
                      );
                    },
                  );

                  if (pickedRange != null) {
                    _dateController.text =
                    "${pickedRange.start.toLocal().toIso8601String().split('T')[0]} - ${pickedRange.end.toLocal().toIso8601String().split('T')[0]}";
                  }
                },



                readOnly: true,
                validator: (value) =>
                value == null || value.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              Text(
                'Participants',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              ..._participants.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, TextEditingController> participant = entry.value;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: Color(0xFF333333),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: participant['name'],
                          cursorColor: Colors.white, // Change the cursor color to white
                          decoration: InputDecoration(
                            labelText: 'Name',
                            labelStyle: TextStyle(color: Colors.white),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white), // White border on focus
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey), // Grey border when not focused
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          style: TextStyle(color: Colors.white), // Text color
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          cursorColor: Colors.white,
                          controller: participant['phone'],
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: TextStyle(color: Colors.white),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white), // White border on focus
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey), // Grey border when not focused
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                          validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          cursorColor: Colors.white,
                          controller: participant['emergency'],
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Emergency Contact Number',
                            labelStyle: TextStyle(color: Colors.white),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white), // White border on focus
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey), // Grey border when not focused
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                          validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                        ),
                        SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => _removeParticipant(index),
                            icon: Icon(Icons.delete, color: Colors.red),
                            label: Text(
                              "Remove",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // Align buttons at the center
                children: [
                  ElevatedButton(
                    onPressed: _addParticipant,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero, // Remove the default padding around the button
                      backgroundColor: Color(0xFF333333), // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Optional: Adjust border radius for rounded corners
                      ),
                      fixedSize: Size(140, 50), // Set fixed width and height for the button
                    ),
                    child: Icon(
                      Icons.add,
                      size: 20, // Icon size, adjust as needed
                      color: Colors.white, // Icon color
                    ),
                  ),
                  SizedBox(width: 16), // Add some space between the buttons
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero, // Remove the default padding around the button
                      backgroundColor: Colors.white, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Optional: Adjust border radius for rounded corners
                      ),
                      fixedSize: Size(140, 50), // Set fixed width and height for the button
                    ),
                    child: Text(
                      'Submit', // Text you want to show on the button
                      style: TextStyle(
                        fontSize: 16, // Text size
                        color: Colors.black, // Text color
                        fontWeight: FontWeight.bold, // Optional: Set font weight to bold
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 82),
            ],
          ),
        ),
      ),
    );
  }
}