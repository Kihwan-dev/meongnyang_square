import 'dart:typed_data';
import 'package:meongnyang_square/domain/repositories/storage_repository.dart';

class UploadImageUseCase {
  UploadImageUseCase(this._storageRepository);
  final StorageRepository _storageRepository;

  Future<String> execute(Uint8List imageData) async {
    return await _storageRepository.uploadFeedImage(imageData);
  }
}
