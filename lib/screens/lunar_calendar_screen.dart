import 'package:flutter/material.dart';
import 'dart:math';

class LunarCalendarScreen extends StatefulWidget {
  const LunarCalendarScreen({super.key});

  @override
  State<LunarCalendarScreen> createState() => _LunarCalendarScreenState();
}

class _LunarCalendarScreenState extends State<LunarCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  double _moonPhase = 0.0;
  String _phaseName = '';
  String _fishingForecast = '';

  // Список названий месяцев на русском
  final List<String> _monthNames = [
    'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
    'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
  ];

  @override
  void initState() {
    super.initState();
    _calculateMoonPhase(_selectedDate);
  }

  void _calculateMoonPhase(DateTime date) {
    // Известное новолуние: 6 января 2000 года, 18:14 UTC
    final knownNewMoon = DateTime.utc(2000, 1, 6, 18, 14);
    final diff = date.difference(knownNewMoon).inDays;
    const synodicMonth = 29.53058867; // средняя продолжительность лунного месяца в днях
    final phase = (diff / synodicMonth) % 1.0;
    setState(() {
      _moonPhase = phase;
      _phaseName = _getPhaseName(phase);
      _fishingForecast = _getFishingForecast(phase);
    });
  }

  String _getPhaseName(double phase) {
    if (phase < 0.03 || phase > 0.97) return '🌑 Новолуние';
    if (phase < 0.23) return '🌒 Растущий серп';
    if (phase < 0.27) return '🌓 Первая четверть';
    if (phase < 0.48) return '🌔 Растущая луна';
    if (phase < 0.53) return '🌕 Полнолуние';
    if (phase < 0.73) return '🌖 Убывающая луна';
    if (phase < 0.77) return '🌗 Последняя четверть';
    return '🌘 Убывающий серп';
  }

  String _getFishingForecast(double phase) {
    if (phase < 0.1 || phase > 0.9) return '🐟 Отличный клёв! (новолуние)';
    if (phase > 0.45 && phase < 0.55) return '⚠️ Умеренный клёв (полнолуние)';
    if ((phase > 0.23 && phase < 0.27) || (phase > 0.73 && phase < 0.77)) {
      return '🎣 Хороший клёв (квадратуры)';
    }
    return '👍 Средний клёв';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('ru', 'RU'),
      // Параметр locale убран, чтобы избежать ошибки
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _calculateMoonPhase(picked);
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_monthNames[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Лунный календарь рыбака'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
            tooltip: 'Выбрать дату',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      _formatDate(_selectedDate),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _phaseName,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _moonPhase,
                      backgroundColor: Colors.grey[300],
                      color: Colors.amber,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_moonPhase * 100).toStringAsFixed(0)}% освещена',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _fishingForecast,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📖 Как использовать:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('• Новолуние – лучший клёв хищника.'),
                    Text('• Первая/последняя четверть – хороший клёв мирной рыбы.'),
                    Text('• Полнолуние – рыба пассивна, лучше отдохнуть.'),
                    SizedBox(height: 8),
                    Text('ℹ️ Прогноз основан на фазах луны и многолетнем опыте рыболовов.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}