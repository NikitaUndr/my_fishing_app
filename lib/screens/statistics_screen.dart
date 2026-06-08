import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/journal_provider.dart';
import '../models/fishing_record.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final journalProvider = Provider.of<JournalProvider>(context);
    final records = journalProvider.records;

    final totalTrips = records.length;
    final monthlyData = _getMonthlyData(records);
    final topPlaces = _getTopPlaces(records);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
      ),
      body: records.isEmpty
          ? const Center(child: Text('Нет данных для статистики'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Карточка с общим количеством рыбалок
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Всего рыбалок',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalTrips',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Блок "Топ-5 мест"
            if (topPlaces.isNotEmpty) ...[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🏆 Топ-5 мест по количеству рыбалок',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ...topPlaces.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withAlpha(51),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${entry.key}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(entry.value['name']!)),
                              Text(
                                '${entry.value['count']} ${_pluralize(entry.value['count'])}',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // График по месяцам
            const Text(
              'Количество выездов по месяцам',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: monthlyData.values.reduce((a, b) => a > b ? a : b).toDouble() + 1,
                  barGroups: monthlyData.entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key - 1,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: Colors.blue,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const monthNames = [
                            'Янв', 'Фев', 'Мар', 'Апр', 'Май', 'Июн',
                            'Июл', 'Авг', 'Сен', 'Окт', 'Ноя', 'Дек'
                          ];
                          final index = value.toInt();
                          if (index >= 0 && index < monthNames.length) {
                            return Text(monthNames[index], style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<int, int> _getMonthlyData(List<FishingRecord> records) {
    final now = DateTime.now();
    final Map<int, int> monthlyCount = {
      for (int i = 1; i <= 12; i++) i: 0
    };
    for (var record in records) {
      if (record.date.year == now.year) {
        monthlyCount[record.date.month] = (monthlyCount[record.date.month] ?? 0) + 1;
      }
    }
    return monthlyCount;
  }

  Map<int, Map<String, dynamic>> _getTopPlaces(List<FishingRecord> records) {
    final Map<String, int> placeCount = {};
    for (var record in records) {
      if (record.placeName.isNotEmpty) {
        placeCount[record.placeName] = (placeCount[record.placeName] ?? 0) + 1;
      }
    }
    final sorted = placeCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted.take(5).toList();
    final result = <int, Map<String, dynamic>>{};
    for (int i = 0; i < top5.length; i++) {
      result[i+1] = {'name': top5[i].key, 'count': top5[i].value};
    }
    return result;
  }

  String _pluralize(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'выезд';
    if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) return 'выезда';
    return 'выездов';
  }
}