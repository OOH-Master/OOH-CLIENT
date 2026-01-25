import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/responsive/responsive.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  static const Map<String, List<String>> footerLinks = {
    'Solutions': ['Advertisers', 'Agencies', 'Media Owners'],
    'Products': ['Marketplace', 'Planner', 'Analytics'],
    'Resources': ['Blog', 'Case Studies', 'Support'],
    'Company': ['About', 'Careers', 'Contact'],
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: EdgeInsets.symmetric(
        vertical: context.isDesktop ? 48 : 32,
        horizontal: context.isDesktop ? 48 : 16,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Column(
          children: [
            ResponsiveLayout(
              mobile: _buildMobileLayout(),
              tablet: _buildTabletLayout(),
              desktop: _buildDesktopLayout(),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),
            Text(
              '© 2026 AutoHome. All rights reserved.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AutoHome',
          style: AppTypography.h3.copyWith(
            color: AppColors.foreground,
            fontWeight: FontWeight.bold,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .slideX(begin: -0.2, end: 0),
        const SizedBox(height: 32),
        ...footerLinks.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ...entry.value.map((link) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    link,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 24),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 24,
      mainAxisSpacing: 24,
      childAspectRatio: 1.5,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AutoHome',
              style: AppTypography.h3.copyWith(
                color: AppColors.foreground,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 600.ms),
        ...footerLinks.entries.map((entry) {
          return _FooterColumn(
            title: entry.key,
            links: entry.value,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            'AutoHome',
            style: AppTypography.h3.copyWith(
              color: AppColors.foreground,
              fontWeight: FontWeight.bold,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms),
        ),
        ...footerLinks.entries.map((entry) {
          return Expanded(
            flex: 1,
            child: _FooterColumn(
              title: entry.key,
              links: entry.value,
            ),
          );
        }).toList(),
      ],
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String> links;

  const _FooterColumn({
    required this.title,
    required this.links,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map((link) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {},
              child: Text(
                link,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ),
          );
        }).toList(),
      ],
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 100.ms)
        .slideY(begin: 0.2, end: 0);
  }
}
