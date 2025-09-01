// DataSource
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meongnyang_square/data/data_sources/auth_data_source_impl.dart';
import 'package:meongnyang_square/data/data_sources/feed_remote_data_source_impl.dart';
import 'package:meongnyang_square/data/data_sources/storage_data_source_impl.dart';
import 'package:meongnyang_square/data/repositories/auth_repository_impl.dart';
import 'package:meongnyang_square/data/repositories/feed_repository_impl.dart';
import 'package:meongnyang_square/data/repositories/storage_repository_impl.dart';
import 'package:meongnyang_square/domain/entities/feed.dart';
import 'package:meongnyang_square/domain/repositories/auth_repository.dart';
import 'package:meongnyang_square/domain/repositories/feed_repository.dart';
import 'package:meongnyang_square/domain/repositories/storage_repository.dart';
import 'package:meongnyang_square/domain/use_cases/delete_image_use_case.dart';
import 'package:meongnyang_square/domain/use_cases/upload_image_use_case.dart';
import 'package:meongnyang_square/domain/use_cases/upsert_feed_use_case.dart';
import 'package:meongnyang_square/presentation/pages/write/write_view_model.dart';

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

// Feed Repository
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepositoryImpl(ref.watch(feedRemoteDataSourceProvider));
});

// Upsert Feed Use Case
final upsertFeedUseCaseProvider = Provider((ref) {
  return UpsertFeedUseCase(ref.watch(feedRepositoryProvider));
});

// Storage DataSource
final storageDataSourceProvider = Provider((ref) {
  return StorageDataSourceImpl();
});

// Storage Repository
final storageRepositoryImpl = Provider<StorageRepository>((ref) {
  return StorageRepositoryImpl(ref.watch(storageDataSourceProvider));
});

// Upload Image Use Case
final uploadImageUseCaseProvider = Provider((ref) {
  return UploadImageUseCase(ref.watch(storageRepositoryImpl));
});

// Delete Image Use Case
final deleteImageUseCaseProvider = Provider((ref) {
  return DeleteImageUseCase(ref.watch(storageRepositoryImpl));
});

// Write ViewModel Provider
final writeViewModelProvider = NotifierProvider.autoDispose.family<WriteViewModel, WriteState, Feed?>(
  () => WriteViewModel(),
);
