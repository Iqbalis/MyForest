import 'package:flutter/material.dart';
import 'package:myforestnew/Pages/ForgetPass.dart';
import 'package:myforestnew/Pages/HomPage.dart';
import 'package:myforestnew/Resources/auth_method.dart';
import 'package:myforestnew/Resources/utils.dart';
import 'package:myforestnew/Widgets/text_field_input.dart';

class AdminLoginPage extends StatefulWidget {

  @override
  State<AdminLoginPage> createState() => __LogininScreenState();
}

class __LogininScreenState extends State<AdminLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void loginUser() async{
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().loginUser(
        email: _emailController.text,
        password: _passwordController.text
    );

    if(res == "success") {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } else {
      //
      showSnackBar(res, context);

    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F1F1F), // Background color to match the design
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tree icon or logo (placeholder for now)
            Center(
              child: Image.asset(
                'assets/myforestlogo.png',
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
              'Admin',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 40),
            // Email input field
            TextFieldInput(
              hintText: 'Admin Email',
              textInputType: TextInputType.text,
              textEditingController: _emailController,
            ),
            SizedBox(height: 20),
            // Password input field
            TextFieldInput(
              hintText: 'Password',
              textInputType: TextInputType.text,
              textEditingController: _passwordController,
            ),
            SizedBox(height: 10),
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
            SizedBox(height: 30),
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
          ],
        ),
      ),
    );
  }
}