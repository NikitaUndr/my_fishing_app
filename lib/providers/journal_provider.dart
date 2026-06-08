import 'package:flutter/material.dart';
import '../models/fishing_record.dart';
import '../service/database_service.dart';

class JournalProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  List<FishingRecord> _records = [];

  List<FishingRecord> get records => _records;

  // Загрузка записей для конкретного пользователя
  Future<void> loadRecords(String userId) async {
    _records = await _db.getRecordsForUser(userId);
    notifyListeners();
  }

  // Добавление новой записи
  Future<void> addRecord(FishingRecord record) async {
    try {
      await _db.insertRecord(record);
      await loadRecords(record.userId);
    } catch (e) {
      print('JournalProvider addRecord error: $e');
      rethrow;
    }
  }

  // Обновление существующей записи
  Future<void> updateRecord(FishingRecord record) async {
    try {
      await _db.updateRecord(record);
      await loadRecords(record.userId);
    } catch (e) {
      print('JournalProvider updateRecord error: $e');
      rethrow;
    }
  }


  // Удаление записи
  Future<void> deleteRecord(int id, String userId) async {
    await _db.deleteRecord(id);
    await loadRecords(userId);
  }

  // Очистка списка (например, при выходе)
  void clear() {
    _records = [];
    notifyListeners();
  }
}