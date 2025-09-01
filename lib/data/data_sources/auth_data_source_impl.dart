import 'package:firebase_auth/firebase_auth.dart';
import 'package:meongnyang_square/data/data_sources/auth_data_source.dart';

class AuthDataSourceImpl implements AuthDataSource {
  final FirebaseAuth auth;
  AuthDataSourceImpl({required this.auth});

  @override
  Future<UserCredential> login(String email, String password) {
    return auth.signInWithEmailAndPassword(
      email: email, password: password,
    );
  }

  @override
  Future<UserCredential> join(String email, String password) {
    return auth.createUserWithEmailAndPassword(
      email: email, password: password,
    );
  }
}