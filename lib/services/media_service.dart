import 'package:image_picker/image_picker.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickFromCamera() async {
    final file = await _picker.pickImage(source: ImageSource.camera);
    return file?.path;
  }

  Future<String?> pickFromGallery() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    return file?.path;
  }
}
