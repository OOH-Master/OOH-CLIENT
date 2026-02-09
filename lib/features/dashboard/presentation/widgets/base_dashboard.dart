import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/domain/entities/user.dart';

abstract class BaseDashboard extends StatelessWidget {
  final User user;

  const BaseDashboard({super.key, required this.user});

  AppLocalizations l10n(BuildContext context) => AppLocalizations.of(context)!;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= Breakpoints.desktop;

    return RefreshIndicator(
      onRefresh: () => onRefresh(context),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isDesktop ? AppSpacing.lg : AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome header
            Text(
              l10n(context).welcomeBack(user.name),
              style: AppTypography.h1.copyWith(
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              user.role.name,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Stats
            buildStatCards(context, isDesktop),
            const SizedBox(height: AppSpacing.lg),
            // Quick Actions
            Text(
              l10n(context).quickActions,
              style: AppTypography.h3.copyWith(
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            buildQuickActions(context, isDesktop),
            const SizedBox(height: AppSpacing.lg),
            // Recent items
            ...buildRecentSections(context, isDesktop),
          ],
        ),
      ),
    );
  }

  Widget buildStatCards(BuildContext context, bool isDesktop);
  Widget buildQuickActions(BuildContext context, bool isDesktop);
  List<Widget> buildRecentSections(BuildContext context, bool isDesktop);
  Future<void> onRefresh(BuildContext context);
}
