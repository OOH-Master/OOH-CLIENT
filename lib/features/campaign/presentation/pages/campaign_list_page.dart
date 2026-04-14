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
import '../widgets/campaign_status_badge.dart';

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

class _CampaignListView extends StatefulWidget {
  const _CampaignListView();

  @override
  State<_CampaignListView> createState() => _CampaignListViewState();
}

class _CampaignListViewState extends State<_CampaignListView> {
  CampaignStatus? _selectedStatus;
  String _searchQuery = '';

  List<CampaignDto> _filterCampaigns(List<CampaignDto> campaigns) {
    return campaigns.where((c) {
      if (_selectedStatus != null && CampaignStatus.fromApi(c.status) != _selectedStatus) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = (c.name ?? '').toLowerCase();
        final brand = (c.brandUsername ?? '').toLowerCase();
        if (!name.contains(query) && !brand.contains(query)) return false;
      }
      return true;
    }).toList();
  }

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
      body: Column(
        children: [
          // Filter bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Pretrazi kampanje...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                DropdownButton<CampaignStatus?>(
                  value: _selectedStatus,
                  hint: const Text('Svi statusi'),
                  underline: const SizedBox.shrink(),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Svi statusi')),
                    ...CampaignStatus.values.map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(_statusLabel(s, l10n)),
                    )),
                  ],
                  onChanged: (v) => setState(() => _selectedStatus = v),
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: BlocConsumer<CampaignBloc, CampaignState>(
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
                          onPressed: () => context.read<CampaignBloc>().add(LoadCampaigns()),
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  );
                }

                if (state is CampaignsLoaded) {
                  final filtered = _filterCampaigns(state.campaigns);
                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.campaign_outlined, size: 64, color: AppColors.mutedForeground),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            l10n.noCampaigns,
                            style: AppTypography.bodyLarge.copyWith(color: AppColors.mutedForeground),
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
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final campaign = filtered[index];
                        return _CampaignCard(campaign: campaign);
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(CampaignStatus s, AppLocalizations l10n) {
    return switch (s) {
      CampaignStatus.draft => l10n.statusDraft,
      CampaignStatus.inNegotiation => l10n.statusInNegotiation,
      CampaignStatus.booked => l10n.statusBooked,
      CampaignStatus.running => l10n.statusRunning,
      CampaignStatus.finished => l10n.statusFinished,
    };
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

    return GestureDetector(
      onTap: () => context.push('/app/campaigns/${campaign.id}'),
      child: Container(
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
                CampaignStatusBadge(status: status),
              ],
            ),
            if (campaign.description != null) ...[
              const SizedBox(height: 4),
              Text(
                campaign.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                if (campaign.startDate != null || campaign.endDate != null) ...[
                  Icon(Icons.calendar_today, size: 14, color: AppColors.mutedForeground),
                  const SizedBox(width: 4),
                  Text(
                    '${campaign.startDate ?? '—'} — ${campaign.endDate ?? '—'}',
                    style: AppTypography.caption.copyWith(color: AppColors.mutedForeground),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                if (campaign.budget != null) ...[
                  Icon(Icons.monetization_on, size: 14, color: AppColors.mutedForeground),
                  const SizedBox(width: 4),
                  Text(
                    priceFormatter.format(campaign.budget),
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
                    style: AppTypography.caption.copyWith(color: AppColors.mutedForeground),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
