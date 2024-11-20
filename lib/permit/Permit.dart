import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Resources/permit_methods.dart';

class Permit extends StatefulWidget {
  @override
  _PermitApplicationFormState createState() => _PermitApplicationFormState();
}

class _PermitApplicationFormState extends State<Permit> {
  String selectedMountain = 'Mount Nuang';
  int numberOfParticipants = 1;
  DateTimeRange? selectedDateRange;
  List<Map<String, String>> participants = [];
  String guideNo = ''; // Variable to hold the guide number
  final PermitMethods _permitMethods = PermitMethods();
  late String mountain;
  late String guide;
  late String date;
  late String participantsNo;
  late String name;
  late String phoneNo;
  late String emergencyNo;

  final List<String> mountains = [
    'Mount Nuang',
    'Mount Hitam',
    'Bukit Lagong',
    'Bukit Pau',
    'Bukit Sri Bintang',
  ];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    participants = List.generate(numberOfParticipants, (index) => {
      "name": "",
      "phone": "",
      "emergency": ""
    });
  }

  void updateParticipants(int count) {
    setState(() {
      numberOfParticipants = count;
      participants = List.generate(
          count, (index) => {"name": "", "phone": "", "emergency": ""});
    });
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.white, // Header background color
              onPrimary: Colors.black, // Header text color
              surface: Colors.black, // Background of the calendar
              onSurface: Colors.white, // Text color of the days
            ),
            dialogBackgroundColor: Colors.black,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
    }
  }

  InputDecoration _buildRoundedInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white),
      filled: true,
      fillColor: Colors.black,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7.0), // More rounded corners
        borderSide: BorderSide(color: Colors.white), // White border
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7.0),
        borderSide: BorderSide(
            color: Colors.white, width: 2.0), // Blue border when focused
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // White back arrow
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Permit Application Form',
            style: TextStyle(
              fontSize: 19,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mountain Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedMountain,
                        dropdownColor: Colors.black,
                        decoration: _buildRoundedInputDecoration('Mountain/Hill'),
                        items: mountains.map((String mountain) {
                          return DropdownMenuItem<String>(
                            value: mountain,
                            child: Text(mountain,
                                style: TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedMountain = newValue!;
                          });
                        },
                      ),

                      SizedBox(height: 8), // Smaller space below the dropdown

                      // Guide No field (conditional)
                      if (selectedMountain.contains('Mount')) // Show only for mountains
                        TextFormField(
                          decoration: _buildRoundedInputDecoration('Guide No'),
                          style: TextStyle(color: Colors.white),
                          onChanged: (value) {
                            guideNo = value; // Update guide number
                          },
                        ),

                      SizedBox(height: 16), // Space before the date range

                      // Date Range Picker
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: _buildRoundedInputDecoration('From:'),
                              readOnly: true,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              controller: TextEditingController(
                                  text: selectedDateRange != null
                                      ? "${selectedDateRange?.start.toString().split(' ')[0]}"
                                      : ''),
                              onTap: _selectDateRange,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              decoration: _buildRoundedInputDecoration('To:'),
                              readOnly: true,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              controller: TextEditingController(
                                  text: selectedDateRange != null
                                      ? "${selectedDateRange?.end.toString().split(' ')[0]}"
                                      : ''),
                              onTap: _selectDateRange,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),

                      // Number of Participants
                      DropdownButtonFormField<int>(
                        value: numberOfParticipants,
                        dropdownColor: Colors.black,
                        decoration: _buildRoundedInputDecoration('No. of Participants'),
                        items: List.generate(10, (index) => index + 1).map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString(),
                                style: TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          updateParticipants(newValue!);
                        },
                      ),

                      SizedBox(height: 16),

                      // Participants Details
                      Text('Participants Details',
                          style: TextStyle(color: Colors.white)),
                      SizedBox(height: 16), // Added space between label and input box
                      for (int i = 0; i < numberOfParticipants; i++)
                        Column(
                          children: [
                            TextFormField(
                              decoration: _buildRoundedInputDecoration('Full Name'),
                              style: TextStyle(color: Colors.white),
                              onChanged: (value) {
                                participants[i]["name"] = value;
                              },
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    decoration: _buildRoundedInputDecoration('Phone Number'),
                                    style: TextStyle(color: Colors.white),
                                    onChanged: (value) {
                                      participants[i]["phone"] = value;
                                    },
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    decoration: _buildRoundedInputDecoration('Emergency Number'),
                                    style: TextStyle(color: Colors.white),
                                    onChanged: (value) {
                                      participants[i]["emergency"] = value;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                          ],
                        ),

                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),

            // Submit Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () async{
                  if (_formKey.currentState!.validate()) {
                    final String startDate = selectedDateRange != null
                        ? selectedDateRange!.start.toString().split(' ')[0]
                        : '';
                    final String endDate = selectedDateRange != null
                        ? selectedDateRange!.end.toString().split(' ')[0]
                        : '';

                    String response = await _permitMethods.permitUser(
                      mountain: selectedMountain,
                      guide: guideNo.isNotEmpty ? guideNo : "No guide specified",
                      date: '$startDate to $endDate',
                      participantsNo: numberOfParticipants.toString(),
                      participants: participants, // Pass the participants list
                    );

                    // Show a confirmation or error message
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response)));
                  }
                },
                child: Text('Submit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // White background for button
                  foregroundColor: Colors.black, // Black text on button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25), // More rounded button
                  ),
                  minimumSize: Size(double.infinity, 50), // Full width button
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


