import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myforestnew/Pages/Login.dart';
import 'package:myforestnew/Pages/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  bool notificationsEnabled = false;
  bool locationEnabled = false;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    cityController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<void> savePersonalInfo() async {
    try {
      // Now get the current user
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw 'User is not logged in';
      }

      String userId = user.uid;

      // Save personal information
      await FirebaseFirestore.instance.collection('profile').doc(userId).set({
        'first_name': firstNameController.text,
        'last_name': lastNameController.text,
        'email': emailController.text,
        'age': ageController.text,
        'city': cityController.text,
        'notifications_enabled': notificationsEnabled,
        'location_enabled': locationEnabled,
        'updated_at': Timestamp.now(),
      });

      // Show the confirmation dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xFF2C2C2C),
            title: Text(
              'Profile Updated',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Your profile has been successfully updated.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      // Clear the input fields
      firstNameController.clear();
      lastNameController.clear();
      emailController.clear();
      ageController.clear();
      cityController.clear();

      setState(() {
        notificationsEnabled = false;
        locationEnabled = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save information: $e')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F1F1F),
      appBar: AppBar(
        backgroundColor: Color(0xFF1F1F1F),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildTextField('First Name', firstNameController),
            SizedBox(height: 16),
            _buildTextField('Last Name', lastNameController),
            SizedBox(height: 16),
            _buildTextField('Email', emailController),
            SizedBox(height: 16),
            _buildTextField('Age', ageController, keyboardType: TextInputType.number),
            SizedBox(height: 32),
            Text(
              'Location',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildTextField('City', cityController),
            SizedBox(height: 32),

            Text(
              'Privacy',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildSwitch('Notifications', notificationsEnabled, (value) {
              setState(() {
                notificationsEnabled = value;
              });
            }),
            _buildSwitch('Turn On Location', locationEnabled, (value) {
              setState(() {
                locationEnabled = value;
              });
            }),
            SizedBox(height: 32),

            Text(
              'Account',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildPressableArrowSection('Account', 'Log Out Account', context, onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            }),
            SizedBox(height: 32),
            _buildSaveButtonAlignedRight(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      cursorColor: Colors.white,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildPressableArrowSection(String sectionTitle, String optionText, BuildContext context, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {}, // Use the provided onTap function or do nothing by default
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              optionText,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }


  Widget _buildSaveButtonAlignedRight() {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: savePersonalInfo,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: Text(
          'Save',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
    );
  }
}