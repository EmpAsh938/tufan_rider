import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tufan_rider/features/auth/repository/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final data = await _repository.login(email, password);
      emit(AuthSuccess(data));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
