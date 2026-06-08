import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'journal_screen.dart';
import 'all_points_map_screen.dart';
import 'statistics_screen.dart';
import 'gallery_screen.dart'; // импорт галереи
import 'catches_statistics_screen.dart';
import '../service/notification_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    JournalScreen(),
    AllPointsMapScreen(),
    StatisticsScreen(),
    GalleryScreen(), // новая вкладка
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/fish.png',
          height: 40, // подберите нужную высоту
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
          const Text('Fisher App'), // запасной текст, если фото не загрузится
        ),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeProvider.toggleTheme,
            tooltip: 'Сменить тему',
          ),
          IconButton(
            icon: const Icon(Icons.nights_stay),
            onPressed: () => Navigator.pushNamed(context, '/lunar'),
            tooltip: 'Лунный календарь',
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CatchesStatisticsScreen()),
              );
            },
            tooltip: 'Статистика улова',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () async {
              await NotificationService.showTestNotification();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Тестовое уведомление отправлено!')),
              );
            },
            tooltip: 'Тест уведомления',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await authProvider.signOut(),
            tooltip: 'Выход',
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Журнал'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Карта'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Статистика'),
          BottomNavigationBarItem(icon: Icon(Icons.photo_library), label: 'Галерея'),
        ],
      ),
    );
  }
}