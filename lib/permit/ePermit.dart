import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';

class ePermit extends StatelessWidget {
  const ePermit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: const PermitContent(),
    );
  }
}

Future<pw.ImageProvider?> loadImageFromAssets(String path) async {
  try {
    final ByteData bytes = await rootBundle.load(path);
    final Uint8List list = bytes.buffer.asUint8List();
    return pw.MemoryImage(list);
  } catch (e) {
    debugPrint("Error loading image from assets: $e");
    return null;
  }
}

class PermitContent extends StatefulWidget {
  const PermitContent({super.key});

  @override
  State<PermitContent> createState() => _PermitContentState();
}

class _PermitContentState extends State<PermitContent> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? permitData;
  String? siriNumber;

  @override
  void initState() {
    super.initState();
    fetchPermitData();
    fetchSiriNumber();
  }

  Future<void> fetchPermitData() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      final permitQuery = await _firestore
          .collection('permits')
          .doc(user.uid)
          .get();

      if (permitQuery.exists) {
        setState(() {
          permitData = permitQuery.data();
        });
      } else {
        throw Exception("No permit found for the user");
      }
    } catch (e) {
      setState(() {
        permitData = {'error': e.toString()};
      });
    }
  }

  Future<void> fetchSiriNumber() async {
    try {
      final userUID = FirebaseAuth.instance.currentUser!.uid; // Get the current user's UID

      // Fetch the document for the specific user UID
      final siriQuery = await FirebaseFirestore.instance
          .collection('siri_number')
          .where('user_uid', isEqualTo: userUID)
          .get();

      if (siriQuery.docs.isNotEmpty) {
        setState(() {
          siriNumber = siriQuery.docs.first.data()['siri_number'] ?? 'Unknown'; // Access siri_number field
        });
      } else {
        throw Exception("No Siri Number found for this user");
      }
    } catch (e) {
      setState(() {
        siriNumber = "Error: $e";
      });
    }
  }


  Future<void> generatePdf(BuildContext context) async {
    try {
      final pdf = pw.Document();
      final participants = permitData?['participants'] as List<dynamic>?;
      final String name = participants != null && participants.isNotEmpty
          ? participants.first['name'] ?? "Unknown"
          : "Unknown";
      final String mountain = permitData?['mountain'] ?? "Unknown";
      final String date = permitData?['date'] ?? "Unknown";
      final String guide = permitData?['guide'] ?? "Unknown";

      int participantCount = participants?.length ?? 0;
      final double totalAmount = participantCount * 5.0; // RM 5 per participant

      final Uint8List signatureImage = await _loadAssetImage("assets/signature.jpg");

      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text("KERAJAAN NEGERI SELANGOR",
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text("AKTA PERHUTANAN NEGARA 1984",
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text("BORANG 6",
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 16),
                  pw.Text("SELANGOR FORESTRY PERMIT",
                      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.Text("(SEKSYEN 47(3))", style: pw.TextStyle(fontSize: 12)),
                  pw.SizedBox(height: 16),
                  pw.Text("Siri No. $siriNumber", style: pw.TextStyle(fontSize: 20)),
                  pw.SizedBox(height: 16),
                  pw.Text("Guide No. $guide", style: pw.TextStyle(fontSize: 16)),
                  pw.Text("Name: $name", style: pw.TextStyle(fontSize: 14)),
                  pw.Text("Mountain: $mountain", style: pw.TextStyle(fontSize: 14)),
                  pw.SizedBox(height: 16),
                  pw.Text(
                    "This permit is valid from $date.",
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("Participants: $participantCount", style: pw.TextStyle(fontSize: 14)),
                        pw.Text("RM${totalAmount.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 16),
                  if (signatureImage != null)
                    pw.Image(pw.MemoryImage(signatureImage), height: 100, width: 200)
                  else
                    pw.Text("Signature not available", style: pw.TextStyle(fontSize: 14)),
                ],
              ),
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();

      await Printing.sharePdf(bytes: pdfBytes, filename: "permit.pdf");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    }
  }
  Future<Uint8List> _loadAssetImage(String path) async {
    try {
      final ByteData data = await rootBundle.load(path);
      return data.buffer.asUint8List();
    } catch (e) {
      print("Error loading image: $e");
      return Uint8List(
          0); // Return an empty Uint8List if the image is not found
    }
  }

  @override
  Widget build(BuildContext context) {
    if (permitData == null || siriNumber == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (permitData?['error'] != null || siriNumber == "Error") {
      return Center(child: Text('Error: ${permitData?['error'] ?? siriNumber}'));
    }

    final participants = permitData?['participants'] as List<dynamic>?;

    final String name = participants != null && participants.isNotEmpty
        ? participants.first['name'] ?? "Unknown"
        : "Unknown";
    final String mountain = permitData?['mountain'] ?? "Unknown";
    final String date = permitData?['date'] ?? "Unknown";
    final String guide = permitData?['guide'] ?? "Unknown";

    int participantCount = participants?.length ?? 0;
    final double totalAmount = participantCount * 5.0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "KERAJAAN NEGERI SELANGOR",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                "AKTA PERHUTANAN NEGARA 1984",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                "BORANG 6",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "SELANGOR FORESTRY PERMIT",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                "(SEKSYEN 47(3))",
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Siri No. $siriNumber",
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text("Guide No. $guide", style: TextStyle(fontSize: 16)),
              Text(
                "Name: $name",
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              Text(
                "Mountain: $mountain",
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  text: "This permit is valid from ",
                  style: const TextStyle(fontSize: 14),
                  children: [
                    TextSpan(
                      text: "$date",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ".",
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Participants: $participantCount", style: TextStyle(fontSize: 14)),
                    Text("RM${totalAmount.toStringAsFixed(2)}", style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Image.asset(
                "assets/signature.jpg",
                height: 100, // Adjust height as needed
                width: 200,  // Adjust width as needed
                errorBuilder: (context, error, stackTrace) {
                  return const Text("Signature not available");
                },
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => generatePdf(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Download'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}