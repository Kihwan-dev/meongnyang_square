import 'package:meongnyang_square/domain/entities/auth_user.dart';

abstract interface class AuthRepository {
  Future<AuthUser> login(String email, String password);
  Future<AuthUser> join(String email, String password);
  Future<void> logout();
}