import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_format.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/ui/ui.dart';
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

class _CampaignDetailView extends StatefulWidget {
  final String campaignId;

  const _CampaignDetailView({required this.campaignId});

  @override
  State<_CampaignDetailView> createState() => _CampaignDetailViewState();
}

class _CampaignDetailViewState extends State<_CampaignDetailView> {
  /// Poslednje učitana kampanja; ostaje vidljiva dok se menja status.
  CampaignDto? _last;
  bool _deleting = false;

  int get _id => int.tryParse(widget.campaignId) ?? 0;

  Future<void> _edit() async {
    final bloc = context.read<CampaignBloc>();
    await context.push('/app/campaigns/${widget.campaignId}/edit');
    if (mounted) bloc.add(LoadCampaignDetail(_id));
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
              title: Text(l10n.campaignDetail),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: _edit,
                  tooltip: 'Izmeni',
                ),
              ],
            ),
      body: BlocConsumer<CampaignBloc, CampaignState>(
        listener: (context, state) {
          if (state is CampaignFormSuccess) {
            AppSnackbar.show(context, state.message);
            // Posle uspešnog brisanja vraća se na listu, koja se tada osvežava.
            if (_deleting) context.pop();
          } else if (state is CampaignError) {
            _deleting = false;
            AppSnackbar.show(context, state.message, isError: true);
          }
        },
        buildWhen: (previous, current) => current is! CampaignFormSuccess,
        builder: (context, state) {
          if (state is CampaignDetailLoaded) _last = state.campaign;
          final campaign = _last;
          final busy = state is CampaignLoading || state is CampaignInitial;

          if (campaign == null) {
            if (state is CampaignError) {
              return EmptyState(
                icon: Icons.cloud_off_rounded,
                title: 'Kampanja trenutno nije dostupna',
                message: state.message,
                action: OutlinedButton.icon(
                  onPressed: () =>
                      context.read<CampaignBloc>().add(LoadCampaignDetail(_id)),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(l10n.retry),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final side = wide ? 32.0 : 16.0;
                  final gutter =
                      math.max(side, (constraints.maxWidth - 1240) / 2);
                  final contentWidth = constraints.maxWidth - 2 * gutter;
                  return SingleChildScrollView(
                    padding:
                        EdgeInsets.fromLTRB(gutter, wide ? 0 : 16, gutter, 40),
                    child: _buildContent(
                        context, campaign, wide, contentWidth, busy, l10n),
                  );
                },
              ),
              if (busy)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(minHeight: 2),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, CampaignDto campaign, bool wide,
      double width, bool busy, AppLocalizations l10n) {
    final raw = (campaign.status ?? 'DRAFT').toUpperCase();
    final status = CampaignStatus.fromApi(campaign.status);
    final name = (campaign.name == null || campaign.name!.trim().isEmpty)
        ? 'Kampanja #${campaign.id}'
        : campaign.name!;
    final transitions = raw == 'CANCELLED'
        ? <(CampaignStatus, String, bool)>[]
        : _transitions(status);
    final subtitle = _headerSubtitle(campaign);

    final header = wide
        ? PageHeader(
            title: name,
            subtitle: subtitle,
            showBack: true,
            padding: const EdgeInsets.only(top: 28, bottom: 22),
            actions: [
              OutlinedButton.icon(
                onPressed: _edit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Izmeni'),
              ),
              for (final t in transitions.where((t) => t.$3))
                FilledButton(
                  onPressed: busy ? null : () => _changeStatus(t.$1),
                  child: Text(t.$2),
                ),
            ],
          )
        : Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.h4),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.mutedForeground)),
                ],
              ],
            ),
          );

    final overview = SectionCard(
      title: 'Pregled',
      trailing: CampaignStatusBadge(status: status, raw: campaign.status),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FactsGrid(facts: [
            MetaItem(
              label: 'Period zakupa',
              value: (campaign.startDate == null && campaign.endDate == null)
                  ? 'Nije određen'
                  : SrFormat.period(campaign.startDate, campaign.endDate),
            ),
            MetaItem(
              label: 'Trajanje',
              value: _days(campaign).isEmpty ? '—' : _days(campaign),
            ),
            MetaItem(
              label: l10n.budget,
              value: campaign.budget == null
                  ? 'Nije unet'
                  : SrFormat.money(campaign.budget, 'EUR'),
              emphasize: campaign.budget != null,
            ),
            MetaItem(
              label: 'Brend',
              value: (campaign.brandUsername == null ||
                      campaign.brandUsername!.isEmpty)
                  ? '—'
                  : campaign.brandUsername!,
            ),
            MetaItem(
              label: 'Kreirana',
              value: campaign.createdAt == null
                  ? '—'
                  : SrFormat.date(campaign.createdAt),
            ),
          ]),
          if (campaign.description != null &&
              campaign.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 14),
            Text('Opis',
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.mutedForeground)),
            const SizedBox(height: 4),
            Text(campaign.description!,
                style:
                    AppTypography.bodyMedium.copyWith(color: AppColors.text2)),
          ],
        ],
      ),
    );

    final timeline = SectionCard(
      title: 'Tok kampanje',
      child: raw == 'CANCELLED'
          ? Text('Kampanja je otkazana.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.text2))
          : _StatusTimeline(current: raw),
    );

    // Završena ili otkazana kampanja nema prelaza, pa ni ove kartice.
    final Widget? nextStep = transitions.isEmpty
        ? null
        : SectionCard(
            title: 'Sledeći korak',
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final t in transitions)
                  t.$3
                      ? FilledButton(
                          onPressed: busy ? null : () => _changeStatus(t.$1),
                          child: Text(t.$2),
                        )
                      : OutlinedButton(
                          onPressed: busy ? null : () => _changeStatus(t.$1),
                          child: Text(t.$2),
                        ),
              ],
            ),
          );

    final danger = SectionCard(
      title: 'Brisanje kampanje',
      child: Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          onPressed: () => _confirmDelete(context, campaign.id),
          icon: const Icon(Icons.delete_outline_rounded, size: 18),
          label: const Text('Obriši kampanju'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.destructive,
            side: BorderSide(
                color: AppColors.destructive.withValues(alpha: 0.35)),
          ),
        ),
      ),
    );

    const gap = SizedBox(height: 16);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        if (width >= 900)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(children: [overview, gap, timeline]),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: Column(children: [
                  if (nextStep != null) ...[nextStep, gap],
                  danger,
                ]),
              ),
            ],
          )
        else ...[
          overview,
          gap,
          timeline,
          gap,
          if (nextStep != null) ...[nextStep, gap],
          danger,
        ],
      ],
    );
  }

  /// "1.12. – 28.12.2026, budžet 2.500 €, brend"; bez podataka nema podnaslova.
  String? _headerSubtitle(CampaignDto c) {
    final parts = <String>[
      if (c.startDate != null || c.endDate != null)
        SrFormat.period(c.startDate, c.endDate),
      if (c.budget != null) 'budžet ${SrFormat.money(c.budget, 'EUR')}',
      if (c.brandUsername != null && c.brandUsername!.isNotEmpty)
        c.brandUsername!,
    ];
    return parts.isEmpty ? null : parts.join(', ');
  }

  String _days(CampaignDto c) =>
      SrFormat.daysLabel(SrFormat.days(c.startDate, c.endDate));

  /// Dozvoljeni prelazi statusa: (novi status, tekst dugmeta, da li je glavni).
  List<(CampaignStatus, String, bool)> _transitions(CampaignStatus current) {
    switch (current) {
      case CampaignStatus.draft:
        return [(CampaignStatus.inNegotiation, 'Započni pregovore', true)];
      case CampaignStatus.inNegotiation:
        return [
          (CampaignStatus.booked, 'Potvrdi zakup', true),
          (CampaignStatus.draft, 'Vrati u nacrt', false),
        ];
      case CampaignStatus.booked:
        return [(CampaignStatus.running, 'Pokreni kampanju', true)];
      case CampaignStatus.running:
        return [(CampaignStatus.finished, 'Završi kampanju', true)];
      case CampaignStatus.finished:
        return [];
    }
  }

  void _changeStatus(CampaignStatus next) {
    context
        .read<CampaignBloc>()
        .add(ChangeStatus(_id, CampaignStatusBadge.apiValue(next)));
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Obrisati kampanju?'),
        content: const SizedBox(
          width: 420,
          child: Text(
              'Kampanja se trajno uklanja sa liste. Ova radnja se ne može poništiti.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Otkaži'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _deleting = true;
              context.read<CampaignBloc>().add(DeleteCampaign(id));
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: AppColors.destructiveForeground,
            ),
            child: const Text('Obriši'),
          ),
        ],
      ),
    );
  }
}

/// Podaci kampanje u dve ili tri kolone.
class _FactsGrid extends StatelessWidget {
  final List<Widget> facts;

  const _FactsGrid({required this.facts});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 640
            ? 3
            : (constraints.maxWidth >= 380 ? 2 : 1);
        final w = (constraints.maxWidth - (cols - 1) * 16) / cols;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [for (final f in facts) SizedBox(width: w, child: f)],
        );
      },
    );
  }
}

/// Faze kampanje od nacrta do završetka; trenutna je istaknuta.
class _StatusTimeline extends StatelessWidget {
  final String current;

  const _StatusTimeline({required this.current});

  static const _steps = [
    'DRAFT',
    'IN_NEGOTIATION',
    'BOOKED',
    'RUNNING',
    'FINISHED',
  ];

  @override
  Widget build(BuildContext context) {
    final index = math.max(0, _steps.indexOf(current));
    return LayoutBuilder(
      builder: (context, constraints) {
        final vertical = constraints.maxWidth < 620;
        final items = [
          for (var i = 0; i < _steps.length; i++)
            _StepDot(
              label: CampaignStatusBadge.labelFor(_steps[i]),
              done: i < index,
              active: i == index,
            ),
        ];
        if (vertical) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < items.length; i++) ...[
                items[i],
                if (i < items.length - 1)
                  Container(
                    margin: const EdgeInsets.only(left: 11),
                    width: 2,
                    height: 14,
                    color: i < index ? AppColors.primary : AppColors.border,
                  ),
              ],
            ],
          );
        }
        return Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              items[i],
              if (i < items.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    color: i < index ? AppColors.primary : AppColors.border,
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool done;
  final bool active;

  const _StepDot(
      {required this.label, required this.done, required this.active});

  @override
  Widget build(BuildContext context) {
    final filled = done || active;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? AppColors.primary : AppColors.surface,
            border: Border.all(
              color: filled ? AppColors.primary : AppColors.input,
              width: 1.5,
            ),
          ),
          child: done
              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
              : (active
                  ? const Center(
                      child: SizedBox(
                        width: 8,
                        height: 8,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                        ),
                      ),
                    )
                  : null),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: filled ? AppColors.foreground : AppColors.mutedForeground,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
