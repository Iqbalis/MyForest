import 'package:flutter/material.dart';
import 'package:myforestnew/Admin/homeadmin.dart';
import 'package:myforestnew/Pages/ForgetPass.dart';
import 'package:myforestnew/Resources/auth_method.dart';
import 'package:myforestnew/Resources/utils.dart';
import 'package:myforestnew/Widgets/text_field_input.dart';

class AdminLoginPage extends StatefulWidget {
  @override
  State<AdminLoginPage> createState() => __LoginScreenState();
}

class __LoginScreenState extends State<AdminLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;  // Add loading state to handle the loading indicator

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;  // Set loading state to true when login begins
    });

    // Call AuthMethods and get user role validation
    Map<String, String> res = await AuthMethods().loginUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (res['status'] == 'success') {
      // Ensure the role is admin
      if (res['role'] == 'admin') {
        // Navigate to the admin dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeAdmin(), // Or Admin Dashboard page
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
      _isLoading = false;  // Set loading state to false after login process
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F), // Background color to match the design
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tree icon or logo
            Center(
              child: Image.asset(
                'assets/myforestlogo.png',
                height: 150,
              ),
            ),
            const SizedBox(height: 20),
            // Title
            const Text(
              'MyForest',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Admin',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 40),
            // Email input field
            TextFieldInput(
              hintText: 'Admin Email',
              textInputType: TextInputType.emailAddress,
              textEditingController: _emailController,
            ),
            const SizedBox(height: 20),
            // Password input field
            TextFieldInput(
              hintText: 'Password',
              textInputType: TextInputType.visiblePassword,
              textEditingController: _passwordController,
              isPassword: true,
              obscureText: true,
            ),
            const SizedBox(height: 0),
            // Forgot password link
            Padding(
              padding: const EdgeInsets.only(right: 190.0),
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
            const SizedBox(height: 30),
            // Login button with a loading indicator
            ElevatedButton(
              onPressed: _isLoading ? null : loginUser,  // Disable button when loading
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
                backgroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : const Icon(
                Icons.arrow_forward,
                color: Colors.black,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}