import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                getTitlesWidget: (value, _) => Text(
                  '${(value / 10).toStringAsFixed(1)} km',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
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
