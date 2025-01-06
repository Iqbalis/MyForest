import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts package
import 'Pages/GetStarted.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyDtzAzFTUjBM_3B2REU-NhTjVmancwpktQ",
            authDomain: "myforest-2e3f5.firebaseapp.com",
            projectId: "myforest-2e3f5",
            storageBucket: "myforest-2e3f5.firebasestorage.app",
            messagingSenderId: "908621397767",
            appId: "1:908621397767:web:1780638bcbd27c45c58fa2"));
  } else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Getstarted(), // Replace with your initial screen
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.karlaTextTheme(
          Theme.of(context).textTheme, // Apply OpenSans to all text styles
        ),
      ),
    );
  }
}