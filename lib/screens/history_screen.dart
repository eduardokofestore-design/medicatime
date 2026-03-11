import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/medication_provider.dart';
import '../models/medication.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final medicationProvider = Provider.of<MedicationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico'),
      ),
      body: StreamBuilder<List<MedicationHistory>>(
        stream: medicationProvider.getHistory(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final history = snapshot.data!;
            final takenCount = history.where((h) => h.status == 'taken').length;
            final totalCount = history.length;
            final adherencePercentage = totalCount > 0 ? (takenCount / totalCount * 100).round() : 0;

            // Calculate weekly data
            final weeklyData = _calculateWeeklyData(history);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Percentual de Adesão: $adherencePercentage%',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text('Gráfico Semanal de Adesão'),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        barGroups: weeklyData.map((data) => BarChartGroupData(
                          x: data['day'] ?? 0,
                          barRods: [
                            BarChartRodData(
                              toY: data['taken']?.toDouble() ?? 0,
                              color: Colors.green,
                            ),
                          ],
                        )).toList(),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
                                return Text(days[value.toInt()]);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final entry = history[index];
                        return ListTile(
                          title: Text('${entry.date.toLocal()} - ${entry.time}'),
                          subtitle: Text('Status: ${entry.status}'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  List<Map<String, int>> _calculateWeeklyData(List<MedicationHistory> history) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weeklyData = List.generate(7, (index) => {'day': index, 'taken': 0});

    for (var entry in history) {
      if (entry.status == 'taken' && entry.date.isAfter(startOfWeek)) {
        final dayIndex = entry.date.weekday - 1;
        weeklyData[dayIndex]['taken'] = (weeklyData[dayIndex]['taken'] as int) + 1;
      }
    }

    return weeklyData;
  }
}