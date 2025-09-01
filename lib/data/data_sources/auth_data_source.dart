import 'package:firebase_auth/firebase_auth.dart';

abstract interface class AuthDataSource {
  Future<UserCredential> login(String email, String password);
  Future<UserCredential> join(String email, String password);
}