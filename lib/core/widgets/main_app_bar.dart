import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/l10n.dart';
import '../responsive/breakpoints.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Reusable AppBar that should be used across ALL pages in the app.
/// Provides consistent branding, navigation, and actions.
class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Optional title widget to display in the center/title area
  final Widget? titleWidget;

  /// Whether to show the back button (for detail pages)
  final bool showBackButton;

  /// Custom back button callback (defaults to context.pop())
  final VoidCallback? onBackPressed;

  /// Additional actions to display on the right
  final List<Widget>? actions;

  /// Whether to show the login button
  final bool showLoginButton;

  /// Optional bottom widget (like a search bar or tabs)
  final PreferredSizeWidget? bottom;

  const MainAppBar({
    super.key,
    this.titleWidget,
    this.showBackButton = false,
    this.onBackPressed,
    this.actions,
    this.showLoginButton = true,
    this.bottom,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0) + 1,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= Breakpoints.desktop;

    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.foreground),
              onPressed: onBackPressed ?? () => context.pop(),
            )
          : Padding(
              padding: const EdgeInsets.only(left: 16),
              child: GestureDetector(
                onTap: () => context.go('/'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLogo(),
                    if (isDesktop) ...[
                      const SizedBox(width: 12),
                      Text(
                        l10n.appName,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.foreground,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
      leadingWidth: showBackButton ? 56 : (isDesktop ? 180 : 60),
      title: titleWidget,
      centerTitle: false,
      actions: [
        if (actions != null) ...actions!,
        if (showLoginButton) ...[
          OutlinedButton(
            onPressed: () => context.push('/auth/login'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              l10n.loginButton,
              style: AppTypography.button.copyWith(color: AppColors.foreground),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight((bottom?.preferredSize.height ?? 0) + 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (bottom != null) bottom!,
            Container(height: 1, color: AppColors.border),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.apartment, color: Colors.white, size: 18),
    );
  }
}
