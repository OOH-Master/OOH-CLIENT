import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../data/dto/campaign_dto.dart';
import '../../data/repository/campaign_repository.dart';
import '../blocs/campaign_bloc.dart';
import '../widgets/campaign_status_badge.dart';

class CampaignDetailPage extends StatelessWidget {
  final String campaignId;

  const CampaignDetailPage({super.key, required this.campaignId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CampaignBloc(context.read<CampaignRepository>())
        ..add(LoadCampaignDetail(int.tryParse(campaignId) ?? 0)),
      child: _CampaignDetailView(campaignId: campaignId),
    );
  }
}

class _CampaignDetailView extends StatelessWidget {
  final String campaignId;
  const _CampaignDetailView({required this.campaignId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = context.isDesktop;
    final priceFormatter = NumberFormat('#,##0.00');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.campaignDetail),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/app/campaigns/$campaignId/edit'),
            tooltip: 'Izmeni',
          ),
        ],
      ),
      body: BlocConsumer<CampaignBloc, CampaignState>(
        listener: (context, state) {
          if (state is CampaignFormSuccess) {
            AppSnackbar.show(context, state.message);
          } else if (state is CampaignError) {
            AppSnackbar.show(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is CampaignLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CampaignDetailLoaded) {
            final campaign = state.campaign;
            final status = CampaignStatus.fromApi(campaign.status);

            return SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? AppSpacing.lg : AppSpacing.md),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: isDesktop ? 700 : double.infinity),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              campaign.name ?? 'Kampanja #${campaign.id}',
                              style: AppTypography.h4,
                            ),
                          ),
                          CampaignStatusBadge(status: status),
                        ],
                      ),
                      if (campaign.description != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          campaign.description!,
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.mutedForeground),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      // Details card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            _detailRow(Icons.calendar_today, l10n.startDate, campaign.startDate ?? '—'),
                            _detailRow(Icons.calendar_today, l10n.endDate, campaign.endDate ?? '—'),
                            if (campaign.budget != null)
                              _detailRow(Icons.euro, l10n.budget, priceFormatter.format(campaign.budget)),
                            if (campaign.brandUsername != null)
                              _detailRow(Icons.business, l10n.brandUsername, campaign.brandUsername!),
                            _detailRow(Icons.access_time, 'Kreirana', campaign.createdAt ?? '—'),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Status transition buttons
                      Text('Promena statusa', style: AppTypography.h6),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: _buildTransitionButtons(context, status, campaign.id),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Delete button
                      OutlinedButton.icon(
                        onPressed: () => _confirmDelete(context, campaign.id),
                        icon: Icon(Icons.delete_outline, color: AppColors.destructive),
                        label: Text('Obrisi kampanju', style: TextStyle(color: AppColors.destructive)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.destructive.withValues(alpha: 0.3)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (state is CampaignError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.destructive),
                  const SizedBox(height: AppSpacing.md),
                  Text(state.message),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () => context.read<CampaignBloc>().add(
                      LoadCampaignDetail(int.tryParse(campaignId) ?? 0),
                    ),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.mutedForeground),
          const SizedBox(width: AppSpacing.xs),
          SizedBox(
            width: 130,
            child: Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground)),
          ),
          Expanded(
            child: Text(value, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTransitionButtons(BuildContext context, CampaignStatus current, int id) {
    final transitions = <(CampaignStatus, String)>[];
    switch (current) {
      case CampaignStatus.draft:
        transitions.add((CampaignStatus.inNegotiation, 'Zapocni pregovore'));
      case CampaignStatus.inNegotiation:
        transitions.add((CampaignStatus.booked, 'Potvrdi rezervaciju'));
        transitions.add((CampaignStatus.draft, 'Vrati u nacrt'));
      case CampaignStatus.booked:
        transitions.add((CampaignStatus.running, 'Pokreni kampanju'));
      case CampaignStatus.running:
        transitions.add((CampaignStatus.finished, 'Zavrsi kampanju'));
      case CampaignStatus.finished:
        break;
    }

    return transitions.map((t) {
      return ElevatedButton(
        onPressed: () {
          context.read<CampaignBloc>().add(ChangeStatus(id, t.$1.name.toUpperCase()));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryForeground,
        ),
        child: Text(t.$2),
      );
    }).toList();
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Potvrda brisanja'),
        content: const Text('Da li ste sigurni da zelite da obrisete ovu kampanju?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Otkazi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CampaignBloc>().add(DeleteCampaign(id));
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: AppColors.destructiveForeground,
            ),
            child: const Text('Obrisi'),
          ),
        ],
      ),
    );
  }
}
