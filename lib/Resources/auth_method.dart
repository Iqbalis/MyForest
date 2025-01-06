import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign up user with role
  Future<String> signUpUser({
    required String email,
    required String password,
    required String role, // Add role as a parameter (e.g., 'admin', 'user')
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty && role.isNotEmpty) {
        // Register user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Add user to database with role
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'uid': cred.user!.uid,
          'email': email,
          'role': role, // Store role in Firestore
        });
        res = "success";
      } else {
        res = "Please fill in all fields";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Logging in user with role validation
  Future<Map<String, String>> loginUser({required String email, required String password}) async {
    try {
      // Try to login with Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;

      // Get the user's role from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        String role = userDoc.get('role') ?? 'user'; // Default to user if role not set
        return {'status': 'success', 'role': role};
      } else {
        return {'status': 'failed', 'message': 'User not found'};
      }
    } catch (e) {
      return {'status': 'failed', 'message': e.toString()};
    }
  }
}