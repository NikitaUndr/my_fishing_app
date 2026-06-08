import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherService {
  // 🔧 ЗАМЕНИТЕ ЭТУ СТРОКУ НА ВАШ API-КЛЮЧ
  static const String _apiKey = 'ae39a0fe1043055a0c871f2894405f00';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  /// Получает текущую погоду по координатам.
  /// Возвращает Map с температурой (в °C) и описанием погоды.
  static Future<Map<String, dynamic>?> getWeather(double lat, double lon) async {
    try {
      final url = Uri.parse(
          '$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=ru');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'temperature': data['main']['temp'],
          'condition': data['weather'][0]['description'],
        };
      } else {
        print('Ошибка получения погоды: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Ошибка сети при запросе погоды: $e');
      return null;
    }
  }
}