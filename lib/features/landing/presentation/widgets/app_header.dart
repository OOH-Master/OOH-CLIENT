import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  State<AppHeader> createState() => _AppHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(64);
}

class _AppHeaderState extends State<AppHeader> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      backgroundColor: AppColors.background.withValues(alpha: 0.95),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.95),
          border: const Border(
            bottom: BorderSide(
              color: AppColors.border,
              width: 1,
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/'),
            child: Text(
              l10n.appName,
              style: AppTypography.h3.copyWith(
                color: AppColors.foreground,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (context.isDesktop) ...[
            const SizedBox(width: 64),
            _buildDesktopNav(context, l10n),
          ],
        ],
      ),
      actions: [
        if (context.isDesktop) ...[
          TextButton(
            onPressed: () => context.go('/auth/login'),
            child: Text(
              l10n.loginButton,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => context.go('/auth/register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.primaryForeground,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(l10n.getStarted),
          ),
          const SizedBox(width: 16),
        ] else ...[
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _showMobileMenu(context, l10n),
          ),
        ],
      ],
    );
  }

  Widget _buildDesktopNav(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        _NavLink(label: l10n.navSolutions, onTap: () {}),
        const SizedBox(width: 24),
        _NavLink(label: l10n.navProducts, onTap: () {}),
        const SizedBox(width: 24),
        _NavLink(label: l10n.navResources, onTap: () {}),
        const SizedBox(width: 24),
        _NavLink(label: l10n.navCompany, onTap: () {}),
        const SizedBox(width: 24),
        _NavLink(label: l10n.navLocations, onTap: () => context.go('/discover')),
      ],
    );
  }

  void _showMobileMenu(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.menu,
              style: AppTypography.h3.copyWith(
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              title: Text(l10n.home),
              onTap: () {
                Navigator.pop(context);
                context.go('/');
              },
            ),
            ListTile(
              title: Text(l10n.findMedia),
              onTap: () {
                Navigator.pop(context);
                context.go('/discover');
              },
            ),
            const Divider(),
            ListTile(
              title: Text(l10n.loginButton),
              onTap: () {
                Navigator.pop(context);
                context.go('/auth/login');
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/auth/register');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
              ),
              child: Text(l10n.getStarted),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _NavLink({
    required this.label,
    required this.onTap,
  });

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.label,
          style: AppTypography.bodyMedium.copyWith(
            color: _isHovered ? AppColors.foreground : AppColors.mutedForeground,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
