import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../agency/data/repository/agency_repository.dart';
import '../../../auth/domain/entities/role.dart';
import '../../../campaign/data/repository/campaign_repository.dart';
import '../../../inquiry/data/repository/inquiry_repository.dart';
import 'base_dashboard.dart';
import 'quick_action_card.dart';
import 'stat_card.dart';

class AgencyDashboard extends BaseDashboard {
  const AgencyDashboard({super.key, required super.user});

  @override
  Widget buildStatCards(BuildContext context, bool isDesktop) {
    final loc = l10n(context);
    final brandsFuture = context.read<AgencyRepository>().getBrands().then((list) => list.length).catchError((_) => 0);
    final inquiryFuture = context.read<InquiryRepository>().getInquiries(Role.agency).then((list) => list.length).catchError((_) => 0);
    final campaignFuture = context.read<CampaignRepository>().getCampaigns().then((list) => list.length).catchError((_) => 0);
    final cardWidth = isDesktop ? 200.0 : (MediaQuery.of(context).size.width - AppSpacing.md * 2 - AppSpacing.sm * 2) / 3;
    return FutureBuilder<List<int>>(
      future: Future.wait([brandsFuture, inquiryFuture, campaignFuture]),
      builder: (context, snapshot) {
        final brandsCount = snapshot.data?[0].toString() ?? '—';
        final inquiryCount = snapshot.data?[1].toString() ?? '—';
        final campaignCount = snapshot.data?[2].toString() ?? '—';
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            SizedBox(
              width: cardWidth,
              child: StatCard(
                icon: Icons.business,
                label: loc.myBrands,
                value: brandsCount,
                iconColor: AppColors.primary,
                onTap: () => context.push('/app/agency/brands'),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: StatCard(
                icon: Icons.mail_outline,
                label: loc.myInquiries,
                value: inquiryCount,
                iconColor: AppColors.info,
                onTap: () => context.push('/app/inquiries'),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: StatCard(
                icon: Icons.campaign_outlined,
                label: loc.myCampaigns,
                value: campaignCount,
                iconColor: AppColors.success,
                onTap: () => context.push('/app/campaigns'),
              ),
            ),
          ],
        );
      },
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
          icon: Icons.business,
          label: loc.myBrands,
          onTap: () => context.push('/app/agency/brands'),
        ),
        QuickActionCard(
          icon: Icons.mail_outline,
          label: loc.myInquiries,
          onTap: () => context.push('/app/inquiries'),
          color: AppColors.info,
        ),
        QuickActionCard(
          icon: Icons.add_circle_outline,
          label: loc.newCampaign,
          onTap: () => context.push('/app/campaigns/create'),
          color: AppColors.success,
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
