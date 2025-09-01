import 'dart:typed_data';

abstract interface class StorageRepository {
  Future<String> uploadFeedImage(Uint8List imageData);
  Future<bool> deleteFeedImage(String imagePath);
}
