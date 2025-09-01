import 'dart:typed_data';
import 'package:meongnyang_square/domain/repositories/feed_repository.dart';

class UploadImageUseCase {
  UploadImageUseCase(this._feedRepository);
  final FeedRepository _feedRepository;

  Future<String> execute(Uint8List imageData) async {
    return await _feedRepository.uploadFeedImage(imageData);
  }
}
