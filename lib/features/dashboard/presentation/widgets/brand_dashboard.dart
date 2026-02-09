import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import 'base_dashboard.dart';
import 'quick_action_card.dart';
import 'stat_card.dart';

class BrandDashboard extends BaseDashboard {
  const BrandDashboard({super.key, required super.user});

  @override
  Widget buildStatCards(BuildContext context, bool isDesktop) {
    final loc = l10n(context);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        SizedBox(
          width: isDesktop ? 200 : (MediaQuery.of(context).size.width - AppSpacing.md * 2 - AppSpacing.sm) / 2,
          child: StatCard(
            icon: Icons.mail_outline,
            label: loc.myInquiries,
            value: '—',
            iconColor: AppColors.primary,
            onTap: () => context.push('/app/inquiries'),
          ),
        ),
        SizedBox(
          width: isDesktop ? 200 : (MediaQuery.of(context).size.width - AppSpacing.md * 2 - AppSpacing.sm) / 2,
          child: StatCard(
            icon: Icons.campaign_outlined,
            label: loc.myCampaigns,
            value: '—',
            iconColor: AppColors.info,
            onTap: () => context.push('/app/campaigns'),
          ),
        ),
      ],
    );
  }

  @override
  Widget buildQuickActions(BuildContext context, bool isDesktop) {
    final loc = l10n(context);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        QuickActionCard(
          icon: Icons.mail_outline,
          label: loc.myInquiries,
          onTap: () => context.push('/app/inquiries'),
        ),
        QuickActionCard(
          icon: Icons.search,
          label: loc.browseInventory,
          onTap: () => context.go('/app/discover'),
          color: AppColors.success,
        ),
        QuickActionCard(
          icon: Icons.add_circle_outline,
          label: loc.newCampaign,
          onTap: () => context.push('/app/campaigns/create'),
          color: AppColors.info,
        ),
      ],
    );
  }

  @override
  List<Widget> buildRecentSections(BuildContext context, bool isDesktop) {
    final loc = l10n(context);
    return [
      Text(
        loc.recentInquiries,
        style: AppTypography.h3.copyWith(color: AppColors.foreground),
      ),
      const SizedBox(height: AppSpacing.sm),
      _buildEmptyPlaceholder(loc.nothingHereYet),
    ];
  }

  Widget _buildEmptyPlaceholder(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        message,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.mutedForeground),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Future<void> onRefresh(BuildContext context) async {}
}
