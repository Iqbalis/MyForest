import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myforestnew/Admin/AdminLogin.dart';
import 'package:myforestnew/Pages/ForgetPass.dart';
import 'package:myforestnew/Pages/GetStarted.dart';
import 'package:myforestnew/Pages/HomPage.dart';
import 'package:myforestnew/Pages/SignUp.dart';
import 'package:myforestnew/Resources/auth_method.dart';
import 'package:myforestnew/Resources/utils.dart';
import 'package:myforestnew/Widgets/text_field_input.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => __LogininScreenState();
}

class __LogininScreenState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });

    // Call AuthMethods and get user role validation
    Map<String, String> res = await AuthMethods().loginUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (res['status'] == 'success') {
      // Ensure the role is admin
      if (res['role'] == 'user') {
        // Navigate to the admin dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomePage(), // Or Admin Dashboard page
          ),
        );
      } else {
        // Show error if role is not admin
        showSnackBar("Access denied! Only admins can log in.", context);
      }
    } else {
      // Show any other errors
      showSnackBar(res['message'] ?? "Login failed", context);
    }

    setState(() {
      _isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F), // Background color
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey[850],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/myforestlogo.png',
                    height: 120,
                  ),
                ],
              ),
            ),
            ListTile(
              tileColor: Colors.grey[850],
              leading: const Icon(
                Icons.explore,
                color: Colors.white,
              ),
              title: const Text(
                'Get Started',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Getstarted(),
                  ),
                );
              },
            ),
            ListTile(
              tileColor: Colors.grey[850],
              leading: const Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
              ),
              title: const Text(
                'Admin Login',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AdminLoginPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    'assets/myforestlogo.png',
                    height: 150,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'MyForest',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 50),
                TextFieldInput(
                  hintText: 'Email',
                  textInputType: TextInputType.text,
                  textEditingController: _emailController,
                ),
                const SizedBox(height: 20),
                TextFieldInput(
                  hintText: 'Password',
                  textInputType: TextInputType.text,
                  textEditingController: _passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ForgetPass(),
                        ),
                      );
                    },
                    child: const Text(
                      'Forget Password?',
                      style: TextStyle(color: Colors.lightBlueAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _isLoading
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : ElevatedButton(
                  onPressed: loginUser,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    backgroundColor: Colors.white,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  "Don't have an account?",
                  style: TextStyle(color: Colors.white70),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SignUp(),
                      ),
                    );
                  },
                  child: const Text(
                    'Sign up now',
                    style: TextStyle(color: Colors.lightBlueAccent),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}