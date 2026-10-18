import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/blocs/auth_bloc.dart';
import '../../features/notification/presentation/widgets/notification_bell.dart';
import '../l10n/l10n.dart';
import '../l10n/locale_cubit.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'ui/ui.dart';

/// Zaglavlje stranica van radnog dela (prijava, registracija, lozinka):
/// belo sa tankom linijom, znak platforme, zvonce za prijavljene, izbor jezika
/// i dugme za prijavu.
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

  static const double _height = 64;

  @override
  Size get preferredSize =>
      Size.fromHeight(_height + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final wide = MediaQuery.sizeOf(context).width >= 600;

    void back() {
      if (onBackPressed != null) {
        onBackPressed!();
      } else if (Navigator.of(context).canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    }

    return AppBar(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: _height,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      shape: const Border(bottom: BorderSide(color: AppColors.border)),
      title: Padding(
        padding: EdgeInsets.only(left: showBackButton ? 12 : 16),
        child: Row(
          children: [
            if (showBackButton) ...[
              _BackButton(onTap: back),
              const SizedBox(width: 12),
            ],
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => context.go('/'),
                child: BrandMark(size: 32, compact: !wide),
              ),
            ),
            if (titleWidget != null) ...[
              const SizedBox(width: 16),
              Flexible(child: titleWidget!),
            ],
          ],
        ),
      ),
      actions: [
        if (actions != null) ...actions!,
        // Zvonce samo za prijavljenog korisnika
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is AuthAuthenticated) {
              return const NotificationBell();
            }
            return const SizedBox.shrink();
          },
        ),
        const SizedBox(width: 4),
        BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) => _LocaleToggle(
            label: locale.languageCode == 'sr' ? 'EN' : 'SR',
            onTap: () => context.read<LocaleCubit>().toggle(),
          ),
        ),
        if (showLoginButton)
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is AuthAuthenticated) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(left: 10),
                child: OutlinedButton(
                  onPressed: () => context.push('/auth/login'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(l10n.loginButton),
                ),
              );
            },
          ),
        const SizedBox(width: 16),
      ],
      bottom: bottom,
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Nazad',
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: const SizedBox(
            width: 38,
            height: 38,
            child: Icon(Icons.arrow_back_rounded,
                size: 20, color: AppColors.text2),
          ),
        ),
      ),
    );
  }
}

/// Izbor jezika: mala oznaka "EN" / "SR" sa tankom ivicom.
class _LocaleToggle extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _LocaleToggle({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label == 'EN' ? 'English' : 'Srpski',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.translate_rounded,
                    size: 14, color: AppColors.mutedForeground),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.text2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
