import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserBloc(repository: context.read())..add(FetchUserProfile()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserLoadInProgress) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserLoadSuccess) {
              final user = state.user;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(user.photoUrl),
                    ),
                    const SizedBox(height: 16),
                    Text(user.name, style: const TextStyle(fontSize: 20)),
                    Text(user.email, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            } else if (state is UserLoadFailure) {
              return Center(child: Text('Hata: ${state.error}'));
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
