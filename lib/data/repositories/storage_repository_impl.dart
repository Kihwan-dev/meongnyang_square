import 'dart:typed_data';
import 'package:meongnyang_square/data/data_sources/storage_data_source.dart';
import 'package:meongnyang_square/domain/repositories/storage_repository.dart';

// 핵심은 DataSource를 받아와서 DataSource내부의 함수를 사용한다는 것!
class StorageRepositoryImpl implements StorageRepository {
  StorageRepositoryImpl(this._storageDataSource);
  final StorageDataSource _storageDataSource;

  @override
  Future<String> uploadFeedImage(Uint8List imageData) async {
    final fileName = "feed_${DateTime.now().millisecondsSinceEpoch}.jpg";
    return await _storageDataSource.uploadImage(imageData, fileName);
  }

  @override
  Future<bool> deleteFeedImage(String imagePath) async {
    return await _storageDataSource.deleteImage(imagePath);
  }
}
