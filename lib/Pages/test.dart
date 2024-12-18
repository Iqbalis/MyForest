import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gpx/gpx.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: Colors.white,
      body: ElevationProfileApp(),
    ),
  ));
}

class ElevationProfileApp extends StatefulWidget {
  @override
  _ElevationProfileAppState createState() => _ElevationProfileAppState();
}

class _ElevationProfileAppState extends State<ElevationProfileApp> {
  List<double> elevations = [];

  @override
  void initState() {
    super.initState();
    loadGpxData();
  }

  Future<void> loadGpxData() async {
    // Replace with your GPX file path
    final data = await parseGpxFile('assets/gpxFile/nuang.xml');
    setState(() {
      elevations = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Other Content (Map, Header, etc.)
        Positioned.fill(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    'Map or Other Content Here',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Elevation Profile at Bottom
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.3, // 30% of the page
            child: Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300, width: 2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, -2), // Shadow above the container
                  ),
                ],
              ),
              child: elevations.isNotEmpty
                  ? ElevationProfile(elevations: elevations)
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      ],
    );
  }
}

class ElevationProfile extends StatelessWidget {
  final List<double> elevations;

  const ElevationProfile({Key? key, required this.elevations}) : super(key: key);

  List<FlSpot> generateChartData() {
    return List<FlSpot>.generate(
      elevations.length,
          (index) => FlSpot(index.toDouble(), elevations[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                getTitlesWidget: (value, _) => Text(
                  '${(value / 10).toStringAsFixed(1)} km',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.black54, width: 1),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: generateChartData(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 2,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.5),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              dotData: FlDotData(show: false),
            ),
          ],
          minX: 0,
          maxX: elevations.length.toDouble(),
          minY: elevations.reduce((a, b) => a < b ? a : b),
          maxY: elevations.reduce((a, b) => a > b ? a : b),
        ),
      ),
    );
  }
}

Future<List<double>> parseGpxFile(String filePath) async {
  try {
    String gpxData = await rootBundle.loadString(filePath);

    final gpx = GpxReader().fromString(gpxData);

    return gpx.trks
        .expand((trk) => trk.trksegs)
        .expand((trkseg) => trkseg.trkpts)
        .map((trkpt) => trkpt.ele ?? 0.0)
        .toList();
  } catch (e) {
    throw Exception('Failed to parse GPX file: $e');
  }
}
