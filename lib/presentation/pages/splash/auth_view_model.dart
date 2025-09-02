import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meongnyang_square/domain/entities/auth_user.dart';
import 'package:meongnyang_square/domain/repositories/auth_repository.dart';
import 'package:meongnyang_square/presentation/providers.dart';

class AuthState {
  final AuthUser? user;
  final bool isUser;
  final bool isLoading;
  AuthState(
      {required this.user, required this.isUser, required this.isLoading});
}

class AuthViewModel extends Notifier<AuthState> {
  late final AuthRepository authRepository;

  @override
  AuthState build() {
    authRepository = ref.read(authRepositoryProvider);
    return AuthState(user: null, isUser: true, isLoading: false);
  }

  //모드전환
  void setMode(bool isUser) {
    state = AuthState(user: state.user, isUser: isUser, isLoading: state.isLoading);
  }

  //로그인
  Future<AuthUser> login(String email, String password) async {
    state = AuthState(
        user: state.user, isUser: state.isUser, isLoading: true); // 로딩 시작
    try {
      final user = await authRepository.login(email, password);
      state =
          AuthState(user: user, isUser: true, isLoading: false); // 성공 후 상태 업데이트
      return user;
    } catch (e) {
      state =
          AuthState(user: null, isUser: state.isUser, isLoading: false); // 실패
      rethrow;
    }
  }

  //회원가입
  Future<AuthUser> join(String email, String password) async {
    state = AuthState(
        user: state.user, isUser: state.isUser, isLoading: true); // 로딩 시작
    try {
      final user = await authRepository.join(email, password);
      state =
          AuthState(user: user, isUser: true, isLoading: false); // 성공 후 상태 업데이트
      return user;
    } catch (e) {
      state =
          AuthState(user: null, isUser: state.isUser, isLoading: false); // 실패
      rethrow;
    }
  }

  /// 세션이 남아있을 때, 그 유저정보만 상태에 반영
  void setSessionUser(AuthUser? user) {
    state = AuthState(
      user: user,
      isUser: state.isUser, 
      isLoading: false,      
    );
  }

}

final authViewModelProvider =
    NotifierProvider<AuthViewModel, AuthState>(() => AuthViewModel());
