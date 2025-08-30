import 'package:meongnyang_square/data/data_sources/auth_data_source.dart';
import 'package:meongnyang_square/domain/entities/auth_user.dart';
import 'package:meongnyang_square/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource authDataSource;
  AuthRepositoryImpl({required this.authDataSource});

  @override
  Future<AuthUser> login(String email, String password) async {
    final checkUser = await authDataSource.login(email, password);
    final user = checkUser.user;
    if (user == null) throw StateError('login 에러: user가 없음');
    
    return AuthUser(
      uid: user.uid,
      email: user.email,
    );
    
  }

  @override
  Future<AuthUser> join(String email, String password) async{
    final checkUser = await authDataSource.join(email, password);
    final user = checkUser.user;
    if (user == null) throw StateError('join 에러: user가 없음');
    
    return AuthUser(
      uid: user.uid,
      email: user.email,
    );

  }
}