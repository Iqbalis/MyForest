import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PermitMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> permitUser ({
    required String mountain,
    required String guide,
    required String date,
    required String participantsNo,
    required List<Map<String, String>> participants,
  }) async {
    String res = "Some error occured";
    try {
      if(mountain.isNotEmpty &&
          guide.isNotEmpty &&
          date.isNotEmpty &&
          participantsNo.isNotEmpty &&
          participants.isNotEmpty) {

        await _firestore.collection('permits').doc(_auth.currentUser!.uid).set({
          'mountain': mountain,
          'guide': guide,
          'date': date,
          'participantsNo': participantsNo,
          'participants': participants,
          'approved': false,
        });
        res = "Permit application submitted successfully";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}