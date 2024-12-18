import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:myforestnew/Pages/savedpage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:myforestnew/bukitBintang/bintangLoc.dart';
import 'package:myforestnew/bukitBintang/forecastBintang.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class bukitBintang extends StatefulWidget {
  @override
  _bukitBintangPageState createState() => _bukitBintangPageState();
}

class _bukitBintangPageState extends State<bukitBintang> {
  String weatherDescription = '';
  double temperature = 0;
  int highTemp = 0;
  int lowTemp = 0;
  String locationName = '';
  List<Map<String, dynamic>> hourlyForecast = [];
  final List<String> imgList = [
    'assets/bintang/bintang1.jpg',
    'assets/bintang/bintang2.jpg',
    'assets/bintang/bintang3.png',
  ];

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
    _checkIfSaved();
  }
  bool isSaved = false;
  String? savedDocumentId;
  Future<void> _checkIfSaved() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Query Firestore to see if the mount is already saved by the user
        final query = await FirebaseFirestore.instance
            .collection('saved_mounts')
            .where('name', isEqualTo: 'Bukit Sri Bintang') // Match the mount name
            .where('userId', isEqualTo: user.uid) // Match the current user
            .get();

        if (query.docs.isNotEmpty) {
          setState(() {
            isSaved = true;
            savedDocumentId = query.docs.first.id;
          });
        }
      } catch (e) {
        print('Error checking if mount is saved: $e');
      }
    }
  }
  Future<void> fetchWeatherData() async {
    const String apiKey = '8f5b43dd3e53fb197df8ed5a8cae93c5';
    const String location = 'Kuala Lumpur';
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$location&units=metric&appid=$apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          locationName = data['city']['name'];
          temperature = data['list'][0]['main']['temp'].toDouble();
          weatherDescription = data['list'][0]['weather'][0]['description'];
          highTemp = data['list'][0]['main']['temp_max'].toInt();
          lowTemp = data['list'][0]['main']['temp_min'].toInt();
          hourlyForecast = List.generate(6, (index) =>
          {
            'time': data['list'][index]['dt_txt'].substring(11, 16),
            'temp': data['list'][index]['main']['temp'].toInt(),
            'icon': data['list'][index]['weather'][0]['icon'],
          });
        });
      } else {
        print('Failed to load weather data');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildImageSlider(), // The image slider
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.35), // Leave space for the image slider
                _buildRoundedContent(context), // Rounded content container
              ],
            ),
          ),
          // Positioned back button and save button over the top image
          Positioned(
            top: 40,
            left: 10,
            child: Container(
              width: 50, // Set the width of the circle
              height: 45, // Set the height of the circle
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black, // Background color of the circle
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              width: 50, // Set the width of the circle
              height: 45, // Set the height of the circle
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black, // Background color of the circle
              ),
              child: IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_outline,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;

                  if (user != null) {
                    final mountData = {
                      'name': 'Bukit Sri Bintang',
                      'distance': '11 KM',
                      'description': 'Bukit Kiara Forest Reserve',
                      'images': [
                        'assets/bintang/bintang1.jpg',
                        'assets/bintang/bintang2.jpg',
                        'assets/bintang/bintang3.png',
                      ],
                      'userId': user.uid,
                    };

                    try {
                      if (isSaved) {
                        // Unsaving the mount
                        if (savedDocumentId != null) {
                          await FirebaseFirestore.instance
                              .collection('saved_mounts')
                              .doc(savedDocumentId)
                              .delete();

                          setState(() {
                            isSaved = false;
                            savedDocumentId = null;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Bukit Sri Bintang unsaved successfully!')),
                          );
                        }
                      } else {
                        // Saving the mount
                        final docRef = await FirebaseFirestore.instance
                            .collection('saved_mounts')
                            .add(mountData);

                        setState(() {
                          isSaved = true;
                          savedDocumentId = docRef.id;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Bukit Sri Bintang saved successfully!')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Operation failed: $e')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please log in to save this mount.')),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSlider() {
    return CarouselSlider(
      options: CarouselOptions(
        height: MediaQuery
            .of(context)
            .size
            .height * 0.40,
        viewportFraction: 1.0,
        enableInfiniteScroll: false,
        enlargeCenterPage: false,
      ),
      items: imgList.map((item) =>
          GestureDetector(
            onTap: () {
            },
            child: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width, // Set width explicitly
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.40, // Set height explicitly
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(item),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )).toList(),
    );
  }


  Widget _buildRoundedContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black, // Background color of the content section
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30), // Rounded top corners
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bukit Sir Bintang',
                    style: TextStyle(fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Bukit Kiara Forest Reserve',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white24,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                    'Show Trail', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Mount Info Section
          _buildTrailInfo(),
          SizedBox(height: 20),
          // Weather API Box Placeholder
          _buildWeatherBox(),
          SizedBox(height: 20),
          // Location Section
          Row(
            children: [
              Text('Location',
                  style: TextStyle(color: Colors.white, fontSize: 20)),
              Spacer(),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => bintangLoc(),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          // Reviews Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Reviews',
                  style: TextStyle(fontSize: 20, color: Colors.white)),
              Row(
                children: [
                  Text('4.9',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                  SizedBox(width: 4),
                  Icon(Icons.star, color: Colors.yellow[800], size: 20),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          // Added gap between "Reviews" and the first review
          _buildReviewsSection(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildWeatherBox() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => forecastBintang(),
          ),
        );
      },
      child : Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade900,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${temperature.toInt()}° $locationName',
              // Display location name here
              style: TextStyle(fontSize: 29, color: Colors.white),
            ),
            Text(
              weatherDescription,
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            Text(
              'H:${highTemp}° L:${lowTemp}°',
              style: TextStyle(fontSize: 14, color: Colors.white54),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: hourlyForecast.map((hour) {
                return Column(
                  children: [
                    Text(hour['time'],
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                    Image.network(
                      'http://openweathermap.org/img/wn/${hour['icon']}@2x.png',
                      width: 30,
                      height: 30,
                    ),
                    Text('${hour['temp']}°',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailInfo() {
    return Container(
      padding: EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('11 km', style: TextStyle(fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
              SizedBox(width: 10),
              Text('Trail length',
                  style: TextStyle(fontSize: 16, color: Colors.white70)),
            ],
          ),
          Divider(color: Colors.white, thickness: 1), // White line between rows
          SizedBox(height: 15),
          Row(
            children: [
              Text('3,920 ft', style: TextStyle(fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
              SizedBox(width: 10),
              Text('Elevation gain',
                  style: TextStyle(fontSize: 16, color: Colors.white70)),
            ],
          ),
          Divider(color: Colors.white, thickness: 1), // White line between rows
          SizedBox(height: 15),
          Row(
            children: [
              Text('2 hour 30 min', style: TextStyle(fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
              SizedBox(width: 10),
              Text('Estimated time',
                  style: TextStyle(fontSize: 16, color: Colors.white70)),
            ],
          ),
          Divider(color: Colors.white, thickness: 1), // White line between rows
          SizedBox(height: 15),
          Row(
            children: [
              Text('Hard', style: TextStyle(fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
              SizedBox(width: 10),
              Text('Difficulty',
                  style: TextStyle(fontSize: 16, color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewItem('Adib', 'The trail was easy and fun', 5),
        _buildReviewItem(
            'Iqbal Ishak', 'The trail was fun but a bit challenging', 4),
        _buildReviewItem('Amal Hakimi', 'A beautiful, scenic experience', 5),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            _showReviewInput();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white24,
          ),
          child: Text('Write a Review', style: TextStyle(color: Colors.white)),
        ),

      ],
    );
  }

  Widget _buildReviewItem(String name, String review, int stars) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 12),
      // Added margin for spacing between boxes
      decoration: BoxDecoration(
        color: Colors.grey[900], // Background color for each review box
        borderRadius: BorderRadius.circular(25), // Rounded corners
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(name, style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white)),
              Spacer(),
              Row(
                children: List.generate(stars, (index) =>
                    Icon(Icons.star, color: Colors.yellow[800])),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(review, style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }


  void _showReviewInput() {
    showDialog(
      context: context,
      builder: (context) {
        String review = '';
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text('Write a Review', style: TextStyle(color: Colors.white)),
          content: TextField(
            onChanged: (value) {
              review = value;
            },
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter your review here',
              hintStyle: TextStyle(color: Colors.white54),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle submitting the review
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent),
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}