import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/journal_provider.dart';
import '../models/fishing_record.dart';
import 'add_edit_record_screen.dart';

class AllPointsMapScreen extends StatefulWidget {
  const AllPointsMapScreen({super.key});

  @override
  State<AllPointsMapScreen> createState() => _AllPointsMapScreenState();
}

class _AllPointsMapScreenState extends State<AllPointsMapScreen> {
  bool _permissionGranted = false;
  YandexMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      setState(() => _permissionGranted = true);
    } else if (status.isPermanentlyDenied) {
      _showPermissionDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Для отображения карты нужно разрешение геолокации')),
      );
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Разрешение необходимо'),
        content: const Text('Для работы карты нужно разрешение на определение местоположения. Пожалуйста, разрешите в настройках.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Открыть настройки'),
          ),
        ],
      ),
    );
  }

  Future<void> _goToCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Включите службы геолокации')),
      );
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Разрешение отклонено')),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Разрешение отключено навсегда. Включите в настройках.')),
      );
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    if (_mapController != null) {
      await _mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: Point(latitude: position.latitude, longitude: position.longitude),
            zoom: 15,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final journalProvider = Provider.of<JournalProvider>(context);
    final records = journalProvider.records;

    if (!_permissionGranted) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Для работы карты необходимо разрешение геолокации'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _requestPermissions,
                child: const Text('Запросить разрешение'),
              ),
            ],
          ),
        ),
      );
    }

    // Создаём маркеры для записей с координатами, используя ту же иконку
    final markers = records
        .where((r) => r.latitude != 0 && r.longitude != 0)
        .map((record) {
      return PlacemarkMapObject(
        mapId: MapObjectId(record.id.toString()),
        point: Point(latitude: record.latitude, longitude: record.longitude),
        opacity: 1,
        // ДОБАВЛЕНА ИКОНКА маркера – такая же, как на экране выбора места
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage('assets/images/marker.png'),
            scale: 0.1,   // подберите подходящий масштаб
          ),
        ),
        onTap: (_, __) => _showRecordDetails(context, record),
      );
    }).toList();

    if (markers.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Нет точек для отображения')),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          YandexMap(
            onMapCreated: (controller) async {
              _mapController = controller;
              // Центрируем карту по первой точке
              await controller.moveCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: markers.first.point, zoom: 12),
                ),
              );
            },
            mapObjects: markers,
          ),
          // Кнопка "Моё местоположение"
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _goToCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }

  void _showRecordDetails(BuildContext context, FishingRecord record) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record.placeName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Дата: ${record.date.day}.${record.date.month}.${record.date.year}'),
            if (record.catchDetails != null && record.catchDetails!.isNotEmpty)
              Text('Улов: ${record.catchDetails}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditRecordScreen(record: record),
                      ),
                    );
                  },
                  child: const Text('Редактировать'),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Закрыть'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}