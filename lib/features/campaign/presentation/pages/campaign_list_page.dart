import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/dto/campaign_dto.dart';
import '../../data/repository/campaign_repository.dart';
import '../blocs/campaign_bloc.dart';

class CampaignListPage extends StatelessWidget {
  const CampaignListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CampaignBloc(context.read<CampaignRepository>())
        ..add(LoadCampaigns()),
      child: const _CampaignListView(),
    );
  }
}

class _CampaignListView extends StatelessWidget {
  const _CampaignListView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.campaigns),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/app/campaigns/create'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        icon: const Icon(Icons.add),
        label: Text(l10n.newCampaign),
      ),
      body: BlocConsumer<CampaignBloc, CampaignState>(
        listener: (context, state) {
          if (state is CampaignFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is CampaignLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CampaignError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.destructive),
                  const SizedBox(height: AppSpacing.md),
                  Text(state.message, style: AppTypography.bodyMedium),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<CampaignBloc>().add(LoadCampaigns()),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          if (state is CampaignsLoaded) {
            if (state.campaigns.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.campaign_outlined,
                        size: 64, color: AppColors.mutedForeground),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.noCampaigns,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<CampaignBloc>().add(LoadCampaigns());
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: state.campaigns.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final campaign = state.campaigns[index];
                  return _CampaignCard(campaign: campaign);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final CampaignDto campaign;
  const _CampaignCard({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final priceFormatter = NumberFormat('#,##0.00');
    final status = CampaignStatus.fromApi(campaign.status);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  campaign.name ?? 'Campaign #${campaign.id}',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.foreground,
                  ),
                ),
              ),
              _CampaignStatusBadge(status: status),
            ],
          ),
          if (campaign.description != null) ...[
            const SizedBox(height: 4),
            Text(
              campaign.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              if (campaign.startDate != null || campaign.endDate != null) ...[
                Icon(Icons.calendar_today,
                    size: 14, color: AppColors.mutedForeground),
                const SizedBox(width: 4),
                Text(
                  '${campaign.startDate ?? '—'} — ${campaign.endDate ?? '—'}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              if (campaign.budget != null) ...[
                Icon(Icons.monetization_on,
                    size: 14, color: AppColors.mutedForeground),
                const SizedBox(width: 4),
                Text(
                  '€${priceFormatter.format(campaign.budget)}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          if (campaign.brandUsername != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.business, size: 14, color: AppColors.mutedForeground),
                const SizedBox(width: 4),
                Text(
                  '${l10n.brandUsername}: ${campaign.brandUsername}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CampaignStatusBadge extends StatelessWidget {
  final CampaignStatus status;
  const _CampaignStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final (Color bg, Color fg, String label) = switch (status) {
      CampaignStatus.draft => (
        AppColors.muted,
        AppColors.mutedForeground,
        l10n.statusDraft,
      ),
      CampaignStatus.inNegotiation => (
        const Color(0xFFFEF3C7),
        const Color(0xFF92400E),
        l10n.statusInNegotiation,
      ),
      CampaignStatus.booked => (
        const Color(0xFFDBEAFE),
        const Color(0xFF1E40AF),
        l10n.statusBooked,
      ),
      CampaignStatus.running => (
        const Color(0xFFD1FAE5),
        const Color(0xFF065F46),
        l10n.statusRunning,
      ),
      CampaignStatus.finished => (
        const Color(0xFFE5E7EB),
        const Color(0xFF374151),
        l10n.statusFinished,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
