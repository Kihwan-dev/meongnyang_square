import 'dart:typed_data';

import 'package:meongnyang_square/domain/use_cases/feed_params.dart';

abstract interface class FeedRepository {
  Future<void> upsertFeed(FeedParams feedParams);
  Future<String> uploadFeedImage(Uint8List imageData);
}
