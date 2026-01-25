import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';

class ExpertAdviceSection extends StatelessWidget {
  const ExpertAdviceSection({super.key});

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
        child: Column(
          children: [
            Text(
              'Get expert advice, instantly',
              style: context.isDesktop ? AppTypography.displaySmall : AppTypography.h1,
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),
            Text(
              'Our media planning experts are here to help. Get personalized recommendations and strategy advice through our in-platform consultation service.',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms, duration: 600.ms),
            const SizedBox(height: 48),
            Center(
              child: Container(
                width: context.isDesktop ? 320 : 280,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Container(
                    height: 420,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.pink[50]!,
                          Colors.amber[50]!,
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.pink[400]!,
                                  Colors.amber[400]!,
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.pink[400]!.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.people,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Expert Support',
                            style: AppTypography.h3.copyWith(
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Connect with our team for personalized guidance',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          _buildFeatureCard(
                            icon: Icons.bar_chart,
                            label: 'Campaign Analytics',
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 12),
                          _buildFeatureCard(
                            icon: Icons.trending_up,
                            label: 'Performance Insights',
                            color: Colors.green[600]!,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack).fadeIn(duration: 600.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
