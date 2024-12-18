import 'package:flutter/material.dart';
import 'package:myforestnew/Admin/ApprovalPage.dart';
import 'package:myforestnew/Resources/permit_method.dart';

class PermitAdmin extends StatefulWidget {
  @override
  _PermitApplicationState createState() => _PermitApplicationState();
}

class _PermitApplicationState extends State<PermitAdmin> {
  final TextEditingController _dateController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final PermitMethods _permitMethods = PermitMethods();

  String? _selectedMountain;
  final TextEditingController _guideNumberController = TextEditingController();
  List<Map<String, TextEditingController>> _participants = [];

  // Sample list of mountains
  final List<String> _mountains = ["Mount Nuang", "Mount Hitam", "Bukit Lagong", "Bukit Pau"];

  @override
  void initState() {
    super.initState();
    _addParticipant(); // Start with one participant
  }

  void _addParticipant() {
    setState(() {
      _participants.add({
        'name': TextEditingController(),
        'phone': TextEditingController(),
        'emergency': TextEditingController(),
      });
    });
  }

  void _removeParticipant(int index) {
    setState(() {
      _participants.removeAt(index);
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final String date = _dateController.text.trim();
      final String mountain = _selectedMountain!;
      final String guide = _guideNumberController.text.trim();

      List<Map<String, String>> participantData = _participants.map((p) {
        return {
          'name': p['name']!.text.trim(),
          'phone': p['phone']!.text.trim(),
          'emergency': p['emergency']!.text.trim(),
        };
      }).toList();

      String response = await _permitMethods.permitUser(
        mountain: mountain,
        guide: guide.isNotEmpty ? guide : "No guide specified",
        date: date,
        participantsNo: participantData.length.toString(),
        participants: participantData,
      );

      // Show confirmation or error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response)));
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _guideNumberController.dispose();
    for (var participant in _participants) {
      participant['name']!.dispose();
      participant['phone']!.dispose();
      participant['emergency']!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Permit Application Form"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PermitsListPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25), // Rounded corners
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text('Permit List'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Name of Mountain',
                    labelStyle: TextStyle(fontSize: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  items: _mountains.map((mountain) {
                    return DropdownMenuItem<String>(
                      value: mountain,
                      child: Text(
                        mountain,
                        style: TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMountain = value;
                    });
                  },
                  value: _selectedMountain,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
              ),
              if (_selectedMountain != null && _selectedMountain!.startsWith("Mount"))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _guideNumberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Guide Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                ),
              SizedBox(height: 2),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Date Range',
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  DateTimeRange? pickedRange = await showDateRangePicker(
                    context: context,
                    initialDateRange: DateTimeRange(
                      start: DateTime.now(),
                      end: DateTime.now(),
                    ),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (pickedRange != null) {
                    _dateController.text =
                    "${pickedRange.start.toLocal().toIso8601String().split('T')[0]} - ${pickedRange.end.toLocal().toIso8601String().split('T')[0]}";
                  }
                },
                readOnly: true,
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              Text(
                'Participants',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ..._participants.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, TextEditingController> participant = entry.value;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: participant['name'],
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: participant['phone'],
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: participant['emergency'],
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Emergency Contact Number',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                        ),
                        SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => _removeParticipant(index),
                            icon: Icon(Icons.delete, color: Colors.red),
                            label: Text(
                              "Remove",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _addParticipant,
                icon: Icon(Icons.add),
                label: Text("Add Participant"),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}