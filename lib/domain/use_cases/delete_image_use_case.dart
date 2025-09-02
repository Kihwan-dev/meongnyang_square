import 'package:meongnyang_square/domain/repositories/storage_repository.dart';

class DeleteImageUseCase {
  DeleteImageUseCase(this._storageRepository);
  final StorageRepository _storageRepository;

  Future<bool> execute(String imagePath) async {
    return await _storageRepository.deleteFeedImage(imagePath);
  }
}
