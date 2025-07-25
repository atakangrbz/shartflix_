abstract class UserState {}

// Uygulama ilk yüklendiğinde veya hiçbir işlem yapılmamışken
class UserInitial extends UserState {}

// API çağrıları sırasında kullanılan yükleniyor durumu
class UserLoading extends UserState {}

// Giriş başarılı olduğunda kullanıcı verileri burada tutulur
class UserLoggedIn extends UserState {
  final Map<String, dynamic> user;

  UserLoggedIn(this.user);
}

// Profil özel olarak yüklendiğinde kullanılan durum
class UserProfileLoaded extends UserState {
  final Map<String, dynamic> profile;

  UserProfileLoaded(this.profile);
}

// Hata olduğunda bu durumla mesaj gösterilir
class UserError extends UserState {
  final String message;

  UserError(this.message);
}
