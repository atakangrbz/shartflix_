// user_event.dart

abstract class UserEvent {}

class LoginUser extends UserEvent {
  final String email;
  final String password;

  LoginUser({required this.email, required this.password});
}
class FetchUserProfile extends UserEvent {
  final String token;

  FetchUserProfile({required this.token});
}


class RegisterUser extends UserEvent {
  final String name;
  final String email;
  final String password;

  RegisterUser({
    required this.name,
    required this.email,
    required this.password,
  });
}
