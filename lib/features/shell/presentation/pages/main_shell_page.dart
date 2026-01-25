import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../blocs/shell_cubit.dart';

class MainShellPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellPage({super.key, required this.navigationShell});

  void _goBranch(int index, BuildContext context) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
    context.read<ShellCubit>().setIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => ShellCubit(),
      child: BlocBuilder<ShellCubit, int>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_getTitle(navigationShell.currentIndex, l10n)),
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        String name = 'User';
                        String email = '';
                        if (authState is AuthAuthenticated) {
                          name = authState.user.name;
                          email = authState.user.email;
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              email,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.inventory_2),
                    title: Text(l10n.discoverTab),
                    selected: navigationShell.currentIndex == 0,
                    onTap: () {
                      _goBranch(0, context);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.map),
                    title: Text(l10n.mapTab),
                    selected: navigationShell.currentIndex == 1,
                    onTap: () {
                      _goBranch(1, context);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(l10n.profileTab),
                    selected: navigationShell.currentIndex == 2,
                    onTap: () {
                      _goBranch(2, context);
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: Text(l10n.logout),
                    onTap: () {
                      context.read<AuthBloc>().add(LogoutRequested());
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            body: navigationShell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.inventory_2_outlined),
                  selectedIcon: const Icon(Icons.inventory_2),
                  label: l10n.discoverTab,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.map_outlined),
                  selectedIcon: const Icon(Icons.map),
                  label: l10n.mapTab,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: const Icon(Icons.person),
                  label: l10n.profileTab,
                ),
              ],
              onDestinationSelected: (index) => _goBranch(index, context),
            ),
          );
        },
      ),
    );
  }

  String _getTitle(int index, AppLocalizations l10n) {
    switch (index) {
      case 0:
        return l10n.discoverTab;
      case 1:
        return l10n.mapTab;
      case 2:
        return l10n.profileTab;
      default:
        return '';
    }
  }
}
