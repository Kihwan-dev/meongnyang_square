// DataSource
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meongnyang_square/data/data_sources/auth_data_source_impl.dart';
import 'package:meongnyang_square/data/repositories/auth_repository_impl.dart';
import 'package:meongnyang_square/domain/repositories/auth_repository.dart';

//Auth인증-DataSource용 생성자
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Auth인증-DataSource
final authDataSourceProvider = Provider((ref) {
  return AuthDataSourceImpl(auth: ref.watch(firebaseAuthProvider));
},);

// Auth인증-Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(authDataSource: ref.watch(authDataSourceProvider));
},);