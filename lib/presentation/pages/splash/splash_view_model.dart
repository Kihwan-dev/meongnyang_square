import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meongnyang_square/domain/entities/auth_user.dart';
import 'package:meongnyang_square/domain/repositories/auth_repository.dart';
import 'package:meongnyang_square/presentation/providers.dart';

class AuthState {
  final AuthUser? user;
  AuthState({required this.user});
}

class AuthViewModel extends Notifier<AuthState?> {
  late final AuthRepository authRepository;

  @override
  AuthState? build() {
    authRepository = ref.read(authRepositoryProvider);
    return null;
  }

  Future<AuthUser> login(String email, String password) async {
    final user = await authRepository.login(email, password);
    state = AuthState(user: user);
    return user;
  }

  Future<AuthUser> join(String email, String password) async {
    final user = await authRepository.join(email, password);
    state = AuthState(user: user);
    return user;
  }

}

final authViewModelProvider =
    NotifierProvider<AuthViewModel, AuthState?>(() => AuthViewModel());