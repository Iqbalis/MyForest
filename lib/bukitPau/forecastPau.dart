import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class forecastPau extends StatefulWidget {
  @override
  _WeatherForecastPageState createState() => _WeatherForecastPageState();
}

class _WeatherForecastPageState extends State<forecastPau> {
  late Future<List<WeatherForecast>> forecast;

  @override
  void initState() {
    super.initState();
    forecast = fetchWeatherForecast();
  }

  @override
  Widget build(BuildContext context) {
    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Color(0xFF1E1E1E),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF121212),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
      iconTheme: IconThemeData(color: Colors.white70),
    );

    return Theme(
      data: darkTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Ampang'),
          centerTitle: true,
          elevation: 5,
          backgroundColor: Colors.blueGrey[800],
        ),
        body: FutureBuilder<List<WeatherForecast>>(
          future: forecast,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingScreen();
            } else if (snapshot.hasError) {
              return _buildErrorScreen(snapshot.error.toString());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildErrorScreen("No forecast data available");
            } else {
              final weatherData = snapshot.data!;
              return _buildWeatherForecast(weatherData);
            }
          },
        ),
      ),
    );
  }

  // Loading Screen
  Widget _buildLoadingScreen() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.white),
      ),
    );
  }

  // Error Screen
  Widget _buildErrorScreen(String error) {
    return Center(
      child: Text(
        "Error: $error",
        style: TextStyle(color: Colors.redAccent, fontSize: 18),
      ),
    );
  }

  // Weather Forecast Screen
  Widget _buildWeatherForecast(List<WeatherForecast> weatherData) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTodayWeather(weatherData),
          _buildFiveDayForecast(weatherData),
        ],
      ),
    );
  }

  // Today's Weather Widget
  Widget _buildTodayWeather(List<WeatherForecast> weatherData) {
    final todayForecast = weatherData[0];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TODAY'S WEATHER",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.wb_sunny, color: Colors.yellow[700], size: 40),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${todayForecast.temp}°C",
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      todayForecast.weatherDescription,
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          Text(
            "Time-Based Forecast",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Container(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 8,
              itemBuilder: (context, index) {
                final forecast = weatherData[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      Text(
                        forecast.time,
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      Icon(Icons.cloud, color: Colors.white70),
                      Text(
                        '${forecast.temp}°C',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 5-Day Forecast Widget
  Widget _buildFiveDayForecast(List<WeatherForecast> weatherData) {
    final distinctDays = <String, WeatherForecast>{};

    // Group forecasts by day
    for (var forecast in weatherData) {
      if (!distinctDays.containsKey(forecast.dayName)) {
        distinctDays[forecast.dayName] = forecast;
      }
    }

    // Get only 5 distinct days
    final fiveDayForecast = distinctDays.values.take(5).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '5-DAY FORECAST',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 10),
          Column(
            children: fiveDayForecast.map((dailyForecast) {
              return Card(
                color: Colors.black26,
                margin: EdgeInsets.symmetric(vertical: 8),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: Icon(Icons.cloud, color: Colors.white70),
                  title: Text(
                    dailyForecast.dayName,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  subtitle: Row(
                    children: [
                      Text('${dailyForecast.tempMin}°', style: TextStyle(color: Colors.white)),
                      SizedBox(width: 10),
                      Container(
                        height: 5,
                        width: 100,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 10),
                      Text('${dailyForecast.tempMax}°', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${dailyForecast.precipitationChance}%',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class WeatherForecast {
  final String dayName;
  final String time;
  final String weatherDescription;
  final double temp;
  final double tempMax;
  final double tempMin;
  final int precipitationChance;

  WeatherForecast({
    required this.dayName,
    required this.time,
    required this.weatherDescription,
    required this.temp,
    required this.tempMax,
    required this.tempMin,
    required this.precipitationChance,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000).toLocal();
    final dayName = DateFormat('EEEE').format(dateTime); // Get the day name (e.g., "Monday")

    return WeatherForecast(
      dayName: dayName,
      time: dateTime.toString().split(' ')[1].substring(0, 5), // Get time in HH:MM format
      weatherDescription: json['weather'][0]['description'],
      temp: json['main']['temp'].toDouble(),
      tempMax: json['main']['temp_max'].toDouble(),
      tempMin: json['main']['temp_min'].toDouble(),
      precipitationChance: (json['pop'] * 100).toInt(),
    );
  }
}

Future<List<WeatherForecast>> fetchWeatherForecast() async {
  const String apiKey = '8f5b43dd3e53fb197df8ed5a8cae93c5';
  const String location = 'Ampang';
  final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?q=$location&units=metric&appid=$apiKey');

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['list'];
      return data.map((json) => WeatherForecast.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load weather forecast');
    }
  } catch (e) {
    rethrow;
  }
}