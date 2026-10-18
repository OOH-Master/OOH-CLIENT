import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/sr_format.dart';
import '../../../../core/utils/sr_labels.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../auth/domain/entities/role.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../inquiry/data/repository/inquiry_repository.dart';
import '../../../inquiry/domain/entities/inquiry.dart';
import '../../data/models/dashboard_models.dart';
import '../../data/repository/analytics_repository.dart';
import '../blocs/analytics_bloc.dart';
import 'base_dashboard.dart';
import 'dashboard_charts.dart';
import 'dashboard_rows.dart';

/// Kontrolna tabla stručnjaka za lokacije (interni administrator).
class AdminDashboard extends StatelessWidget {
  final User user;

  const AdminDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnalyticsBloc(context.read<AnalyticsRepository>())
        ..add(LoadAdminAnalytics()),
      child: _AdminBody(user: user),
    );
  }
}

class _AdminBody extends StatefulWidget {
  final User user;

  const _AdminBody({required this.user});

  @override
  State<_AdminBody> createState() => _AdminBodyState();
}

class _AdminBodyState extends State<_AdminBody> {
  late Future<List<Inquiry>?> _inquiries;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _inquiries = context
        .read<InquiryRepository>()
        .getInquiries(Role.admin)
        .then<List<Inquiry>?>((v) => v)
        .catchError((Object _) => null);
  }

  Future<void> _refresh() async {
    setState(_load);
    context.read<AnalyticsBloc>().add(LoadAdminAnalytics());
    await _inquiries;
  }

  /// Upiti koji čekaju stručnjaka: podneti, i brifovi u obradi bez dodeljenih površina.
  static bool _waiting(Inquiry i) =>
      i.status == InquiryStatus.submitted ||
      (i.status == InquiryStatus.inProgress && i.items.isEmpty);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, analyticsState) {
        final loaded = analyticsState is AnalyticsLoaded
            ? DashboardAnalytics.fromMap(analyticsState.data)
            : null;
        final analytics = loaded == null || loaded.failed ? null : loaded;
        final analyticsLoading = analyticsState is! AnalyticsLoaded;

        return FutureBuilder<List<Inquiry>?>(
          future: _inquiries,
          builder: (context, snapshot) {
            final loading = snapshot.connectionState != ConnectionState.done;
            final inquiries = snapshot.data;
            return DashboardScaffold(
              subtitle: dashboardSubtitle(widget.user),
              actions: [
                FilledButton(
                  onPressed: () => context.push('/app/admin/inquiries'),
                  child: const Text('Upravljanje upitima'),
                ),
              ],
              onRefresh: _refresh,
              children: [
                _kpis(context, analytics, analyticsLoading, inquiries),
                DashboardColumns(
                  left: _pipelineCard(
                      context, analytics, analyticsLoading, inquiries, loading),
                  right: _waitingCard(context, inquiries, loading),
                ),
                DashboardColumns(
                  left: _monthlyCard(analytics, analyticsLoading, inquiries),
                  right: _citiesCard(analytics, analyticsLoading),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ── Brojke ──────────────────────────────────────────────────────────────

  Widget _kpis(BuildContext context, DashboardAnalytics? analytics,
      bool analyticsLoading, List<Inquiry>? inquiries) {
    const loadingNote = 'Učitavanje…';
    const notLoaded = 'Podaci nisu učitani';
    if (analyticsLoading) {
      return const StatStrip(items: [
        StatItem('Ukupno upita', '—', note: loadingNote),
        StatItem('Površine', '—', note: loadingNote),
        StatItem('Korisnici', '—', note: loadingNote),
        StatItem('Kampanje', '—', note: loadingNote),
      ]);
    }

    final byStatus = analytics?.inquiriesByStatus ??
        (inquiries == null ? null : statusCountsOf(inquiries));
    final totalInquiries =
        analytics != null ? analytics.totalInquiries : inquiries?.length;
    final conversion = analytics?.conversionRate;
    final waiting = inquiries?.where(_waiting).length;

    final cities = analytics?.inventoryByCity.length ?? 0;
    final users = analytics?.usersByRole ?? const {};
    int role(String key) => users[key] ?? 0;
    final campaigns = byStatus == null
        ? null
        : (byStatus[InquiryStatus.acceptedByClient] ?? 0) +
            (byStatus[InquiryStatus.realized] ?? 0);

    return StatStrip(items: [
      StatItem(
        'Ukupno upita',
        totalInquiries?.toString() ?? '—',
        note: conversion != null
            ? 'konverzija ${conversion.round()} %'
            : waiting != null
                ? SrFormat.count(
                    waiting, 'čeka akciju', 'čekaju akciju', 'čeka akciju')
                : notLoaded,
        onTap: () => context.push('/app/admin/inquiries'),
      ),
      StatItem(
        'Površine',
        analytics?.totalInventory?.toString() ?? '—',
        note: cities > 0
            ? 'u ${SrFormat.count(cities, 'gradu', 'grada', 'gradova')}'
            : null,
      ),
      StatItem(
        'Korisnici',
        analytics == null ? '—' : analytics.totalUsers.toString(),
        note: analytics == null
            ? notLoaded
            : [
                SrFormat.count(role('BRAND'), 'brend', 'brenda', 'brendova'),
                SrFormat.count(
                    role('AGENCY'), 'agencija', 'agencije', 'agencija'),
                SrFormat.count(
                    role('MEDIA_OWNER'), 'vlasnik', 'vlasnika', 'vlasnika'),
              ].join(', '),
        onTap: () => context.push('/app/admin/users'),
      ),
      StatItem('Kampanje', campaigns?.toString() ?? '—'),
    ]);
  }

  // ── Sekcije ─────────────────────────────────────────────────────────────

  Widget _pipelineCard(BuildContext context, DashboardAnalytics? analytics,
      bool analyticsLoading, List<Inquiry>? inquiries, bool loading) {
    Map<InquiryStatus, int>? counts;
    if (analytics != null && analytics.inquiriesByStatus.isNotEmpty) {
      counts = analytics.inquiriesByStatus;
    } else if (inquiries != null) {
      counts = statusCountsOf(inquiries);
    }

    Widget child;
    if (counts != null) {
      child = PipelineBars(counts: counts);
    } else if (analyticsLoading || loading) {
      child = const SectionSkeleton(rows: 4);
    } else {
      child = SectionFailure(onRetry: _refresh);
    }

    final conversion = analytics?.conversionRate;
    return SectionCard(
      title: 'Tok upita',
      subtitle:
          conversion != null ? 'konverzija ${conversion.round()} %' : null,
      trailing: SectionLink(
          label: 'Svi upiti',
          onTap: () => context.push('/app/admin/inquiries')),
      child: child,
    );
  }

  Widget _waitingCard(
      BuildContext context, List<Inquiry>? inquiries, bool loading) {
    Widget child;
    var rows = false;
    var waiting = <Inquiry>[];
    if (loading) {
      child = const SectionSkeleton(rows: 4);
    } else if (inquiries == null) {
      child = SectionFailure(onRetry: _refresh);
    } else {
      // Najstariji prvi: najduže čekaju.
      waiting = inquiries.where(_waiting).toList()
        ..sort((a, b) {
          final da =
              a.createdAt == null ? null : DateTime.tryParse(a.createdAt!);
          final db =
              b.createdAt == null ? null : DateTime.tryParse(b.createdAt!);
          if (da != null && db != null) return da.compareTo(db);
          return a.id.compareTo(b.id);
        });
      if (waiting.isEmpty) {
        child = const EmptyState(
          compact: true,
          icon: Icons.task_alt_rounded,
          title: 'Nema upita na čekanju',
        );
      } else {
        final shown = waiting.take(5).toList();
        rows = true;
        child = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < shown.length; i++) ...[
              if (i > 0) const RowDivider(),
              InquiryActivityRow(
                inquiry: shown[i],
                adminView: true,
                onTap: () => context.push('/app/admin/inquiries'),
              ),
            ],
            if (waiting.length > shown.length) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: SectionLink(
                  label:
                      'Još ${waiting.length - shown.length} u upravljanju upitima',
                  onTap: () => context.push('/app/admin/inquiries'),
                ),
              ),
            ],
          ],
        );
      }
    }

    return ListSectionCard(
      title: 'Upiti koji čekaju akciju',
      subtitle: waiting.isEmpty
          ? null
          : SrFormat.count(waiting.length, 'upit', 'upita', 'upita'),
      rows: rows,
      trailing: SectionLink(
          label: 'Upravljanje',
          onTap: () => context.push('/app/admin/inquiries')),
      child: child,
    );
  }

  Widget _monthlyCard(DashboardAnalytics? analytics, bool analyticsLoading,
      List<Inquiry>? inquiries) {
    List<MonthCount>? months;
    if (analytics != null && analytics.monthlyTrend.isNotEmpty) {
      months = analytics.monthlyTrend;
    } else if (inquiries != null) {
      months = monthlyCountsOf(inquiries);
    } else if (analytics != null) {
      months = const [];
    }

    Widget child;
    if (months != null) {
      child = MonthlyBars(data: months);
    } else if (analyticsLoading) {
      child = const SizedBox(
          height: 236, child: Center(child: CircularProgressIndicator()));
    } else {
      child = SectionFailure(onRetry: _refresh);
    }
    final total = months?.fold<int>(0, (a, m) => a + m.count) ?? 0;
    return SectionCard(
      title: 'Upiti po mesecima',
      subtitle: months == null || months.isEmpty
          ? null
          : '${SrFormat.count(total, 'upit', 'upita', 'upita')} u poslednjih ${SrFormat.count(months.length, 'mesec', 'meseca', 'meseci')}',
      child: child,
    );
  }

  Widget _citiesCard(DashboardAnalytics? analytics, bool analyticsLoading) {
    Widget child;
    if (analytics != null) {
      final entries = analytics.inventoryByCity.entries
          .map((e) => MapEntry(SrLabels.city(e.key), e.value))
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      child = RankedBars(
        entries: entries,
        maxItems: 8,
        unitLabel: (n) => SrFormat.count(n, 'površina', 'površine', 'površina'),
      );
    } else if (analyticsLoading) {
      child = const SectionSkeleton(rows: 4);
    } else {
      child = SectionFailure(onRetry: _refresh);
    }
    final cities = analytics?.inventoryByCity.length ?? 0;
    return SectionCard(
      title: 'Površine po gradovima',
      subtitle: cities > 0
          ? SrFormat.count(cities, 'grad', 'grada', 'gradova')
          : null,
      child: child,
    );
  }
}
