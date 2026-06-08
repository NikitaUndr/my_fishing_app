import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/journal_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/lunar_calendar_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';
import 'screens/add_edit_record_screen.dart';
import 'service/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  try {
    await NotificationService.init();
    await NotificationService.scheduleWeeklyReminder();
  } catch (e) {
    print('Ошибка инициализации уведомлений: $e');
  }
  //await NotificationService.init();          // инициализация уведомлений
  //await NotificationService.scheduleWeeklyReminder(); // запуск еженедельного напоминания
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => JournalProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // новый провайдер
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Fisher App',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ru', 'RU'), // русский
              Locale('en', 'US'), // английский (как запасной)
            ],
            locale: const Locale('ru', 'RU'), // принудительно русский (опционально)
            initialRoute: '/',
            routes: {
              '/': (context) => const AuthWrapper(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/add_edit_record': (context) => const AddEditRecordScreen(),
              '/lunar': (context) => const LunarCalendarScreen(),
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.user == null) {
      return const LoginScreen();
    } else {
      return const MainScreen();
    }
  }
}