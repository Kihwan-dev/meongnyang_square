// DataSource
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meongnyang_square/data/data_sources/auth_data_source_impl.dart';
import 'package:meongnyang_square/data/data_sources/feed_remote_data_source_impl.dart';
import 'package:meongnyang_square/data/data_sources/storage_data_source_impl.dart';
import 'package:meongnyang_square/data/repositories/auth_repository_impl.dart';
import 'package:meongnyang_square/data/repositories/feed_repository_impl.dart';
import 'package:meongnyang_square/domain/repositories/auth_repository.dart';
import 'package:meongnyang_square/domain/repositories/feed_repository.dart';
import 'package:meongnyang_square/domain/use_cases/upload_image_use_case.dart';
import 'package:meongnyang_square/domain/use_cases/upsert_feed_use_case.dart';

/* 사용자 인증 */
//Auth인증-DataSource용 생성자
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Auth인증-DataSource
final authDataSourceProvider = Provider(
  (ref) {
    return AuthDataSourceImpl(auth: ref.watch(firebaseAuthProvider));
  },
);

// Auth인증-Repository
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) {
    return AuthRepositoryImpl(authDataSource: ref.watch(authDataSourceProvider));
  },
);

/* 피드 및 이미지 관련 */
// Feed DataSource
final feedRemoteDataSourceProvider = Provider((ref) {
  return FeedRemoteDataSourceImpl();
});

// Storage DataSource
final storageDataSourceProvider = Provider((ref) {
  return StorageDataSourceImpl();
});

// Feed Repository
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepositoryImpl(
    ref.watch(feedRemoteDataSourceProvider),
    ref.watch(storageDataSourceProvider),
  );
});

// Upload Image Use Case
final uploadImageUseCaseProvider = Provider((ref) {
  return UploadImageUseCase(ref.watch(feedRepositoryProvider));
});

// Upsert Feed Use Case
final upsertFeedUseCaseProvider = Provider((ref) {
  return UpsertFeedUseCase(ref.watch(feedRepositoryProvider));
});
