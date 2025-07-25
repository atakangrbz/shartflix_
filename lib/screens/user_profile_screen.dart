import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';

class UserProfileScreen extends StatelessWidget {
  final String token; // Giriş yapıldıktan sonra gelen token

  const UserProfileScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    // Bloc'u tekrar oluşturmana gerek yok, çünkü main.dart'te MultiBlocProvider ile verildi
    context.read<UserBloc>().add(FetchUserProfile(token: token));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.deepPurple,
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserProfileLoaded) {
            final user = state.profile;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(user['photoUrl'] ?? ''),
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user['name'] ?? '',
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    user['email'] ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          } else if (state is UserError) {
            return Center(
              child: Text('Hata: ${state.message}', style: const TextStyle(color: Colors.red)),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
