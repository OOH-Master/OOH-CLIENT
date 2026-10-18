import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/sr_format.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../agency/data/repository/agency_repository.dart';
import '../../../auth/domain/entities/role.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../campaign/data/dto/campaign_dto.dart';
import '../../../campaign/data/repository/campaign_repository.dart';
import '../../../inquiry/data/repository/inquiry_repository.dart';
import '../../../inquiry/domain/entities/inquiry.dart';
import '../../data/models/dashboard_models.dart';
import '../../data/repository/analytics_repository.dart';
import '../blocs/analytics_bloc.dart';
import 'base_dashboard.dart';
import 'dashboard_charts.dart';
import 'dashboard_rows.dart';

/// Podaci table brenda/agencije; `null` znači da poziv nije uspeo.
class _ClientData {
  final List<Inquiry>? inquiries;
  final List<CampaignDto>? campaigns;
  final int? brandCount;

  const _ClientData({this.inquiries, this.campaigns, this.brandCount});
}

const _notLoaded = 'Podaci nisu učitani';
const _loading = 'Učitavanje…';

/// Kontrolna tabla brenda i agencije: brojke, upiti po statusu i nedavni
/// upiti; agencija dodatno vidi upite po brendu.
class ClientDashboard extends StatefulWidget {
  final User user;
  final bool agency;

  const ClientDashboard({super.key, required this.user, required this.agency});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  late Future<_ClientData> _data;
  late Future<Map<String, double>> _acceptedTotals;

  bool get _agency => widget.agency;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final role = _agency ? Role.agency : Role.brand;
    final inquiries = context
        .read<InquiryRepository>()
        .getInquiries(role)
        .then<List<Inquiry>?>((v) => v)
        .catchError((Object _) => null);
    final campaigns = context
        .read<CampaignRepository>()
        .getCampaigns()
        .then<List<CampaignDto>?>((v) => v)
        .catchError((Object _) => null);
    final brands = _agency
        ? context
            .read<AgencyRepository>()
            .getBrands()
            .then<int?>((v) => v.length)
            .catchError((Object _) => null)
        : Future<int?>.value(null);

    _data = Future.wait<Object?>([inquiries, campaigns, brands])
        .then((r) => _ClientData(
              inquiries: r[0] as List<Inquiry>?,
              campaigns: r[1] as List<CampaignDto>?,
              brandCount: r[2] as int?,
            ));

    // Vrednost prihvaćenih ponuda, po valutama.
    final analytics = context.read<AnalyticsRepository>();
    _acceptedTotals = inquiries.then<Map<String, double>>((list) async {
      final ids = (list ?? const <Inquiry>[])
          .where((i) => isAcceptedInquiry(i.status))
          .map((i) => i.id)
          .toList();
      if (ids.isEmpty) return <String, double>{};
      return analytics.getAcceptedOfferTotals(agency: _agency, inquiryIds: ids);
    }).catchError((Object _) => <String, double>{});
  }

  Future<void> _refresh() async {
    setState(_load);
    context
        .read<AnalyticsBloc>()
        .add(_agency ? LoadAgencyAnalytics() : LoadBrandAnalytics());
    await Future.wait<Object?>([_data, _acceptedTotals]);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, analyticsState) {
        final analytics = analyticsState is AnalyticsLoaded
            ? DashboardAnalytics.fromMap(analyticsState.data)
            : null;
        final analyticsLoading = analyticsState is! AnalyticsLoaded;

        return FutureBuilder<_ClientData>(
          future: _data,
          builder: (context, snapshot) {
            final loading = snapshot.connectionState != ConnectionState.done;
            final data = snapshot.data ?? const _ClientData();

            return DashboardScaffold(
              subtitle: dashboardSubtitle(widget.user),
              actions: [
                FilledButton(
                  onPressed: () => context.go('/app/discover'),
                  child: const Text('Istraži površine'),
                ),
                OutlinedButton(
                  onPressed: () => context.push('/app/inquiries/create'),
                  child: const Text('Generalni upit'),
                ),
              ],
              onRefresh: _refresh,
              children: [
                _kpis(context, data, loading, analytics),
                DashboardColumns(
                  left: _statusCard(data, loading, analytics, analyticsLoading),
                  right: _recentCard(context, data, loading),
                ),
                if (_agency)
                  _brandsCard(context, data, analytics, analyticsLoading),
              ],
            );
          },
        );
      },
    );
  }

  // ── Brojke ──────────────────────────────────────────────────────────────

  Widget _kpis(BuildContext context, _ClientData data, bool loading,
      DashboardAnalytics? analytics) {
    if (loading) {
      return StatStrip(items: [
        const StatItem('Aktivni upiti', '—', note: _loading),
        const StatItem('Ponude za odluku', '—', note: _loading),
        const StatItem('Kampanje', '—', note: _loading),
        const StatItem('Ukupna vrednost', '—', note: _loading),
        if (_agency) const StatItem('Moji brendovi', '—', note: _loading),
      ]);
    }

    final inquiries = data.inquiries;
    final total = inquiries?.length ?? 0;
    final active = inquiries?.where((i) => isActiveInquiry(i.status)).length;
    final offers =
        inquiries?.where((i) => i.status == InquiryStatus.offerSent).toList();
    final campaigns = data.campaigns;
    final running = campaigns
            ?.where((c) => (c.status ?? '').toUpperCase() == 'RUNNING')
            .length ??
        0;
    final booked = campaigns
            ?.where((c) => (c.status ?? '').toUpperCase() == 'BOOKED')
            .length ??
        0;

    return FutureBuilder<Map<String, double>>(
      future: _acceptedTotals,
      builder: (context, totals) => StatStrip(items: [
        StatItem(
          'Aktivni upiti',
          active?.toString() ?? '—',
          note: inquiries == null
              ? _notLoaded
              : (total == 0 ? null : 'od ukupno $total'),
          onTap: () => context.push('/app/inquiries'),
        ),
        StatItem(
          'Ponude za odluku',
          offers?.length.toString() ?? '—',
          note: offers == null ? _notLoaded : null,
          onTap: () => offers != null && offers.length == 1
              ? context.push('/app/inquiries/${offers.first.id}/offer')
              : context.push('/app/inquiries'),
        ),
        StatItem(
          'Kampanje',
          campaigns?.length.toString() ?? '—',
          note: campaigns == null
              ? _notLoaded
              : running > 0
                  ? '$running u toku'
                  : booked > 0
                      ? SrFormat.count(
                          booked, 'zakupljena', 'zakupljene', 'zakupljenih')
                      : null,
          onTap: () => context.push('/app/campaigns'),
        ),
        _valueItem(context, totals, inquiries, analytics),
        if (_agency)
          StatItem(
            'Moji brendovi',
            data.brandCount?.toString() ?? '—',
            note: data.brandCount == null ? _notLoaded : null,
            onTap: () => context.push('/app/agency/brands'),
          ),
      ]),
    );
  }

  /// Vrednost prihvaćenih ponuda po valutama; bez njih, budžet upita.
  StatItem _valueItem(
      BuildContext context,
      AsyncSnapshot<Map<String, double>> snapshot,
      List<Inquiry>? inquiries,
      DashboardAnalytics? analytics) {
    const label = 'Ukupna vrednost';
    if (snapshot.connectionState != ConnectionState.done) {
      return const StatItem(label, '—', note: _loading);
    }
    final totals = (snapshot.data ?? const {}).entries.toList();
    if (totals.isEmpty) {
      final budget = analytics?.totalSpend;
      return StatItem(
        label,
        SrFormat.money(0, 'EUR'),
        note: budget != null && budget > 0
            ? 'budžet upita ${SrFormat.money(budget, 'EUR', decimals: false)}'
            : null,
      );
    }
    final accepted =
        inquiries?.where((i) => isAcceptedInquiry(i.status)).length ?? 0;
    final others = totals
        .skip(1)
        .map((e) => SrFormat.money(e.value, e.key, decimals: false))
        .join(', ');
    return StatItem(
      label,
      SrFormat.money(totals.first.value, totals.first.key, decimals: false),
      note: others.isNotEmpty
          ? '+ $others'
          : accepted > 0
              ? SrFormat.count(accepted, 'prihvaćena ponuda',
                  'prihvaćene ponude', 'prihvaćenih ponuda')
              : null,
      onTap: () => context.push('/app/campaigns'),
    );
  }

  // ── Sekcije ─────────────────────────────────────────────────────────────

  Widget _statusCard(_ClientData data, bool loading,
      DashboardAnalytics? analytics, bool analyticsLoading) {
    // Analitika servera, a ako nije stigla, isti zbir iz liste upita.
    Map<InquiryStatus, int>? counts;
    if (analytics != null &&
        !analytics.failed &&
        analytics.inquiriesByStatus.isNotEmpty) {
      counts = analytics.inquiriesByStatus;
    } else if (data.inquiries != null) {
      counts = statusCountsOf(data.inquiries!);
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
      title: 'Upiti po statusu',
      subtitle:
          total > 0 ? SrFormat.count(total, 'upit', 'upita', 'upita') : null,
      child: child,
    );
  }

  Widget _recentCard(BuildContext context, _ClientData data, bool loading) {
    Widget child;
    var rows = false;
    final inquiries = data.inquiries;
    if (loading) {
      child = const SectionSkeleton(rows: 4);
    } else if (inquiries == null) {
      child = SectionFailure(onRetry: _refresh);
    } else if (inquiries.isEmpty) {
      child = const EmptyState(
        compact: true,
        icon: Icons.forward_to_inbox_outlined,
        title: 'Još nema upita',
      );
    } else {
      final recent = [...inquiries]..sort(_newestFirst);
      final shown = recent.take(5).toList();
      rows = true;
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < shown.length; i++) ...[
            if (i > 0) const RowDivider(),
            InquiryActivityRow(
              inquiry: shown[i],
              onTap: () => context.push('/app/inquiries/${shown[i].id}'),
            ),
          ],
        ],
      );
    }

    return ListSectionCard(
      title: 'Nedavni upiti',
      subtitle: inquiries != null && inquiries.length > 5
          ? '5 od ${inquiries.length}'
          : null,
      rows: rows,
      trailing: SectionLink(
          label: 'Moji upiti', onTap: () => context.push('/app/inquiries')),
      child: child,
    );
  }

  Widget _brandsCard(BuildContext context, _ClientData data,
      DashboardAnalytics? analytics, bool analyticsLoading) {
    Widget child;
    if (analyticsLoading) {
      child = const SectionSkeleton(rows: 3);
    } else if (analytics == null || analytics.failed) {
      child = SectionFailure(onRetry: _refresh);
    } else {
      final entries = analytics.inquiriesPerBrand.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      child = RankedBars(
        entries: entries,
        unitLabel: (n) => SrFormat.count(n, 'upit', 'upita', 'upita'),
      );
    }
    final brands = data.brandCount;
    return SectionCard(
      title: 'Upiti po brendu',
      subtitle: brands == null
          ? null
          : SrFormat.count(brands, 'brend', 'brenda', 'brendova'),
      trailing: SectionLink(
          label: 'Moji brendovi',
          onTap: () => context.push('/app/agency/brands')),
      child: child,
    );
  }

  static int _newestFirst(Inquiry a, Inquiry b) {
    final da = a.createdAt == null ? null : DateTime.tryParse(a.createdAt!);
    final db = b.createdAt == null ? null : DateTime.tryParse(b.createdAt!);
    if (da != null && db != null) {
      final c = db.compareTo(da);
      if (c != 0) return c;
    }
    return b.id.compareTo(a.id);
  }
}
