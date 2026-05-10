import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/local/field_log_db.dart';
import '../data/remote/weather_api.dart';
import '../model/field_log.dart';
import '../services/location_service.dart';
import '../services/media_service.dart';
import '../services/permission_service.dart';

class FieldLogController extends ChangeNotifier {
  FieldLogController({
    FieldLogDb? db,
    LocationService? locationService,
    WeatherApi? weatherApi,
    MediaService? mediaService,
    PermissionService? permissionService,
    Uuid? uuid,
  }) : _db = db ?? FieldLogDb.instance,
       _weather = weatherApi ?? WeatherApi(),
       _media = mediaService ?? MediaService(),
       _permission = permissionService ?? PermissionService(),
       _uuid = uuid ?? Uuid(),
       _location = locationService ?? LocationService();

  final FieldLogDb _db;
  final WeatherApi _weather;
  final MediaService _media;
  final PermissionService _permission;
  final LocationService _location;
  final Uuid _uuid;

  List<FieldLog> _logs = [];
  bool loading = false;
  String? error;

  List<FieldLog> get logs => List.unmodifiable(_logs);

  Future<void> refresh() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      _logs = await _db.getAllByNewestFirst();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> createLog({
    required String notes,
    String? localImagePath,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final position = await _location.getCurrentPosition();
      final now = DateTime.now();
      final id = _uuid.v4();

      var log = FieldLog(
        id: id,
        notes: notes,
        latitude: position.latitude,
        longitude: position.longitude,
        createdAt: now,
        updatedAt: now,
        syncedToServer: 0,
        userId: null,
        weatherDescription: null,
        localImagePath: localImagePath,
        remoteImagePath: null,
      );

      await _db.insert(log);
      await refresh();
      _fetchWeatherForLog(log);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteLog(String id) async {
    await _db.delete(id);
    await refresh();
  }

  Future<void> updateLog(FieldLog updatedLog) async {
    await _db.update(updatedLog);
    await refresh();
  }

  Future<void> _fetchWeatherForLog(FieldLog log) async {
    try {
      final summary = await _weather.fetchSummary(
        latitude: log.latitude,
        longitude: log.longitude,
      );
      final updated = log.copyWith(
        weatherDescription: summary,
        updatedAt: DateTime.now(),
      );
      await _db.update(updated);
      await refresh();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<String?> pickImageFromCamera() async {
    final ok = await _permission.ensureCamera();
    if (!ok) {
      error = 'Camera permission denied';
      notifyListeners();
      return null;
    }
    return _media.pickFromCamera();
  }

  Future<String?> pickImageFromGallery() async {
    return _media.pickFromGallery();
  }
}
