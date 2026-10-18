import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/result.dart';
import '../../../../core/utils/sr_format.dart';
import '../../../../core/utils/sr_labels.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../inquiry/domain/entities/inquiry.dart';
import '../../../inventory_management/data/repository/inventory_management_repository.dart';
import '../../data/models/dashboard_models.dart';
import '../../data/repository/analytics_repository.dart';
import '../blocs/analytics_bloc.dart';
import 'base_dashboard.dart';
import 'dashboard_charts.dart';
import 'dashboard_rows.dart';

/// Kontrolna tabla vlasnika medija.
class MediaOwnerDashboard extends StatelessWidget {
  final User user;

  const MediaOwnerDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnalyticsBloc(context.read<AnalyticsRepository>())
        ..add(LoadMediaOwnerAnalytics()),
      child: _MediaOwnerBody(user: user),
    );
  }
}

/// Zahtevi za ponude i statusi površina; `null` znači da poziv nije uspeo.
class _OwnerData {
  final List<OwnerQuoteSummary>? quotes;
  final List<String?>? inventoryStatuses;

  const _OwnerData({this.quotes, this.inventoryStatuses});
}

class _MediaOwnerBody extends StatefulWidget {
  final User user;

  const _MediaOwnerBody({required this.user});

  @override
  State<_MediaOwnerBody> createState() => _MediaOwnerBodyState();
}

class _MediaOwnerBodyState extends State<_MediaOwnerBody> {
  late Future<_OwnerData> _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final quotes = context
        .read<AnalyticsRepository>()
        .getMediaOwnerQuotes()
        .then<List<OwnerQuoteSummary>?>((r) => switch (r) {
              Success(data: final d) => d,
              Error() => null,
            });
    final inventory = context
        .read<InventoryManagementRepository>()
        .getMyInventory()
        .then<List<String?>?>((items) => items.map((i) => i.status).toList())
        .catchError((Object _) => null);
    _data = Future.wait<Object?>([quotes, inventory]).then((r) => _OwnerData(
          quotes: r[0] as List<OwnerQuoteSummary>?,
          inventoryStatuses: r[1] as List<String?>?,
        ));
  }

  Future<void> _refresh() async {
    setState(_load);
    context.read<AnalyticsBloc>().add(LoadMediaOwnerAnalytics());
    await _data;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, analyticsState) {
        final analytics = analyticsState is AnalyticsLoaded
            ? DashboardAnalytics.fromMap(analyticsState.data)
            : null;
        final analyticsLoading = analyticsState is! AnalyticsLoaded;

        return FutureBuilder<_OwnerData>(
          future: _data,
          builder: (context, snapshot) {
            final loading = snapshot.connectionState != ConnectionState.done;
            final data = snapshot.data ?? const _OwnerData();
            return DashboardScaffold(
              subtitle: dashboardSubtitle(widget.user),
              actions: [
                FilledButton(
                  onPressed: () => context.push('/app/media-owner/quotes'),
                  child: const Text('Zahtevi za ponude'),
                ),
                OutlinedButton(
                  onPressed: () => context.push('/app/inventory/create'),
                  child: const Text('Dodaj površinu'),
                ),
              ],
              onRefresh: _refresh,
              children: [
                _kpis(context, data, loading, analytics, analyticsLoading),
                DashboardColumns(
                  left: _pendingCard(context, data, loading),
                  right: _inquiryStatusCard(
                      data, loading, analytics, analyticsLoading),
                ),
                DashboardColumns(
                  left: _topUnitsCard(context, data, loading),
                  right: _quoteStatusCard(data, loading),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ── Brojke ──────────────────────────────────────────────────────────────

  Widget _kpis(BuildContext context, _OwnerData data, bool loading,
      DashboardAnalytics? analytics, bool analyticsLoading) {
    const loadingNote = 'Učitavanje…';
    if (loading) {
      return const StatStrip(items: [
        StatItem('Površine u inventaru', '—', note: loadingNote),
        StatItem('Novi zahtevi za ponude', '—', note: loadingNote),
        StatItem('Stopa prihvatanja', '—', note: loadingNote),
        StatItem('Prihod od prihvaćenih ponuda', '—', note: loadingNote),
      ]);
    }

    final quotes = data.quotes;
    final statuses = data.inventoryStatuses;
    final inventoryCount = analytics?.inventoryCount ?? statuses?.length;
    final activeCount =
        statuses?.where((s) => s == null || s.toUpperCase() == 'ACTIVE').length;
    final newCount = quotes?.where((q) => q.status == 'NEW').length;
    final inProgress =
        quotes?.where((q) => q.status == 'IN_PROGRESS').length ?? 0;

    // Stopa: prihvaćeno / (prihvaćeno + odbijeno) među upitima sa vašim površinama.
    var accepted = 0;
    var rejected = 0;
    final byStatus = analytics?.inquiriesByStatus ?? const {};
    if (byStatus.isNotEmpty) {
      accepted = (byStatus[InquiryStatus.acceptedByClient] ?? 0) +
          (byStatus[InquiryStatus.realized] ?? 0);
      rejected = byStatus[InquiryStatus.rejectedByClient] ?? 0;
    } else if (quotes != null) {
      accepted = quotes.where((q) => q.isAccepted).length;
      rejected = quotes
          .where((q) => q.inquiryStatus == InquiryStatus.rejectedByClient)
          .length;
    }
    final decided = accepted + rejected;

    // Prihod: zbir cena prihvaćenih ponuda, po valutama.
    final revenue = CurrencySum();
    final acceptedQuotes = quotes?.where((q) => q.isAccepted).toList() ?? [];
    for (final q in acceptedQuotes) {
      revenue.addAll(q.amounts);
    }
    final revenueTotals = revenue.totals.entries.toList();
    final homeCurrency = quotes
            ?.expand((q) => q.items)
            .map((i) => i.currency)
            .whereType<String>()
            .firstOrNull ??
        'EUR';

    return StatStrip(items: [
      StatItem(
        'Površine u inventaru',
        inventoryCount?.toString() ?? '—',
        note: activeCount == null
            ? null
            : SrFormat.count(activeCount, 'aktivna', 'aktivne', 'aktivnih'),
        onTap: () => context.push('/app/my-inventory'),
      ),
      StatItem(
        'Novi zahtevi za ponude',
        newCount?.toString() ?? '—',
        note: quotes == null
            ? 'Podaci nisu učitani'
            : inProgress > 0
                ? '$inProgress u izradi'
                : null,
        onTap: () => context.push('/app/media-owner/quotes'),
      ),
      StatItem(
        'Stopa prihvatanja',
        decided == 0 ? '—' : '${(accepted * 100 / decided).round()} %',
        note: decided == 0
            ? (analyticsLoading && quotes == null ? loadingNote : null)
            : 'prihvaćeno $accepted od $decided',
      ),
      StatItem(
        'Prihod od prihvaćenih ponuda',
        revenueTotals.isEmpty
            ? SrFormat.money(0, homeCurrency)
            : SrFormat.money(revenueTotals.first.value, revenueTotals.first.key,
                decimals: false),
        note: revenueTotals.length > 1
            ? '+ ${revenueTotals.skip(1).map((e) => SrFormat.money(e.value, e.key, decimals: false)).join(', ')}'
            : acceptedQuotes.isEmpty
                ? null
                : SrFormat.count(acceptedQuotes.length, 'prihvaćena ponuda',
                    'prihvaćene ponude', 'prihvaćenih ponuda'),
      ),
    ]);
  }

  // ── Sekcije ─────────────────────────────────────────────────────────────

  Widget _pendingCard(BuildContext context, _OwnerData data, bool loading) {
    final quotes = data.quotes;
    Widget child;
    var rows = false;
    var open = <OwnerQuoteSummary>[];
    if (loading) {
      child = const SectionSkeleton(rows: 4);
    } else if (quotes == null) {
      child = SectionFailure(onRetry: _refresh);
    } else {
      open = quotes.where((q) => q.isOpen).toList()
        ..sort((a, b) {
          final da = a.created;
          final db = b.created;
          if (da != null && db != null) return db.compareTo(da);
          return b.id.compareTo(a.id);
        });
      if (open.isEmpty) {
        child = const EmptyState(
          compact: true,
          icon: Icons.inbox_outlined,
          title: 'Nema zahteva na čekanju',
        );
      } else {
        final shown = open.take(5).toList();
        rows = true;
        child = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < shown.length; i++) ...[
              if (i > 0) const RowDivider(),
              QuoteRequestRow(
                quote: shown[i],
                onTap: () => context.push('/app/media-owner/quotes'),
              ),
            ],
            if (open.length > shown.length) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: SectionLink(
                  label:
                      'Još ${SrFormat.count(open.length - shown.length, 'zahtev', 'zahteva', 'zahteva')}',
                  onTap: () => context.push('/app/media-owner/quotes'),
                ),
              ),
            ],
          ],
        );
      }
    }

    return ListSectionCard(
      title: 'Zahtevi koji čekaju odgovor',
      subtitle: open.isEmpty
          ? null
          : SrFormat.count(open.length, 'zahtev', 'zahteva', 'zahteva'),
      rows: rows,
      trailing: SectionLink(
          label: 'Zahtevi za ponude',
          onTap: () => context.push('/app/media-owner/quotes')),
      child: child,
    );
  }

  Widget _inquiryStatusCard(_OwnerData data, bool loading,
      DashboardAnalytics? analytics, bool analyticsLoading) {
    Map<InquiryStatus, int>? counts;
    if (analytics != null &&
        !analytics.failed &&
        analytics.inquiriesByStatus.isNotEmpty) {
      counts = analytics.inquiriesByStatus;
    } else if (data.quotes != null) {
      final raw = <InquiryStatus, int>{};
      for (final q in data.quotes!) {
        final s = q.inquiryStatus;
        if (s != null) raw[s] = (raw[s] ?? 0) + 1;
      }
      counts = {
        for (final s in InquiryStatus.values)
          if (raw.containsKey(s)) s: raw[s]!,
      };
    }

    final total = counts?.values.fold<int>(0, (a, b) => a + b) ?? 0;

    Widget child;
    if (counts != null) {
      child = PipelineBars(counts: counts);
    } else if (loading || analyticsLoading) {
      child = const SectionSkeleton(rows: 4);
    } else {
      child = SectionFailure(onRetry: _refresh);
    }
    return SectionCard(
      title: 'Upiti na vašim površinama',
      subtitle:
          total > 0 ? SrFormat.count(total, 'upit', 'upita', 'upita') : null,
      child: child,
    );
  }

  Widget _topUnitsCard(BuildContext context, _OwnerData data, bool loading) {
    final quotes = data.quotes;
    Widget child;
    var rows = false;
    if (loading) {
      child = const SectionSkeleton(rows: 3);
    } else if (quotes == null) {
      child = SectionFailure(onRetry: _refresh);
    } else {
      // Koliko zahteva je obuhvatilo svaku površinu.
      final byUnit = <String, (QuoteUnitLine, int)>{};
      for (final q in quotes) {
        for (final item in q.items) {
          final key = item.unitId?.toString() ?? item.code ?? item.title;
          final existing = byUnit[key];
          if (existing == null) {
            byUnit[key] = (item, 1);
          } else {
            final richer = existing.$1.imageUrl == null && item.imageUrl != null
                ? item
                : existing.$1;
            byUnit[key] = (richer, existing.$2 + 1);
          }
        }
      }
      final ranked = byUnit.values.toList()
        ..sort((a, b) => b.$2.compareTo(a.$2));
      if (ranked.isEmpty) {
        child = const EmptyState(
          compact: true,
          icon: Icons.view_quilt_outlined,
          title: 'Još nema traženih površina',
        );
      } else {
        final shown = ranked.take(5).toList();
        rows = true;
        child = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < shown.length; i++) ...[
              if (i > 0) const RowDivider(),
              TopUnitRow(
                unit: shown[i].$1,
                requests: shown[i].$2,
                onTap: shown[i].$1.unitId == null
                    ? null
                    : () => context
                        .push('/app/inventory/${shown[i].$1.unitId}/edit'),
              ),
            ],
          ],
        );
      }
    }
    return ListSectionCard(
      title: 'Najtraženije površine',
      rows: rows,
      trailing: SectionLink(
          label: 'Moj inventar',
          onTap: () => context.push('/app/my-inventory')),
      child: child,
    );
  }

  Widget _quoteStatusCard(_OwnerData data, bool loading) {
    final quotes = data.quotes;
    Widget child;
    if (loading) {
      child = const SectionSkeleton(rows: 3);
    } else if (quotes == null) {
      child = SectionFailure(onRetry: _refresh);
    } else {
      const order = ['NEW', 'IN_PROGRESS', 'SUBMITTED', 'DECLINED'];
      final entries = [
        for (final s in order)
          MapEntry(SrLabels.quoteStatus(s),
              quotes.where((q) => q.status == s).length),
      ];
      child = RankedBars(
        entries: entries,
        colorOf: (label) => quoteTone(order.firstWhere(
                (s) => SrLabels.quoteStatus(s) == label,
                orElse: () => ''))
            .solid,
        maxItems: 4,
        unitLabel: (n) => SrFormat.count(n, 'zahtev', 'zahteva', 'zahteva'),
      );
    }
    return SectionCard(
      title: 'Zahtevi po statusu',
      subtitle: quotes == null || quotes.isEmpty
          ? null
          : SrFormat.count(quotes.length, 'zahtev', 'zahteva', 'zahteva'),
      child: child,
    );
  }
}
