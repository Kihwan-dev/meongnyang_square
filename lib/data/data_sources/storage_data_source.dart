import 'dart:typed_data';

abstract interface class StorageDataSource {
  Future<String> uploadImage(Uint8List imageData, String fileName);
  Future<bool> deleteImage(String imagePath);
}
