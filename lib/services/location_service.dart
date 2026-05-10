import 'package:geolocator/geolocator.dart';
import 'permission_service.dart';

class LocationService {
  LocationService({PermissionService? permissionService})
    : _permission = permissionService ?? PermissionService();

  final PermissionService _permission;

  Future<({double latitude, double longitude})> getCurrentPosition() async {
    final allowed = await _permission.ensureLocation();
    if (!allowed) {
      throw StateError('Location permission denied');
    }

    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw StateError('Location services are disabled');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    return (latitude: position.latitude, longitude: position.longitude);
  }
}
