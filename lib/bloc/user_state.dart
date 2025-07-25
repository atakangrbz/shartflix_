import '../domain/user.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoadInProgress extends UserState {}

class UserLoadSuccess extends UserState {
  final User user;

  UserLoadSuccess(this.user);
}

class UserLoadFailure extends UserState {
  final String error;

  UserLoadFailure(this.error);
}
