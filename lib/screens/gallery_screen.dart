import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/journal_provider.dart';
import 'full_screen_photo_viewer.dart'; // импортируем новый экран

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final journalProvider = Provider.of<JournalProvider>(context);
    final records = journalProvider.records;

    // Получаем все записи, у которых есть фото и файл существует
    final photos = records.where((r) {
      if (r.photoPath == null) return false;
      final file = File(r.photoPath!);
      return file.existsSync();
    }).toList();

    if (photos.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Галерея улова')),
        body: const Center(child: Text('Нет фотографий. Добавьте фото в записи.')),
      );
    }

    // Создаём список путей ко всем фото (для передачи в просмотрщик)
    final List<String> allPhotoPaths = photos.map((r) => r.photoPath!).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Галерея улова')),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final record = photos[index];
          return GestureDetector(
            onTap: () {
              // Открываем полноэкранный просмотр с возможностью листать
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenPhotoViewer(
                    photoPaths: allPhotoPaths,
                    initialIndex: allPhotoPaths.indexOf(record.photoPath!),
                  ),
                ),
              );
            },
            child: Hero(
              tag: record.photoPath!,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(record.photoPath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 50),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}