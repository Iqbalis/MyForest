import 'package:flutter/material.dart';
import 'package:myforestnew/Pages/ForgetPass.dart';
import 'package:myforestnew/Pages/GetStarted.dart';
import 'package:myforestnew/Pages/HomPage.dart';
import 'package:myforestnew/Pages/SignUp.dart';
import 'package:myforestnew/Resources/auth_method.dart';
import 'package:myforestnew/Resources/utils.dart';
import 'package:myforestnew/Widgets/text_field_input.dart';

import '../Admin/AdminLogin.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => __LogininScreenState();
}

class __LogininScreenState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

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
    String res = await AuthMethods().loginUser(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (res == "success") {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } else {
      showSnackBar(res, context);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background color
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey[850], // Set the drawer background to grey
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/myforestlogo.jpg',
                    height: 120,
                  ),
                ],
              ),
            ),
            ListTile(
              tileColor: Colors.grey[850], // Background color of the tile
              leading: Icon(
                Icons.explore,
                color: Colors.white, // Icon color
              ),
              title: Text(
                'Get Started',
                style: TextStyle(color: Colors.white), // Text color
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
              tileColor: Colors.grey[850], // Background color of the tile
              leading: Icon(
                Icons.admin_panel_settings,
                color: Colors.white, // Icon color
              ),
              title: Text(
                'Admin Login',
                style: TextStyle(color: Colors.white), // Text color
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
                SizedBox(height: 20), // Add spacing from the top
                // Tree icon or logo
                Center(
                  child: Image.asset(
                    'assets/myforestlogo.jpg',
                    height: 150,
                  ),
                ),
                SizedBox(height: 20),
                // Title
                Text(
                  'MyForest',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 50),
                // Email input field
                TextFieldInput(
                  hintText: 'Email',
                  textInputType: TextInputType.text,
                  textEditingController: _emailController,
                ),
                SizedBox(height: 20),
                // Password input field
                TextFieldInput(
                  hintText: 'Password',
                  textInputType: TextInputType.text,
                  textEditingController: _passwordController,
                  obscureText: true,
                ),
                SizedBox(height: 0),
                // Forgot password link
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
                    child: Text(
                      'Forget Password?',
                      style: TextStyle(color: Colors.lightBlueAccent),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Login button (arrow icon)
                ElevatedButton(
                  onPressed: loginUser,
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                    backgroundColor: Colors.white,
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
                SizedBox(height: 40),
                // Signup prompt
                Text(
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
                  child: Text(
                    'Sign up now',
                    style: TextStyle(color: Colors.lightBlueAccent),
                  ),
                ),
                SizedBox(height: 20), // Spacing for scrollable content
              ],
            ),
          ),
        ),
      ),
    );
  }
}