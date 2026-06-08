import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/journal_provider.dart';
import 'add_edit_record_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecords();
    });
  }

  Future<void> _loadRecords() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final journalProvider = Provider.of<JournalProvider>(context, listen: false);
    if (authProvider.user != null) {
      await journalProvider.loadRecords(authProvider.user!.uid);
    }
  }

  Future<bool?> _confirmDelete(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить запись?'),
        content: const Text('Вы уверены, что хотите удалить эту запись?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final journalProvider = Provider.of<JournalProvider>(context);

    return Scaffold(
      body: journalProvider.records.isEmpty
          ? const Center(
        child: Text('У вас пока нет записей. Нажмите +, чтобы добавить.'),
      )
          : ListView.builder(
        itemCount: journalProvider.records.length,
        itemBuilder: (context, index) {
          final record = journalProvider.records[index];
          return Dismissible(
            key: Key(record.id.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) => _confirmDelete(context),
            onDismissed: (direction) {
              journalProvider.deleteRecord(record.id!, record.userId);
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: record.photoPath != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(record.photoPath!),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 50),
                  ),
                )
                    : null,
                title: Text(record.placeName),
                subtitle: Text(
                  '${record.date.day}.${record.date.month}.${record.date.year}'
                      '${record.weatherCondition != null && record.temperature != null ? '\n🌡️ ${record.weatherCondition}, ${record.temperature!.toInt()}°C' : ''}',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditRecordScreen(record: record),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditRecordScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}