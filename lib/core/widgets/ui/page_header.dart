import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../responsive/breakpoints.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Zaglavlje stranice u radnom delu aplikacije: naslov, kratko objašnjenje i
/// akcije desno. Na telefonu se akcije spuštaju ispod naslova.
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final bool showBack;
  final Widget? leading;
  final EdgeInsetsGeometry? padding;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.showBack = false,
    this.leading,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < Breakpoints.tablet;
    final titleStyle = (compact ? AppTypography.h4 : AppTypography.h2)
        .copyWith(color: AppColors.foreground, fontSize: compact ? 21 : 26);

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: titleStyle),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.mutedForeground),
          ),
        ],
      ],
    );

    final back = showBack
        ? Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _BackButton(onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/app/dashboard');
              }
            }),
          )
        : null;

    final lead = leading ?? back;

    return Padding(
      padding: padding ??
          EdgeInsets.fromLTRB(compact ? 16 : 32, compact ? 18 : 28,
              compact ? 16 : 32, compact ? 14 : 22),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (lead != null) lead,
                    Expanded(child: titleBlock),
                  ],
                ),
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: actions),
                ],
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (lead != null) lead,
                Expanded(child: titleBlock),
                if (actions.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  Wrap(spacing: 10, runSpacing: 10, children: actions),
                ],
              ],
            ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
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
          child:
              Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.text2),
        ),
      ),
    );
  }
}
