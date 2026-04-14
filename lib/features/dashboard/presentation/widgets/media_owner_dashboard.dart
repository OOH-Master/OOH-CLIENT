import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../inventory_management/data/repository/inventory_management_repository.dart';
import '../blocs/analytics_bloc.dart';
import '../../data/repository/analytics_repository.dart';
import 'base_dashboard.dart';
import 'quick_action_card.dart';
import 'stat_card.dart';

class MediaOwnerDashboard extends BaseDashboard {
  const MediaOwnerDashboard({super.key, required super.user});

  @override
  Widget buildStatCards(BuildContext context, bool isDesktop) {
    final loc = l10n(context);
    final cardWidth = isDesktop
        ? 200.0
        : (MediaQuery.of(context).size.width - AppSpacing.md * 2 - AppSpacing.sm) / 2;

    return FutureBuilder<List<dynamic>>(
      future: context.read<InventoryManagementRepository>().getMyInventory().then<List<dynamic>>((list) => list).catchError((_) => <dynamic>[]),
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        final totalCount = items.length.toString();
        final activeCount = items.where((item) => item.status == 'AVAILABLE').length.toString();

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
                    icon: Icons.inventory_2_outlined,
                    label: loc.myInventory,
                    value: snapshot.hasData ? totalCount : '—',
                    iconColor: AppColors.primary,
                    onTap: () => context.push('/app/my-inventory'),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: StatCard(
                    icon: Icons.check_circle_outline,
                    label: loc.activeItems,
                    value: snapshot.hasData ? activeCount : '—',
                    iconColor: AppColors.success,
                  ),
                ),
              ],
            ),
            // Analytics section
            const SizedBox(height: AppSpacing.md),
            _AnalyticsSection(),
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
          icon: Icons.inventory_2_outlined,
          label: loc.myInventory,
          onTap: () => context.push('/app/my-inventory'),
        ),
        QuickActionCard(
          icon: Icons.add_circle_outline,
          label: loc.addInventory,
          onTap: () => context.push('/app/inventory/create'),
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
        loc.recentInventory,
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

class _AnalyticsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnalyticsBloc(context.read<AnalyticsRepository>())
        ..add(LoadMediaOwnerAnalytics()),
      child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoaded && state.data['error'] == null) {
            final quoteStats = state.data['quoteStats'] as Map<String, dynamic>? ?? {};
            if (quoteStats.isEmpty) return const SizedBox.shrink();
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
                  Text('Statistika ponuda', style: AppTypography.h6),
                  const SizedBox(height: AppSpacing.sm),
                  ...quoteStats.entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key, style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground)),
                        Text('${e.value}', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )),
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
