import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../blocs/analytics_bloc.dart';
import '../../data/repository/analytics_repository.dart';
import 'base_dashboard.dart';
import 'quick_action_card.dart';
import 'stat_card.dart';

class AdminDashboard extends BaseDashboard {
  const AdminDashboard({super.key, required super.user});

  @override
  Widget buildStatCards(BuildContext context, bool isDesktop) {
    final loc = l10n(context);

    return BlocProvider(
      create: (context) => AnalyticsBloc(context.read<AnalyticsRepository>())
        ..add(LoadAdminAnalytics()),
      child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          String totalInquiries = '—';
          String acceptanceRate = '—';
          String activeCampaigns = '—';
          String totalRevenue = '—';
          Map<String, dynamic> pipeline = {};
          List<Map<String, dynamic>> monthlyTrend = [];

          if (state is AnalyticsLoaded) {
            totalInquiries = '${state.data['totalInquiries'] ?? '—'}';
            acceptanceRate = state.data['acceptanceRate'] != null
                ? '${(state.data['acceptanceRate'] as num).toStringAsFixed(0)}%'
                : '—';
            activeCampaigns = '${state.data['activeCampaigns'] ?? '—'}';
            totalRevenue = state.data['totalRevenue'] != null
                ? (state.data['totalRevenue'] as num).toStringAsFixed(0)
                : '—';
            pipeline = (state.data['pipeline'] as Map<String, dynamic>?) ?? {};
            final trendData = state.data['monthlyTrend'];
            if (trendData is List) {
              monthlyTrend = trendData.map((e) => e as Map<String, dynamic>).toList();
            }
          }

          final cardWidth = isDesktop
              ? 180.0
              : (MediaQuery.of(context).size.width - AppSpacing.md * 2 - AppSpacing.sm) / 2;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KPI Row
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: StatCard(
                      icon: Icons.mail_outline,
                      label: loc.totalInquiries,
                      value: totalInquiries,
                      iconColor: AppColors.info,
                      onTap: () => context.push('/app/inquiries'),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: StatCard(
                      icon: Icons.check_circle_outline,
                      label: 'Stopa prihvatanja',
                      value: acceptanceRate,
                      iconColor: AppColors.success,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: StatCard(
                      icon: Icons.campaign_outlined,
                      label: 'Aktivne kampanje',
                      value: activeCampaigns,
                      iconColor: AppColors.warning,
                      onTap: () => context.push('/app/campaigns'),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: StatCard(
                      icon: Icons.euro_outlined,
                      label: 'Ukupan prihod',
                      value: totalRevenue,
                      iconColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
              // Pipeline bar
              if (pipeline.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Pipeline upita',
                  style: AppTypography.h6.copyWith(color: AppColors.foreground),
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildPipelineBar(pipeline),
              ],
              // Monthly trend chart
              if (monthlyTrend.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Mesecni trend',
                  style: AppTypography.h6.copyWith(color: AppColors.foreground),
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildMonthlyTrendChart(monthlyTrend),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildPipelineBar(Map<String, dynamic> pipeline) {
    final statuses = pipeline.entries.toList();
    final total = statuses.fold<int>(0, (sum, e) => sum + ((e.value as num?)?.toInt() ?? 0));
    if (total == 0) return const SizedBox.shrink();

    final colors = [
      AppColors.info,
      AppColors.warning,
      const Color(0xFF8B5CF6),
      AppColors.primary,
      const Color(0xFF0EA5E9),
      AppColors.success,
      AppColors.destructive,
      AppColors.mutedForeground,
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: SizedBox(
              height: 24,
              child: Row(
                children: List.generate(statuses.length, (i) {
                  final count = (statuses[i].value as num?)?.toInt() ?? 0;
                  if (count == 0) return const SizedBox.shrink();
                  return Expanded(
                    flex: count,
                    child: Container(
                      color: colors[i % colors.length],
                      alignment: Alignment.center,
                      child: count > 0
                          ? Text(
                              '$count',
                              style: AppTypography.labelSmall.copyWith(color: Colors.white),
                            )
                          : null,
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Legend
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xxs,
            children: List.generate(statuses.length, (i) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colors[i % colors.length],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${statuses[i].key}: ${statuses[i].value}',
                    style: AppTypography.caption.copyWith(color: AppColors.mutedForeground),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTrendChart(List<Map<String, dynamic>> data) {
    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      final count = (data[i]['count'] as num?)?.toDouble() ?? 0;
      spots.add(FlSpot(i.toDouble(), count));
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.border,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: AppTypography.caption.copyWith(color: AppColors.mutedForeground),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < data.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        data[idx]['month']?.toString() ?? '',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.mutedForeground,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
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
          label: loc.allInquiries,
          onTap: () => context.push('/app/inquiries'),
        ),
        QuickActionCard(
          icon: Icons.people_outline,
          label: 'Korisnici',
          onTap: () => context.push('/app/admin/users'),
          color: AppColors.info,
        ),
        QuickActionCard(
          icon: Icons.settings,
          label: loc.configuration,
          onTap: () => context.push('/app/admin/config'),
          color: AppColors.warning,
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
