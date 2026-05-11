import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherApi {
  final http.Client _client;
  WeatherApi({http.Client? client}) : _client = client ?? http.Client();

  // Fetch the weather info
  Future<String> fetchSummary({
    required double latitude,
    required double longitude,
  }) async {
    // Call Open Meteo Weather API
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,weather_code,apparent_temperature,wind_speed_10m,cloud_cover,precipitation,surface_pressure',
    );

    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Weather HTTP ${res.statusCode}');
    }

    final map = jsonDecode(res.body) as Map<String, dynamic>;

    // Fetch all weather infos from the API
    final curr = map['current'] as Map<String, dynamic>?;
    if (curr == null) throw Exception('Weather response missing');
    final temp = (curr['temperature_2m'] as num?)?.toDouble();
    final humidity = (curr['relative_humidity_2m'] as num?)?.toInt();
    final apparent = (curr['apparent_temperature'] as num?)?.toDouble();
    final wind = (curr['wind_speed_10m'] as num?)?.toDouble();
    final clouds = (curr['cloud_cover'] as num?)?.toInt();
    final precip = (curr['precipitation'] as num?)?.toDouble();
    final pressure = (curr['surface_pressure'] as num?)?.toDouble();
    final code = (curr['weather_code'] as num?)?.toInt();
    final label = _weatherCodeLabel(code);

    // Merge into a String array
    final parts = <String>[];

    if (temp != null) {
      parts.add('Temperature: ${temp.round()}°C - $label');
    } else {
      parts.add(label);
    }

    if (humidity != null) {
      parts.add('Humidity: $humidity%');
    }
    if (apparent != null) {
      parts.add('Feels like: ${apparent.round()}°C');
    }
    if (wind != null) {
      parts.add('Wind: ${wind.round()} km/h');
    }
    if (clouds != null) {
      parts.add('Clouds: $clouds%');
    }
    if (precip != null && precip > 0) {
      parts.add('Precipitation: $precip mm');
    }
    if (pressure != null) {
      parts.add('Pressure: ${pressure.round()} hPa');
    }

    return parts.join('\n');
  }

  // Codes for determining the weather
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
