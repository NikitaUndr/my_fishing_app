// lib/screens/catches_statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/journal_provider.dart';
import '../models/fishing_record.dart';

class CatchesStatisticsScreen extends StatelessWidget {
  const CatchesStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final records = Provider.of<JournalProvider>(context).records;
    final fishData = _parseCatches(records);

    if (fishData.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Статистика улова')),
        body: const Center(child: Text('Нет данных об улове.\nДобавьте записи с текстом в поле "Улов", например: "щука 2, окунь 3"')),
      );
    }

    // Сортируем по убыванию количества
    final sortedEntries = fishData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final Map<String, int> sortedMap = {};
    for (var entry in sortedEntries) {
      sortedMap[entry.key] = entry.value;
    }

    final totalFish = sortedMap.values.reduce((a, b) => a + b);

    return Scaffold(
      appBar: AppBar(title: const Text('Статистика улова')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Распределение по видам', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 250,
                      child: PieChart(
                        PieChartData(
                          sections: sortedMap.entries.map((entry) {
                            final value = entry.value.toDouble();
                            final percent = value / totalFish;
                            return PieChartSectionData(
                              value: value,
                              title: '',
                              radius: 80,
                              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              color: _getColorForFish(entry.key),
                            );
                          }).toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          startDegreeOffset: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Детализация', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...sortedMap.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: _getColorForFish(entry.key),
                                ),
                                const SizedBox(width: 8),
                                Text(entry.key, style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                            Text('${entry.value} ${_pluralizeFish(entry.value)}'),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, int> _parseCatches(List<FishingRecord> records) {
    final Map<String, int> fishCount = {};

    for (var record in records) {
      final text = record.catchDetails ?? '';
      if (text.isEmpty) continue;

      // Разделяем по запятым, точкам с запятой, переводам строк
      final parts = text.split(RegExp(r'[,;]\s*|\n'));
      for (var part in parts) {
        part = part.trim();
        if (part.isEmpty) continue;

        // Пытаемся найти число и название
        // Вариант: "щука 2", "2 щуки"
        final match1 = RegExp(r'([а-яА-ЯёЁa-zA-Z]+)\s*[:]?\s*(\d+(?:\.\d+)?)', unicode: true).firstMatch(part);
        final match2 = RegExp(r'(\d+(?:\.\d+)?)\s*([а-яА-ЯёЁa-zA-Z]+)', unicode: true).firstMatch(part);

        if (match1 != null) {
          final species = match1.group(1)!.trim().toLowerCase();
          final count = (double.tryParse(match1.group(2)!) ?? 1).toInt();
          fishCount[species] = (fishCount[species] ?? 0) + count;
        } else if (match2 != null) {
          final species = match2.group(2)!.trim().toLowerCase();
          final count = (double.tryParse(match2.group(1)!) ?? 1).toInt();
          fishCount[species] = (fishCount[species] ?? 0) + count;
        } else {
          // Нет числа – считаем 1 рыбу
          final species = part.toLowerCase();
          fishCount[species] = (fishCount[species] ?? 0) + 1;
        }
      }
    }
    return fishCount;
  }

  Color _getColorForFish(String fish) {
    final int hash = fish.hashCode.abs();
    return Color(0xFF000000 + (hash % 0xFFFFFF)).withAlpha(180);
  }

  String _pluralizeFish(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'рыба';
    if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) return 'рыбы';
    return 'рыб';
  }
}