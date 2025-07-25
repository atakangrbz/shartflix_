// user_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_event.dart';
import 'user_state.dart';
import '../data/user_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc({required this.userRepository}) : super(UserInitial()) {
    // LOGIN işlemi
    on<FetchUserProfile>((event, emit) async {
  emit(UserLoading());
  try {
    final profile = await userRepository.getProfile(event.token);
    emit(UserProfileLoaded(profile));
  } catch (e) {
    emit(UserError('Profil alınamadı'));
  }
});

    on<LoginUser>((event, emit) async {
      emit(UserLoading());
      try {
        final user = await userRepository.login(event.email, event.password);
        emit(UserLoggedIn(user));
      } catch (e) {
        emit(UserError('Giriş başarısız'));
      }
    });

    // REGISTER işlemi — BUNU EKLE!
    on<RegisterUser>((event, emit) async {
      emit(UserLoading());
      try {
        final user = await userRepository.register(event.name, event.email, event.password);
        emit(UserLoggedIn(user));
      } catch (e) {
        emit(UserError('Kayıt başarısız'));
      }
    });
  }
}
