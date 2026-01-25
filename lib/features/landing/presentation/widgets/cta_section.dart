import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/responsive/responsive.dart';

class CTASection extends StatelessWidget {
  const CTASection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        vertical: context.isDesktop ? 96 : 64,
        horizontal: context.isDesktop ? 48 : 16,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            Text(
              'Ready to elevate your brand\'s presence?',
              style: context.isDesktop
                  ? AppTypography.displaySmall
                  : AppTypography.h1,
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),
            Text(
              'Join thousands of leading brands who use our platform to create impactful OOH campaigns. Sign up today and get started in minutes.',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 600.ms),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Start Your Campaign'),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms)
                .scale(),
          ],
        ),
      ),
    );
  }
}
