import 'dart:convert';

import 'package:http/http.dart' as http;

class WeatherApi {
  final http.Client _client;
  WeatherApi({http.Client? client}) : _client = client ?? http.Client();
  Future<String> fetchSummary({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,weather_code',
    );

    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Weather HTTP ${res.statusCode}');
    }

    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final curr = map['current'] as Map<String, dynamic>?;
    if (curr == null) throw Exception('Weather response missing');

    final temp = (curr['temperature_2m'] as num?)?.toDouble();
    final code = (curr['weather_code'] as num?)?.toInt();

    final label = _weatherCodeLabel(code);
    if (temp != null) {
      return '${temp.round()}°C - $label';
    }
    return label;
  }

  String _weatherCodeLabel(int? code) {
    switch (code) {
      case 0:
        return 'Clear';
      case 1:
      case 2:
      case 3:
        return 'Partly Cloudy';
      case 45:
      case 48:
        return 'Fog';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorm';
      default:
        return 'Weather code $code';
    }
  }
}
