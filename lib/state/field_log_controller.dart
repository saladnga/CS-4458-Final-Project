import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/local/field_log_db.dart';
import '../data/remote/weather_api.dart';
import '../model/field_log.dart';
import '../services/location_service.dart';
import '../services/media_service.dart';
import '../services/permission_service.dart';
import '../data/remote/field_log_remote.dart';

class FieldLogController extends ChangeNotifier {
  FieldLogController({
    required this.userId,
    FieldLogRemote? remote,
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
       _location = locationService ?? LocationService(),
       _remote = remote ?? FieldLogRemote();

  final FieldLogDb _db;
  final WeatherApi _weather;
  final MediaService _media;
  final PermissionService _permission;
  final LocationService _location;
  final Uuid _uuid;
  final String userId;
  final FieldLogRemote _remote;

  List<FieldLog> _logs = [];
  bool loading = false;
  String? error;

  List<FieldLog> get logs => List.unmodifiable(_logs);

  Future<void> refresh() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      var local = await _db.getAllByNewestFirst(userId);
      if (local.isEmpty) {
        final remote = await _remote.fetchAll(userId);
        for (final log in remote) {
          await _db.insert(log);
        }
        local = await _db.getAllByNewestFirst(userId);
      }
      _logs = local;
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
        userId: userId,
        weatherDescription: null,
        localImagePath: localImagePath,
        remoteImagePath: null,
      );

      await _db.insert(log);

      if (localImagePath != null) {
        final url = await _media.uploadImage(localImagePath, userId, id);
        log = log.copyWith(remoteImagePath: url, syncedToServer: 1);
        await _db.update(log);
      }

      final synced = log.copyWith(syncedToServer: 1);
      await _remote.upsert(synced);
      await _db.update(synced);

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
    await _remote.delete(userId, id);
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
      await _remote.upsert(updated);
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
