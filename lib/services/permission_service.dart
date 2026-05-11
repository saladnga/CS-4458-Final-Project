import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Ask for Camera
  Future<bool> ensureCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Ask to use location
  Future<bool> ensureLocation() async {
    var status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) {
      status = await Permission.locationWhenInUse.request();
    }
    return status.isGranted;
  }
}
