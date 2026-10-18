import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'landing_shared.dart';

/// Poziv na registraciju: tamni panel sa naslovom i dva dugmeta.
class CTASection extends StatelessWidget {
  const CTASection({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return LandingSection(
      color: AppColors.surface,
      vertical: wide ? 88 : 56,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.symmetric(
            horizontal: wide ? 56 : 24, vertical: wide ? 48 : 32),
        child: wide
            ? Row(
                children: [
                  Expanded(child: _copy()),
                  const SizedBox(width: 40),
                  _buttons(context),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _copy(),
                  const SizedBox(height: 24),
                  _buttons(context),
                ],
              ),
      ),
    );
  }

  Widget _copy() {
    return Text(
      'Spremni da vaš brend bude viđen?',
      style: AppTypography.h2.copyWith(color: Colors.white),
    );
  }

  Widget _buttons(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton(
          onPressed: () => context.go('/auth/register'),
          child: const Text('Započnite kampanju'),
        ),
        OutlinedButton(
          onPressed: () => context.go('/discover'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.transparent,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.28)),
          ),
          child: const Text('Istražite površine'),
        ),
      ],
    );
  }
}
