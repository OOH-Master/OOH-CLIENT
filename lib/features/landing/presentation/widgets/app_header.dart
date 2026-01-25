import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/responsive/responsive.dart';

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
    return AppBar(
      backgroundColor: AppColors.background.withOpacity(0.8),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: AppColors.background.withOpacity(0.8),
          border: Border(
            bottom: BorderSide(
              color: AppColors.border,
              width: 1,
            ),
          ),
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: context.isDesktop
                ? const ColorFilter.mode(Colors.transparent, BlendMode.src)
                : const ColorFilter.mode(Colors.transparent, BlendMode.src),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/'),
            child: Text(
              'AutoHome',
              style: AppTypography.h3.copyWith(
                color: AppColors.foreground,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (context.isDesktop) ...[
            const SizedBox(width: 64),
            _buildDesktopNav(context),
          ],
        ],
      ),
      actions: [
        if (context.isDesktop) ...[
          TextButton(
            onPressed: () => context.go('/login'),
            child: Text(
              'Log in',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => context.go('/register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.primaryForeground,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Get started'),
          ),
          const SizedBox(width: 16),
        ] else ...[
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _showMobileMenu(context),
          ),
        ],
      ],
    );
  }

  Widget _buildDesktopNav(BuildContext context) {
    return Row(
      children: [
        _NavLink(label: 'Solutions', onTap: () {}),
        const SizedBox(width: 24),
        _NavLink(label: 'Products', onTap: () {}),
        const SizedBox(width: 24),
        _NavLink(label: 'Resources', onTap: () {}),
        const SizedBox(width: 24),
        _NavLink(label: 'Company', onTap: () {}),
        const SizedBox(width: 24),
        _NavLink(label: 'Locations', onTap: () {}),
      ],
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Menu',
              style: AppTypography.h3.copyWith(
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                context.go('/');
              },
            ),
            ListTile(
              title: const Text('Find media'),
              onTap: () {
                Navigator.pop(context);
                context.go('/search');
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Log in'),
              onTap: () {
                Navigator.pop(context);
                context.go('/login');
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/register');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
              ),
              child: const Text('Get started'),
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
