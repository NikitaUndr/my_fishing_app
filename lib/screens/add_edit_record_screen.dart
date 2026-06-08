import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/fishing_record.dart';
import '../providers/auth_provider.dart';
import '../providers/journal_provider.dart';
import 'yandex_map_picker_screen.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../service/weather_service.dart';

class AddEditRecordScreen extends StatefulWidget {
  final FishingRecord? record;
  const AddEditRecordScreen({super.key, this.record});

  @override
  State<AddEditRecordScreen> createState() => _AddEditRecordScreenState();
}

class _AddEditRecordScreenState extends State<AddEditRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _placeController;
  late TextEditingController _tackleController;
  late TextEditingController _baitController;
  late TextEditingController _catchController;
  late DateTime _selectedDate;
  bool _isLoading = false;
  double _latitude = 0.0;
  double _longitude = 0.0;
  File? _imageFile; // для фото

  @override
  void initState() {
    super.initState();
    _placeController = TextEditingController(text: widget.record?.placeName ?? '');
    _tackleController = TextEditingController(text: widget.record?.tackle ?? '');
    _baitController = TextEditingController(text: widget.record?.bait ?? '');
    _catchController = TextEditingController(text: widget.record?.catchDetails ?? '');
    _selectedDate = widget.record?.date ?? DateTime.now();

    if (widget.record != null) {
      _latitude = widget.record!.latitude;
      _longitude = widget.record!.longitude;
      if (widget.record!.photoPath != null && widget.record!.photoPath!.isNotEmpty) {
        _imageFile = File(widget.record!.photoPath!);
      }
    }
  }

  @override
  void dispose() {
    _placeController.dispose();
    _tackleController.dispose();
    _baitController.dispose();
    _catchController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => YandexMapPickerScreen(
          initialPoint: _latitude != 0 && _longitude != 0
              ? Point(latitude: _latitude, longitude: _longitude)
              : null,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _placeController.text = result['address'];
        _latitude = result['lat'];
        _longitude = result['lng'];
      });
    }
  }

  // Выбор фото из камеры или галереи
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
      final savedPath = path.join(appDir.path, fileName);
      final File imageFile = File(pickedFile.path);
      await imageFile.copy(savedPath);
      setState(() {
        _imageFile = File(savedPath);
      });
    }
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Камера'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Галерея'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final journalProvider = Provider.of<JournalProvider>(context, listen: false);

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка: пользователь не авторизован')),
      );
      setState(() => _isLoading = false);
      return;
    }
    // --- НОВЫЙ КОД: ЗАПРОС ПОГОДЫ ---
    double? temperature;
    String? weatherCondition;
    if (_latitude != 0 && _longitude != 0) {
      final weatherData = await WeatherService.getWeather(_latitude, _longitude);
      if (weatherData != null) {
        temperature = weatherData['temperature'];
        weatherCondition = weatherData['condition'];
        // Опционально: показать уведомление об успешной загрузке погоды
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Погода: $weatherCondition, $temperature°C')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось получить погоду для этого места')),
        );
      }
    }

    final record = FishingRecord(
      id: widget.record?.id,
      userId: authProvider.user!.uid,
      date: _selectedDate,
      placeName: _placeController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      tackle: _tackleController.text.trim().isEmpty ? null : _tackleController.text.trim(),
      bait: _baitController.text.trim().isEmpty ? null : _baitController.text.trim(),
      catchDetails: _catchController.text.trim().isEmpty ? null : _catchController.text.trim(),
      temperature: temperature,
      weatherCondition:  weatherCondition,
      photoPath: _imageFile?.path,
    );

    try {
      if (widget.record == null) {
        await journalProvider.addRecord(record);
      } else {
        await journalProvider.updateRecord(record);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      print('Ошибка сохранения: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.record == null ? 'Новая запись' : 'Редактировать'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                title: const Text('Дата рыбалки'),
                subtitle: Text('${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _placeController,
                decoration: InputDecoration(
                  labelText: 'Место',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.map),
                    onPressed: _pickLocation,
                    tooltip: 'Выбрать на карте',
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Введите место' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tackleController,
                decoration: const InputDecoration(
                  labelText: 'Снасти (необязательно)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _baitController,
                decoration: const InputDecoration(
                  labelText: 'Приманки (необязательно)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _catchController,
                decoration: const InputDecoration(
                  labelText: 'Улов (необязательно)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // Кнопка добавления фото
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Добавить фото'),
                      onPressed: _showImagePickerDialog,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200]),
                    ),
                  ),
                ],
              ),
              // Предпросмотр фото
              if (_imageFile != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_imageFile!, height: 150, width: double.infinity, fit: BoxFit.cover),
                ),
              ],
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(onPressed: _save, child: const Text('Сохранить')),
            ],
          ),
        ),
      ),
    );
  }
}