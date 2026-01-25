import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 20),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return Column(
                  children: [
                    Text(
                      state.user.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      state.user.email,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 10),
                    Chip(label: Text(state.user.role.name)),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 200,
            child: PrimaryButton(
              text: l10n.logout,
              onPressed: () {
                context.read<AuthBloc>().add(LogoutRequested());
              },
            ),
          ),
        ],
      ),
    );
  }
}
