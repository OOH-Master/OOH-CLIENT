import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/l10n/locale_cubit.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../notification/presentation/widgets/notification_bell.dart';
import '../widgets/app_sidebar.dart';

/// Ljuska tri glavne grane (kontrolna tabla, istraživanje, profil).
///
/// Na širokom ekranu meni daje [AppFrame] oko celog radnog dela, pa ova ljuska
/// vraća samo sadržaj grane. Na telefonu i tabletu daje zaglavlje, fioku sa
/// stavkama uloge i donju navigaciju.
class MainShellPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellPage({super.key, required this.navigationShell});

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop) return navigationShell;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        titleSpacing: 4,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'Meni',
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const BrandMark(size: 30),
        actions: const [NotificationBell(), SizedBox(width: 6)],
      ),
      drawer: const _MobileDrawer(),
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border))),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.space_dashboard_outlined),
              selectedIcon: const Icon(Icons.space_dashboard_rounded),
              label: l10n.dashboardTab,
            ),
            NavigationDestination(
              icon: const Icon(Icons.travel_explore_outlined),
              selectedIcon: const Icon(Icons.travel_explore_rounded),
              label: l10n.discoverTab,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: l10n.profileTab,
            ),
          ],
          onDestinationSelected: _goBranch,
        ),
      ),
    );
  }
}

class _MobileDrawer extends StatelessWidget {
  const _MobileDrawer();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final role = user?.role;
    final (groupTitle, items) = roleNav(role);
    final name = (user?.companyName?.isNotEmpty ?? false)
        ? user!.companyName!
        : (user?.name ?? '');
    final location =
        GoRouter.of(context).routeInformationProvider.value.uri.path;

    Widget tile(NavEntry e) {
      final selected = e.matches(location);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: Material(
          color: selected ? AppColors.inkRaised : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: Icon(selected ? e.activeIcon : e.icon,
                color: selected ? AppColors.primaryTint : AppColors.inkMuted),
            title: Text(
              e.label,
              style: AppTypography.bodyMedium.copyWith(
                color: selected ? Colors.white : AppColors.inkText,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              if (e.path.startsWith('/app/dashboard') ||
                  e.path.startsWith('/app/discover') ||
                  e.path.startsWith('/app/profile')) {
                context.go(e.path);
              } else {
                context.push(e.path);
              }
            },
          ),
        ),
      );
    }

    return Drawer(
      backgroundColor: AppColors.ink,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  AppAvatar(name: name.isEmpty ? '?' : name, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                AppTypography.h6.copyWith(color: Colors.white)),
                        const SizedBox(height: 2),
                        Text(roleLabel(role),
                            style: AppTypography.caption
                                .copyWith(color: AppColors.inkMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.inkLine, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  for (final e in mainNav) tile(e),
                  tile(const NavEntry('/app/profile', 'Profil',
                      Icons.person_outline_rounded, Icons.person_rounded)),
                  if (items.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 18, 20, 6),
                      child: Text(groupTitle,
                          style: AppTypography.labelSmall
                              .copyWith(color: AppColors.inkMuted)),
                    ),
                    for (final e in items) tile(e),
                  ],
                  const SizedBox(height: 8),
                  tile(const NavEntry(
                      '/app/notifications',
                      'Obaveštenja',
                      Icons.notifications_none_rounded,
                      Icons.notifications_rounded)),
                ],
              ),
            ),
            const Divider(color: AppColors.inkLine, height: 1),
            BlocBuilder<LocaleCubit, Locale>(
              builder: (context, locale) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: const Icon(Icons.translate_rounded,
                    color: AppColors.inkMuted),
                title: Text(
                  locale.languageCode == 'sr' ? 'English' : 'Srpski',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.inkText),
                ),
                onTap: () {
                  context.read<LocaleCubit>().toggle();
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading:
                  const Icon(Icons.logout_rounded, color: Color(0xFFF87171)),
              title: Text('Odjavi se',
                  style: AppTypography.bodyMedium
                      .copyWith(color: const Color(0xFFFCA5A5))),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(LogoutRequested());
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
