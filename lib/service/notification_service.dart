import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tzdata.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: null, // iOS не используется
    );
    await _notifications.initialize(settings);
  }

  static Future<void> scheduleWeeklyReminder() async {
    await _notifications.cancel(0);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Напоминания о рыбалке',
      channelDescription: 'Еженедельные советы и напоминания',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: null,
    );

    await _notifications.periodicallyShow(
      0,
      '🐟 Пора на рыбалку!',
      'Не забудьте записать свои уловы в журнал и посмотреть лунный календарь.',
      RepeatInterval.weekly,
      details,
      androidAllowWhileIdle: true,
    );
  }

  static Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Тестовые уведомления',
      channelDescription: 'Канал для тестовых уведомлений',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: null,
    );
    await _notifications.show(
      99,
      '✅ Уведомления работают!',
      'Это тестовое уведомление из вашего приложения.',
      details,
    );
  }
}