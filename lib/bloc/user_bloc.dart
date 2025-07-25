import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_event.dart';
import 'user_state.dart';
import '../data/user_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;

  UserBloc({required this.repository}) : super(UserInitial()) {
    on<FetchUserProfile>(_onFetchUserProfile);
  }

  Future<void> _onFetchUserProfile(FetchUserProfile event, Emitter<UserState> emit) async {
    emit(UserLoadInProgress());

    try {
      final user = await repository.fetchUserProfile();
      emit(UserLoadSuccess(user));
    } catch (e) {
      emit(UserLoadFailure(e.toString()));
    }
  }
}
