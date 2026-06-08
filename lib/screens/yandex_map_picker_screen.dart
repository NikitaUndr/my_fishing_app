import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class YandexMapPickerScreen extends StatefulWidget {
  final Point? initialPoint;
  const YandexMapPickerScreen({super.key, this.initialPoint});

  @override
  State<YandexMapPickerScreen> createState() => _YandexMapPickerScreenState();
}

class _YandexMapPickerScreenState extends State<YandexMapPickerScreen> {
  final MapObjectId _placemarkId = const MapObjectId('selected_point');
  YandexMapController? _mapController;
  Point? _selectedPoint;
  String _address = 'Нажмите на карту, чтобы выбрать место';
  final String _apiKey = 'c0b752cb-8a4a-4306-88d2-0dca3489fe90'; // замените на свой ключ
  bool _permissionGranted = false;

  // Для поиска
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Скрываем системные кнопки навигации
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _requestPermissions();
    if (widget.initialPoint != null) {
      _selectedPoint = widget.initialPoint;
      _address = 'Выбранная точка';
    }
  }

  @override
  void dispose() {
    // Восстанавливаем стандартный режим
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      setState(() => _permissionGranted = true);
    } else if (status.isPermanentlyDenied) {
      _showPermissionDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Для работы карты нужно разрешение геолокации')),
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

  // Поиск места по тексту
  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _isSearching = true;
      _address = 'Поиск...';
    });

    try {
      final url = Uri.parse(
        'https://geocode-maps.yandex.ru/1.x/?apikey=$_apiKey&geocode=$query&format=json&lang=ru_RU',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['response']['GeoObjectCollection']['featureMember'];
        if (features.isNotEmpty) {
          final geoObject = features[0]['GeoObject'];
          final pos = geoObject['Point']['pos'].split(' ');
          final double lon = double.parse(pos[0]);
          final double lat = double.parse(pos[1]);
          final address = geoObject['metaDataProperty']['GeocoderMetaData']['text'];
          final point = Point(latitude: lat, longitude: lon);

          setState(() {
            _selectedPoint = point;
            _address = address;
            _isSearching = false;
          });

          if (_mapController != null) {
            await _mapController!.moveCamera(
              CameraUpdate.newCameraPosition(CameraPosition(target: point, zoom: 15)),
            );
          }
        } else {
          setState(() {
            _address = 'Ничего не найдено';
            _isSearching = false;
          });
        }
      } else {
        setState(() {
          _address = 'Ошибка поиска';
          _isSearching = false;
        });
      }
    } catch (e) {
      print('Ошибка поиска: $e');
      setState(() {
        _address = 'Ошибка сети';
        _isSearching = false;
      });
    }
  }

  // Текущее местоположение
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
    final newPoint = Point(latitude: position.latitude, longitude: position.longitude);
    if (_mapController != null) {
      await _mapController!.moveCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: newPoint, zoom: 15)),
      );
    }
    setState(() => _selectedPoint = newPoint);
    await _getAddressFromPoint(newPoint);
  }

  // Обратное геокодирование (координаты -> адрес)
  Future<void> _getAddressFromPoint(Point point) async {
    setState(() => _address = 'Определяем адрес...');
    try {
      final url = Uri.parse(
        'https://geocode-maps.yandex.ru/1.x/?apikey=$_apiKey&geocode=${point.longitude},${point.latitude}&format=json&lang=ru_RU',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final geoObject = data['response']['GeoObjectCollection']['featureMember'][0]['GeoObject'];
        final address = geoObject['metaDataProperty']['GeocoderMetaData']['text'];
        setState(() => _address = address);
      } else {
        setState(() => _address = 'Ошибка геокодера');
      }
    } catch (e) {
      print(e);
      setState(() => _address = 'Ошибка сети');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите место на карте'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск места (город, река, улица)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
                    : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: _searchLocation,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _goToCurrentLocation,
          ),
        ],
      ),
      body: _permissionGranted
          ? Stack(
        children: [
          YandexMap(
            onMapCreated: (controller) async {
              _mapController = controller;
              if (_selectedPoint != null) {
                await controller.moveCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: _selectedPoint!, zoom: 15),
                  ),
                );
              }
            },
            onMapTap: (point) async {
              setState(() => _selectedPoint = point);
              await _getAddressFromPoint(point);
            },
            mapObjects: [
              if (_selectedPoint != null)
                PlacemarkMapObject(
                  mapId: _placemarkId,
                  point: _selectedPoint!,
                  opacity: 1,
                  icon: PlacemarkIcon.single(
                    PlacemarkIconStyle(
                      image: BitmapDescriptor.fromAssetImage('assets/images/marker.png'),
                      scale: 0.1,
                    )
                  )

                ),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _goToCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      )
          : Center(
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
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_address, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _selectedPoint == null
                  ? null
                  : () => Navigator.pop(context, {
                'lat': _selectedPoint!.latitude,
                'lng': _selectedPoint!.longitude,
                'address': _address,
              }),
              child: const Text('Выбрать это место'),
            ),
          ],
        ),
      ),
    );
  }
}