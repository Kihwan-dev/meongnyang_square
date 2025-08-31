// lib/data/data_sources/storage_data_source_impl.dart
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meongnyang_square/data/data_sources/storage_data_source.dart';

class StorageDataSourceImpl implements StorageDataSource {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<String> uploadImage(Uint8List imageData, String fileName) async {
    try {
      final ref = _storage.ref("feed_images/$fileName");
      await ref.putData(imageData);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print(e);
      return "";
    }
  }

  @override
  Future<void> deleteImage(String imagePath) async {
    try {
      if (imagePath.isNotEmpty) {
        final ref = _storage.refFromURL(imagePath);
        await ref.delete();
      }
    } catch (e) {
      print(e);
    }
  }
}
