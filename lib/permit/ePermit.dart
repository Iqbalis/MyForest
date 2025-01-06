import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:math';
import 'dart:typed_data';

class ePermit extends StatelessWidget {
  const ePermit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70, // Set the AppBar background color to white
        iconTheme: const IconThemeData(color: Colors.black), // Set the icon color to black
        titleTextStyle: const TextStyle(color: Colors.black), // Set the title text color to black
      ),
      backgroundColor: Colors.white, // Set the background color of the Scaffold to white
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
    return null; // Return null if the image fails to load
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

  @override
  void initState() {
    super.initState();
    fetchPermitData();
  }

  Future<void> fetchPermitData() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      // Fetch permit linked to user UID
      final permitQuery = await _firestore
          .collection('permits')
          .doc(user.uid) // Assuming the permit is stored by user UID
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

  String generateUniqueNumber() {
    final random = Random();
    return (random.nextInt(99999) + 10000).toString(); // Generate a 5-digit unique number
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

      int participantCount = participants?.length ?? 0;
      final double totalAmount = participantCount * 5.0; // RM 5 per participant
      final String signature = "assets/signature.png"; // Ensure this exists in pubspec.yaml

      final imageProvider = await loadImageFromAssets(signature);

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
                  pw.Text("Siri No. ${generateUniqueNumber()}", style: pw.TextStyle(fontSize: 16)),
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
                  if (imageProvider != null) pw.Image(imageProvider) else pw.Text("Signature not available"),
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

  @override
  Widget build(BuildContext context) {
    if (permitData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (permitData?['error'] != null) {
      return Center(child: Text('Error: ${permitData?['error']}'));
    }

    final participants = permitData?['participants'] as List<dynamic>?;

    final String name = participants != null && participants.isNotEmpty
        ? participants.first['name'] ?? "Unknown"
        : "Unknown";
    final String mountain = permitData?['mountain'] ?? "Unknown";
    final String date = permitData?['date'] ?? "Unknown";

    int participantCount = participants?.length ?? 0;
    final double totalAmount = participantCount * 5.0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.topCenter,  // Align content to the top center
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
                "Siri No. ${generateUniqueNumber()}",
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
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
              Text(
                "Participants: $participantCount",
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              Text(
                "This permit is valid from $date.",
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
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