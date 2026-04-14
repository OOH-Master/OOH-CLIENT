import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/domain/entities/role.dart';
import '../../../campaign/data/repository/campaign_repository.dart';
import '../../../inquiry/data/repository/inquiry_repository.dart';
import '../blocs/analytics_bloc.dart';
import '../../data/repository/analytics_repository.dart';
import 'base_dashboard.dart';
import 'quick_action_card.dart';
import 'stat_card.dart';

class BrandDashboard extends BaseDashboard {
  const BrandDashboard({super.key, required super.user});

  @override
  Widget buildStatCards(BuildContext context, bool isDesktop) {
    final loc = l10n(context);
    final inquiryFuture = context.read<InquiryRepository>().getInquiries(Role.brand).then((list) => list.length).catchError((_) => 0);
    final campaignFuture = context.read<CampaignRepository>().getCampaigns().then((list) => list.length).catchError((_) => 0);
    final cardWidth = isDesktop
        ? 200.0
        : (MediaQuery.of(context).size.width - AppSpacing.md * 2 - AppSpacing.sm) / 2;

    return FutureBuilder<List<int>>(
      future: Future.wait([inquiryFuture, campaignFuture]),
      builder: (context, snapshot) {
        final inquiryCount = snapshot.data?[0].toString() ?? '—';
        final campaignCount = snapshot.data?[1].toString() ?? '—';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: StatCard(
                    icon: Icons.mail_outline,
                    label: loc.myInquiries,
                    value: inquiryCount,
                    iconColor: AppColors.primary,
                    onTap: () => context.push('/app/inquiries'),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: StatCard(
                    icon: Icons.campaign_outlined,
                    label: loc.myCampaigns,
                    value: campaignCount,
                    iconColor: AppColors.info,
                    onTap: () => context.push('/app/campaigns'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _BrandAnalyticsSection(),
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

class _BrandAnalyticsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnalyticsBloc(context.read<AnalyticsRepository>())
        ..add(LoadBrandAnalytics()),
      child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoaded && state.data['error'] == null) {
            final statusBreakdown = state.data['statusBreakdown'] as Map<String, dynamic>? ?? {};
            final totalSpending = state.data['totalSpending'];
            if (statusBreakdown.isEmpty && totalSpending == null) return const SizedBox.shrink();

            return Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Analitika', style: AppTypography.h6),
                  if (totalSpending != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Text('Ukupna potrosnja: ', style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground)),
                        Text(
                          (totalSpending as num).toStringAsFixed(2),
                          style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                  if (statusBreakdown.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text('Status upita:', style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground)),
                    const SizedBox(height: AppSpacing.xxs),
                    ...statusBreakdown.entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.key, style: AppTypography.caption),
                          Text('${e.value}', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
