import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import 'landing_shared.dart';

/// Zaglavlje javnog dela (početna strana i pretraga): znak platforme, veze,
/// "Prijavi se" i "Započni"; prijavljen korisnik vidi "Kontrolna tabla".
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  static const double height = 72;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final showLinks = width >= 1040;
    final showButtons = width >= 640;
    final side = landingGutter(context);

    return Material(
      color: AppColors.surface,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: height,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: side),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      final loggedIn = authState is AuthAuthenticated;
                      return Row(
                        children: [
                          _Logo(onTap: () => context.go('/')),
                          if (showLinks) ...[
                            const SizedBox(width: 40),
                            ..._links(context).map((l) => Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: _NavLink(label: l.$1, onTap: l.$2),
                                )),
                          ],
                          const Spacer(),
                          if (showButtons) ..._buttons(context, loggedIn),
                          if (!showLinks) ...[
                            const SizedBox(width: 4),
                            IconButton(
                              tooltip: 'Meni',
                              icon: const Icon(Icons.menu_rounded),
                              onPressed: () => _showMenu(context, loggedIn),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Veze zaglavlja; sekcije početne strane se otvaraju pomeranjem, a sa druge
  /// stranice vode na početnu.
  static List<(String, VoidCallback)> _links(BuildContext context) {
    void section(GlobalKey key) {
      if (!LandingKeys.scrollTo(key)) context.go('/');
    }

    return [
      ('Pretraga površina', () => context.go('/discover')),
      ('Kategorije', () => section(LandingKeys.categories)),
      ('Analitika', () => section(LandingKeys.analytics)),
      ('Generalni upit', () => section(LandingKeys.expert)),
    ];
  }

  static List<Widget> _buttons(BuildContext context, bool loggedIn) {
    if (loggedIn) {
      return [
        FilledButton(
          onPressed: () => context.go('/app/dashboard'),
          child: const Text('Kontrolna tabla'),
        ),
      ];
    }
    return [
      TextButton(
        onPressed: () => context.go('/auth/login'),
        style: TextButton.styleFrom(foregroundColor: AppColors.foreground),
        child: const Text('Prijavi se'),
      ),
      const SizedBox(width: 8),
      FilledButton(
        onPressed: () => context.go('/auth/register'),
        child: const Text('Započni'),
      ),
    ];
  }

  static void _showMenu(BuildContext context, bool loggedIn) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        void go(String route) {
          Navigator.pop(sheetContext);
          context.go(route);
        }

        void section(GlobalKey key) {
          Navigator.pop(sheetContext);
          if (!LandingKeys.scrollTo(key)) context.go('/');
        }

        Widget item(IconData icon, String label, VoidCallback onTap) =>
            ListTile(
              leading: Icon(icon, color: AppColors.text2),
              title: Text(label, style: AppTypography.bodyMedium),
              onTap: onTap,
            );

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                item(Icons.home_outlined, 'Početna', () => go('/')),
                item(Icons.travel_explore_rounded, 'Pretraga površina',
                    () => go('/discover')),
                item(Icons.grid_view_rounded, 'Kategorije',
                    () => section(LandingKeys.categories)),
                item(Icons.insights_rounded, 'Analitika',
                    () => section(LandingKeys.analytics)),
                item(Icons.support_agent_rounded, 'Generalni upit',
                    () => section(LandingKeys.expert)),
                const Divider(height: 24),
                if (loggedIn)
                  FilledButton(
                    onPressed: () => go('/app/dashboard'),
                    child: const Text('Kontrolna tabla'),
                  )
                else ...[
                  OutlinedButton(
                    onPressed: () => go('/auth/login'),
                    child: const Text('Prijavi se'),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () => go('/auth/register'),
                    child: const Text('Započni'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Logo extends StatelessWidget {
  final VoidCallback onTap;

  const _Logo({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: const BrandMark(size: 34),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _NavLink({required this.label, required this.onTap});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.surfaceSunken : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            widget.label,
            style: AppTypography.labelLarge.copyWith(
              color: _hovered ? AppColors.foreground : AppColors.text2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
