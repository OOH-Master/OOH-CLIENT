import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_format.dart';
import '../../../../core/widgets/ui/ui.dart';
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
        ..add(const LoadCampaigns()),
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
  static const _statusOrder = [
    'DRAFT',
    'IN_NEGOTIATION',
    'BOOKED',
    'RUNNING',
    'FINISHED',
    'CANCELLED',
  ];

  /// Izabrani status u API obliku ("RUNNING"); null znači svi.
  String? _status;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static String _rawStatus(CampaignDto c) =>
      (c.status == null || c.status!.isEmpty)
          ? 'DRAFT'
          : c.status!.toUpperCase();

  List<CampaignDto> _filterCampaigns(List<CampaignDto> campaigns) {
    return campaigns.where((c) {
      if (_status != null && _rawStatus(c) != _status) return false;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = (c.name ?? '').toLowerCase();
        final brand = (c.brandUsername ?? '').toLowerCase();
        if (!name.contains(query) && !brand.contains(query)) return false;
      }
      return true;
    }).toList();
  }

  Future<void> _open(String location) async {
    final bloc = context.read<CampaignBloc>();
    await context.push(location);
    // Posle detalja ili forme lista se osvežava (promena statusa, brisanje, nova kampanja).
    if (mounted) bloc.add(const LoadCampaigns());
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _status = null;
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: wide
          ? null
          : AppBar(
              title: Text(l10n.campaigns),
              actions: [
                IconButton(
                  icon: const Icon(Icons.calendar_month_outlined),
                  tooltip: 'Kalendar kampanja',
                  onPressed: () => _open('/app/campaigns/calendar'),
                ),
              ],
            ),
      floatingActionButton: wide
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _open('/app/campaigns/create'),
              icon: const Icon(Icons.add_rounded),
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
        buildWhen: (previous, current) => current is! CampaignFormSuccess,
        builder: (context, state) {
          if (state is CampaignError) {
            return EmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Kampanje trenutno nisu dostupne',
              message: state.message,
              action: OutlinedButton.icon(
                onPressed: () =>
                    context.read<CampaignBloc>().add(const LoadCampaigns()),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(l10n.retry),
              ),
            );
          }
          if (state is! CampaignsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final campaigns = state.campaigns;
          final filtered = _filterCampaigns(campaigns);

          return LayoutBuilder(
            builder: (context, constraints) {
              final side = wide ? 32.0 : 16.0;
              final gutter = math.max(side, (constraints.maxWidth - 1240) / 2);
              final contentWidth = constraints.maxWidth - 2 * gutter;

              return RefreshIndicator(
                onRefresh: () async =>
                    context.read<CampaignBloc>().add(const LoadCampaigns()),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      EdgeInsets.fromLTRB(gutter, wide ? 0 : 16, gutter, 96),
                  children: [
                    if (wide)
                      PageHeader(
                        title: l10n.campaigns,
                        subtitle: _summary(campaigns),
                        padding: const EdgeInsets.only(top: 28, bottom: 22),
                        actions: [
                          OutlinedButton.icon(
                            onPressed: () => _open('/app/campaigns/calendar'),
                            icon: const Icon(Icons.calendar_month_outlined,
                                size: 18),
                            label: const Text('Kalendar'),
                          ),
                          FilledButton.icon(
                            onPressed: () => _open('/app/campaigns/create'),
                            icon: const Icon(Icons.add_rounded, size: 20),
                            label: Text(l10n.newCampaign),
                          ),
                        ],
                      )
                    else if (_summary(campaigns) != null) ...[
                      Text(_summary(campaigns)!,
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.mutedForeground)),
                      const SizedBox(height: 14),
                    ],
                    if (campaigns.isEmpty)
                      SectionCard(
                        child: EmptyState(
                          icon: Icons.campaign_outlined,
                          title: 'Još nema kampanja',
                          message:
                              'Napravite kampanju ručno ili prihvatite ponudu za upit.',
                          action: FilledButton.icon(
                            onPressed: () => _open('/app/campaigns/create'),
                            icon: const Icon(Icons.add_rounded, size: 20),
                            label: Text(l10n.newCampaign),
                          ),
                        ),
                      )
                    else ...[
                      _CampaignKpis(campaigns: campaigns),
                      const SizedBox(height: 16),
                      _buildToolbar(campaigns),
                      const SizedBox(height: 16),
                      if (filtered.isEmpty)
                        SectionCard(
                          child: EmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'Nema kampanja za ovaj izbor',
                            message: 'Promenite pretragu ili status.',
                            action: OutlinedButton(
                              onPressed: _resetFilters,
                              child: const Text('Poništi filtere'),
                            ),
                          ),
                        )
                      else if (contentWidth >= 860)
                        _CampaignTable(
                          campaigns: filtered,
                          onOpen: (c) => _open('/app/campaigns/${c.id}'),
                        )
                      else
                        for (final c in filtered)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _CampaignCard(
                              campaign: c,
                              onTap: () => _open('/app/campaigns/${c.id}'),
                            ),
                          ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// "5 kampanja, 2 u toku"; bez kampanja nema podnaslova.
  String? _summary(List<CampaignDto> campaigns) {
    if (campaigns.isEmpty) return null;
    final running = campaigns.where((c) => _rawStatus(c) == 'RUNNING').length;
    return '${SrFormat.count(campaigns.length, 'kampanja', 'kampanje', 'kampanja')}'
        ', ${running == 0 ? 'nijedna u toku' : '$running u toku'}';
  }

  Widget _buildToolbar(List<CampaignDto> campaigns) {
    final counts = <String, int>{};
    for (final c in campaigns) {
      counts.update(_rawStatus(c), (v) => v + 1, ifAbsent: () => 1);
    }
    final statuses = _statusOrder
        .where((s) => s != 'CANCELLED' || (counts[s] ?? 0) > 0)
        .toList();

    final search = TextField(
      controller: _searchController,
      onChanged: (v) => setState(() => _searchQuery = v),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Pretraži po nazivu ili brendu',
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
                tooltip: 'Obriši pretragu',
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              ),
      ),
    );

    Widget chip(String? value, String label, int count) {
      final selected = _status == value;
      return ChoiceChip(
        label: Text('$label  $count'),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => setState(() => _status = value),
        selectedColor: AppColors.primarySoft,
        side:
            BorderSide(color: selected ? AppColors.primary : AppColors.border),
        labelStyle: AppTypography.labelMedium.copyWith(
          color: selected ? AppColors.primaryStrong : AppColors.text2,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        ),
      );
    }

    final chips = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        chip(null, 'Sve', campaigns.length),
        for (final s in statuses)
          chip(s, CampaignStatusBadge.labelFor(s), counts[s] ?? 0),
      ],
    );

    return DecoratedBox(
      decoration: AppDecorations.card(),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 980) {
              return Row(
                children: [
                  SizedBox(width: 320, child: search),
                  const SizedBox(width: 16),
                  Expanded(child: chips),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [search, const SizedBox(height: 12), chips],
            );
          },
        ),
      ),
    );
  }
}

/// Brzi pregled: broj kampanja, u toku, zakupljene i ukupan budžet.
class _CampaignKpis extends StatelessWidget {
  final List<CampaignDto> campaigns;

  const _CampaignKpis({required this.campaigns});

  @override
  Widget build(BuildContext context) {
    int count(String s) =>
        campaigns.where((c) => (c.status ?? 'DRAFT').toUpperCase() == s).length;
    final budget = campaigns.fold<double>(0, (sum, c) => sum + (c.budget ?? 0));
    final withBudget = campaigns.where((c) => c.budget != null).length;

    return StatStrip(items: [
      StatItem('Kampanje', '${campaigns.length}',
          note: SrFormat.count(count('DRAFT'), 'nacrt', 'nacrta', 'nacrta')),
      StatItem('U toku', '${count('RUNNING')}'),
      StatItem('Zakupljene', '${count('BOOKED')}',
          note: '${count('IN_NEGOTIATION')} u pregovorima'),
      StatItem('Ukupan budžet', SrFormat.money(budget, 'EUR', decimals: false),
          note: SrFormat.count(withBudget, 'kampanja sa budžetom',
              'kampanje sa budžetom', 'kampanja sa budžetom')),
    ]);
  }
}

String _periodLabel(CampaignDto c) {
  if (c.startDate == null && c.endDate == null) return 'Period nije određen';
  return SrFormat.period(c.startDate, c.endDate);
}

String _daysLabel(CampaignDto c) =>
    SrFormat.daysLabel(SrFormat.days(c.startDate, c.endDate));

String _title(CampaignDto c) {
  final n = c.name?.trim();
  return (n == null || n.isEmpty) ? 'Kampanja #${c.id}' : n;
}

/// Tabela kampanja na širokom ekranu.
class _CampaignTable extends StatelessWidget {
  final List<CampaignDto> campaigns;
  final ValueChanged<CampaignDto> onOpen;

  const _CampaignTable({required this.campaigns, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final head =
        AppTypography.labelSmall.copyWith(color: AppColors.mutedForeground);
    return DecoratedBox(
      decoration: AppDecorations.card(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 11, 12, 11),
            decoration: const BoxDecoration(
              color: AppColors.surfaceSunken,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(flex: 5, child: Text('Kampanja', style: head)),
                Expanded(flex: 3, child: Text('Period', style: head)),
                Expanded(flex: 2, child: Text('Brend', style: head)),
                Expanded(
                  flex: 2,
                  child:
                      Text('Budžet', style: head, textAlign: TextAlign.right),
                ),
                const SizedBox(width: 24),
                SizedBox(width: 130, child: Text('Status', style: head)),
              ],
            ),
          ),
          for (var i = 0; i < campaigns.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.borderSoft),
            _CampaignRow(
              campaign: campaigns[i],
              onTap: () => onOpen(campaigns[i]),
              last: i == campaigns.length - 1,
            ),
          ],
        ],
      ),
    );
  }
}

class _CampaignRow extends StatefulWidget {
  final CampaignDto campaign;
  final VoidCallback onTap;
  final bool last;

  const _CampaignRow(
      {required this.campaign, required this.onTap, required this.last});

  @override
  State<_CampaignRow> createState() => _CampaignRowState();
}

class _CampaignRowState extends State<_CampaignRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.campaign;
    final days = _daysLabel(c);
    final radius = widget.last
        ? const BorderRadius.vertical(bottom: Radius.circular(AppRadius.card))
        : BorderRadius.zero;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: _hover
            ? AppColors.surfaceSunken.withValues(alpha: 0.6)
            : Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_title(c),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              AppTypography.labelLarge.copyWith(fontSize: 15)),
                      if (c.description != null && c.description!.isNotEmpty)
                        Text(
                          c.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption
                              .copyWith(color: AppColors.mutedForeground),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_periodLabel(c),
                          style: AppTypography.labelMedium
                              .copyWith(color: AppColors.foreground)),
                      if (days.isNotEmpty)
                        Text(days,
                            style: AppTypography.caption
                                .copyWith(color: AppColors.mutedForeground)),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    c.brandUsername == null || c.brandUsername!.isEmpty
                        ? '—'
                        : c.brandUsername!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.text2),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    c.budget == null ? '—' : SrFormat.money(c.budget, 'EUR'),
                    textAlign: TextAlign.right,
                    style: c.budget == null
                        ? AppTypography.bodySmall
                            .copyWith(color: AppColors.subtle)
                        : AppTypography.money.copyWith(fontSize: 15),
                  ),
                ),
                const SizedBox(width: 24),
                SizedBox(
                  width: 130,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CampaignStatusBadge(
                      status: CampaignStatus.fromApi(c.status),
                      raw: c.status,
                      dense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartica kampanje za uži ekran.
class _CampaignCard extends StatelessWidget {
  final CampaignDto campaign;
  final VoidCallback onTap;

  const _CampaignCard({required this.campaign, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = campaign;
    final days = _daysLabel(c);

    return SectionCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(_title(c),
                    style: AppTypography.labelLarge.copyWith(fontSize: 15.5)),
              ),
              const SizedBox(width: 8),
              CampaignStatusBadge(
                status: CampaignStatus.fromApi(c.status),
                raw: c.status,
                dense: true,
              ),
            ],
          ),
          if (c.description != null && c.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              c.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.mutedForeground),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 18,
            runSpacing: 10,
            children: [
              MetaItem(
                label: 'Period',
                value: _periodLabel(c),
                note: days,
              ),
              MetaItem(
                label: 'Budžet',
                value: c.budget == null ? '—' : SrFormat.money(c.budget, 'EUR'),
                emphasize: c.budget != null,
              ),
              if (c.brandUsername != null && c.brandUsername!.isNotEmpty)
                MetaItem(
                  label: 'Brend',
                  value: c.brandUsername!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
