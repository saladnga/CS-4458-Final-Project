import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();

  // Camera
  Future<String?> pickFromCamera() async {
    final file = await _picker.pickImage(source: ImageSource.camera);
    return file?.path;
  }

  // Gallery
  Future<String?> pickFromGallery() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    return file?.path;
  }

  // Upload through Firebase
  Future<String> uploadImage(
    String localPath,
    String userId,
    String logId,
  ) async {
    final file = File(localPath);
    final ref = FirebaseStorage.instance.ref().child('logs/$userId/$logId.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
