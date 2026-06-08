import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/fishing_record.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // ... внутри класса DatabaseService

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'fisher_app.db');
    return await openDatabase(
      path,
      version: 4, // Увеличиваем версию
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Добавляем обработчик миграции
    );
  }

  // Миграция для добавления новых колонок
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE fishing_records ADD COLUMN temperature REAL');
      await db.execute('ALTER TABLE fishing_records ADD COLUMN weather_condition TEXT');
    }
  }

  // Обновлённый CREATE TABLE для новых установок
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE fishing_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        date TEXT NOT NULL,
        place_name TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        tackle TEXT,
        bait TEXT,
        catch_details TEXT,
        temperature REAL,
        weather_condition TEXT,
        photo_path TEXT
      )
    ''');
  }

// ... остальные методы без изменений


  Future<int> insertRecord(FishingRecord record) async {
    try {
      Database db = await database;
      print('Вставляем запись: ${record.toMap()}');
      int id = await db.insert('fishing_records', record.toMap());
      print('Вставлено с id: $id');
      return id;
    } catch (e) {
      print('Ошибка вставки: $e');
      throw Exception('Ошибка базы данных: $e');
    }
  }

  // Получить все записи пользователя
  Future<List<FishingRecord>> getRecordsForUser(String userId) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'fishing_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return FishingRecord.fromMap(maps[i]);
    });
  }

  // Обновить запись
  Future<int> updateRecord(FishingRecord record) async {
    try {
      Database db = await database;
      print('Обновляем запись: ${record.toMap()}');
      int result = await db.update(
        'fishing_records',
        record.toMap(),
        where: 'id = ?',
        whereArgs: [record.id],
      );
      print('Обновлено строк: $result');
      return result;
    } catch (e) {
      print('Ошибка обновления: $e');
      throw Exception('Ошибка базы данных: $e');
    }
  }

  // Удалить запись
  Future<int> deleteRecord(int id) async {
    Database db = await database;
    return await db.delete(
      'fishing_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Получить одну запись по id
  Future<FishingRecord?> getRecordById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'fishing_records',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return FishingRecord.fromMap(maps.first);
    }
    return null;
  }
}