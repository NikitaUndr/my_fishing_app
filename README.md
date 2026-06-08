## Данные об авторе

# **АНДРЕЙЧУК НИКИТА СЕРГЕЕВИЧ**  
**Логин:** Andrejchuk_NS_22   
**Курс / семестр:** 4 курс / 8 семестр  
**Специальность:** «Программное обеспечение информационных 
технологий»  
**Вид проекта:** Дипломная работа

# Fisher App – мобильное приложение для любителей рыбной ловли

Мобильное приложение для ведения личного журнала рыбалок, картографической фиксации мест, автоматического получения погоды, статистики и лунного календаря с полной поддержкой офлайн-режима.

## О проекте

Приложение решает задачу систематизации индивидуального опыта рыболова: фиксация даты, места (координаты), используемых снастей, приманок и улова. В отличие от существующих аналогов (часто платных или с урезанным бесплатным функционалом), система предоставляет:

* Бесплатный и полный функционал – журнал, карта, погода, статистика, лунный календарь, галерея, тёмная тема, уведомления.
* Офлайн-режим – все записи сохраняются локально в SQLite и доступны без интернета.
* Интеграцию Яндекс.Карт – выбор места на карте, поиск по названию, автоматическое обратное геокодирование, отображение всех сохранённых точек с маркерами.
* Автоматическую погоду – получение температуры и описания от OpenWeatherMap API по координатам выбранного места.
* Лунный календарь с прогнозом клёва – расчёт фазы луны по дате и формирование рекомендации.
* Галерею улова – просмотр всех фото в сетке, полноэкранный режим с листанием и масштабированием.
* Тёмную тему – переключение светлой/тёмной темы на лету.
* Локальные уведомления – еженедельное напоминание о ведении журнала, тестовое уведомление.

Достигнута стабильная работа на Android 11–14, все 23 функциональных теста пройдены успешно.

## Ключевые возможности системы

* **Аутентификация** – регистрация/вход/выход через Firebase Authentication (email/пароль).
* **Журнал рыбалок** – добавление, редактирование, удаление (свайп), прикрепление фото.
* **Карта** – отображение всех точек на карте, центрирование, маркеры с детальной информацией; при добавлении записи – выбор места на карте, поиск, геолокация, обратное геокодирование.
* **Погода** – автоматический запрос температуры и погодных условий при сохранении записи, отображение в карточке журнала.
* **Статистика** – общее количество рыбалок, график выездов по месяцам (fl_chart), топ‑5 мест по частоте посещений.
* **Лунный календарь** – выбор даты, расчёт фазы (0–1) по синодическому алгоритму, текстовый прогноз клёва (отличный, хороший, средний, умеренный).
* **Галерея улова** – сетка из всех фото (Image.file), полноэкранный просмотр с PageView, масштабирование InteractiveViewer, листание свайпом.
* **Тёмная тема** – переключение через провайдер ThemeProvider, адаптация всех экранов.
* **Уведомления** – локальные уведомления через flutter_local_notifications: тестовое по кнопке и еженедельное напоминание (воскресенье, 10:00).

## Архитектура проекта

Проект написан на Flutter (Dart) с использованием паттерна Provider. Основные модули:

* `lib/screens/` – все экраны (LoginScreen, RegisterScreen, JournalScreen, AddEditRecordScreen, MapPickerScreen, AllPointsMapScreen, StatisticsScreen, GalleryScreen, LunarCalendarScreen, CatchesStatisticsScreen и др.)
* `lib/providers/` – провайдеры состояния (AuthProvider, JournalProvider, ThemeProvider)
* `lib/services/` – сервисы (AuthService, DatabaseService, WeatherService, NotificationService)
* `lib/models/` – модели данных (User, FishingRecord)
* `lib/utils/` – вспомогательные функции (форматирование дат, парсинг улова, плюрализация)

## Функциональность

* **Аутентификация** – Firebase Auth: регистрация/вход с валидацией, обработка ошибок, поток состояния пользователя.
* **Локальная база данных** – SQLite (sqflite): таблица `fishing_records` с полями id, user_id, date, place_name, latitude, longitude, tackle, bait, catch_details, temperature, weather_condition, photo_path. Индексы по user_id и date.
* **Офлайн-режим** – все операции журнала выполняются локально; при отсутствии интернета работа продолжается (кроме получения погоды, но запись сохраняется).
* **Карта** – Яндекс.Карты (yandex_mapkit): отображение карты, маркеры, поиск, геолокация (geolocator), обратное геокодирование (HTTP‑запросы к геокодеру).
* **Погода** – OpenWeatherMap API: GET-запрос по координатам, парсинг JSON, сохранение температуры и описания.
* **Статистика** – агрегация по месяцам, вычисление топ‑5 мест, построение графика (fl_chart).
* **Лунный календарь** – расчёт фазы: (date - known_new_moon) / synodic_month % 1.0, пороговое определение фазы, прогноз.
* **Галерея** – чтение файлов из photo_path, отображение в GridView, передача списка путей в FullScreenPhotoViewer.
* **Уведомления** – планирование через periodicallyShow (RepeatInterval.weekly) и тестовый показ.

## Структура данных

Приложение используя локальную SQLite-базу данных с одной основной таблицей:

```sql
CREATE TABLE fishing_records (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    date DATETIME NOT NULL,
    place_name TEXT NOT NULL,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL,
    tackle TEXT,
    bait TEXT,
    catch_details TEXT,
    temperature REAL,
    weather_condition TEXT,
    photo_path TEXT
);
```

## Установка и запуск

1. Клонируйте репозиторий:
   ```bash
   git clone https://github.com/ваш_username/fisher-app.git
   cd fisher-app

2. Установите Flutter SDK (см. документацию (https://docs.flutter.dev/get-started/install)).

3. Установите зависимости:
   ```bash
   flutter pub get

4. Настройте Firebase:
* Создайте проект в Firebase Console.
* Добавьте Android-приложение с package name com.example.fishing_app2 (или вашим).
* Скачайте google-services.json и поместите в android/app/.
* Включите аутентификацию по email/паролю.
* Получите API-ключи:
Яндекс.Карты (мобильный SDK) – вставьте в MainApplication.java.
OpenWeatherMap – вставьте в WeatherService.
Яндекс.Геокодер – вставьте в YandexMapPickerScreen.

5. Запустите приложение:
  ```bash
  flutter run
```

## Архитектура проекта (файлы)

* lib/main.dart – точка входа, инициализация Firebase, провайдеров, маршрутизация.
* lib/screens/login_screen.dart, register_screen.dart – аутентификация.
* lib/screens/journal_screen.dart – журнал с удалением свайпом.
* lib/screens/add_edit_record_screen.dart – форма добавления/редактирования, выбор фото, карта.
* lib/screens/all_points_map_screen.dart – карта всех сохранённых точек.
* lib/screens/yandex_map_picker_screen.dart – выбор места на карте с поиском.
* lib/screens/statistics_screen.dart – статистика (график, топ‑5).
* lib/screens/gallery_screen.dart – галерея улова.
* lib/screens/lunar_calendar_screen.dart – лунный календарь.
* lib/providers/auth_provider.dart, journal_provider.dart, theme_provider.dart.
* lib/services/auth_service.dart, database_service.dart, weather_service.dart, notification_service.dart.
* lib/models/fishing_record.dart.

## Результаты

Приложение успешно протестировано на реальных устройствах Samsung Galaxy (Android 13, 14). Все 23 функциональных теста пройдены. 
Основные метрики:
* Стабильность – ни одного краша при длительном использовании.
* Производительность – добавление 50+ записей, скроллинг журнала и галереи менее 0.5 секунды.
* Офлайн-режим – полная работа журнала без интернета, корректная обработка отсутствия сети при запросе погоды.
* Точность геокодирования – обратное геокодирование даёт корректный адрес для выбранных координат.
* Лунный календарь – фазы совпадают с общедоступными календарями (погрешность <0.01).

<img width="232" height="434" alt="image" src="https://github.com/user-attachments/assets/91946c9c-47a6-4ce4-a0d0-2b9e413e9ef1" /> <img width="232" height="434" alt="image" src="https://github.com/user-attachments/assets/192aa997-7174-4a2a-872e-2ed301af8b58" /> <img width="232" height="434" alt="image" src="https://github.com/user-attachments/assets/c40c8416-a2eb-43bf-ba21-33676dbe1b15" /> 

<img width="232" height="434" alt="image" src="https://github.com/user-attachments/assets/12cb7bde-1289-4bb0-85f8-7a77cc504f10" /> <img width="232" height="434" alt="image" src="https://github.com/user-attachments/assets/805a1e6c-c717-4466-a424-7c3527a44bce" /> <img width="232" height="434" alt="image" src="https://github.com/user-attachments/assets/2f80ec15-7bb8-4ce0-8880-bdf76987e342" /> 

<img width="232" height="434" alt="image" src="https://github.com/user-attachments/assets/dde0b460-b968-43ef-9b4a-ff65a9bb2fe5" /> <img width="232" height="434" alt="image" src="https://github.com/user-attachments/assets/3337b73e-5b47-482e-a0b2-b784eb63b299" /> <img width="232" height="434" alt="image" src="https://github.com/user-attachments/assets/8768031a-0bef-4cea-91fe-62ad4626096f" />


## Требования

* Flutter SDK (>=3.13.0)

* Dart (>=3.1.0)

* Android SDK (minSdk 26, targetSdk 34)

* Для сборки под iOS: Xcode 14+ (опционально)

* Доступ в интернет для работы карт и погоды (базовый функционал журнала работает офлайн)









