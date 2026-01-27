import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';

class AdvancedAnalyticsSection extends StatelessWidget {
  const AdvancedAnalyticsSection({super.key});

  static const List<Map<String, String>> features = [
    {
      'title': 'Real-time Dashboards',
      'description': 'Monitor your campaign performance in real-time with live data updates.',
    },
    {
      'title': 'Audience Measurement',
      'description': 'Understand the demographics of your viewers.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.muted,
      padding: EdgeInsets.symmetric(
        vertical: context.isDesktop ? 96 : 64,
        horizontal: context.isDesktop ? 48 : 16,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: ResponsiveLayout(
          mobile: _buildMobileLayout(context),
          desktop: _buildDesktopLayout(context),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildContent(context),
        const SizedBox(height: 48),
        _buildImage(),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildImage(),
        ),
        const SizedBox(width: 64),
        Expanded(
          child: _buildContent(context),
        ),
      ],
    );
  }

  Widget _buildImage() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.2),
            AppColors.accent.withOpacity(0.1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.analytics_outlined,
          size: 120,
          color: Colors.white,
        ),
      ),
    )
        .animate()
        .scale(duration: 800.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 600.ms);
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Advanced analytics to measure what matters',
          style: context.isDesktop
              ? AppTypography.displaySmall
              : AppTypography.h1,
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.2, end: 0),
        const SizedBox(height: 24),
        Text(
          'Our analytics suite provides comprehensive insights into your campaign\'s performance. Track reach, frequency, and audience engagement with our intuitive dashboards to optimize your OOH strategy.',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.mutedForeground,
            height: 1.6,
          ),
        )
            .animate()
            .fadeIn(delay: 100.ms, duration: 600.ms)
            .slideY(begin: 0.2, end: 0),
        const SizedBox(height: 32),
        ...features.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.value['title']!,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.value['description']!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 200 + entry.key * 100), duration: 600.ms)
              .slideX(begin: -0.2, end: 0);
        }),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.primaryForeground,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Explore analytics'),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 18),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 500.ms, duration: 600.ms)
            .scale(),
      ],
    );
  }
}
