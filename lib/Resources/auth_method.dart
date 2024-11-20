import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:myforestnew/Pages/SignUp.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //sign up user
  Future<String> signUpUser ({
    required String email,
    required String password,
    //required String username,
  }) async {
    String res = "Some error occured";
    try {
      if(email.isNotEmpty || password.isNotEmpty ) {
        //register user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);

        print(cred.user!.uid);
        //add user to database
        _firestore.collection('users').doc(cred.user!.uid).set({
          //'username': username,
          'uid': cred.user!.uid,
          'email': email,
          'role': "user"
        });
        res = "success";
      }
    } catch(err) {
      res = err.toString();
    }
    return res;
  }

  // logging in user
  Future<String> loginUser ({
    required String email,
    required String password,
  }) async {
    String res = "Some error occured";

    try {
      if(email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      // Get the currently logged-in user
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Fetch user data from Firestore
        DocumentSnapshot userDoc = await _firestore
            .collection('users') // Replace with your Firestore collection name
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          return userDoc.data() as Map<String, dynamic>; // Return user data as a map
        } else {
          print("User document does not exist.");
          return null; // User document doesn't exist
        }
      } else {
        print("No user logged in.");
        return null; // No user logged in
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null; // Return null on error
    }
  }
}
