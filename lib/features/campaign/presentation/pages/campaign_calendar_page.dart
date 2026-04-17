import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/dto/campaign_dto.dart';
import '../../data/repository/campaign_repository.dart';
import '../blocs/campaign_bloc.dart';

/// Calendar-view alternative to the list page.
/// Uses table_calendar with color-coded event markers by CampaignStatus.
class CampaignCalendarPage extends StatelessWidget {
  const CampaignCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CampaignBloc(context.read<CampaignRepository>())
        ..add(LoadCampaigns()),
      child: const _CampaignCalendarView(),
    );
  }
}

class _CampaignCalendarView extends StatefulWidget {
  const _CampaignCalendarView();

  @override
  State<_CampaignCalendarView> createState() => _CampaignCalendarViewState();
}

class _CampaignCalendarViewState extends State<_CampaignCalendarView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _format = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.campaignCalendarTitle),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: AppLocalizations.of(context)!.listView,
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: BlocBuilder<CampaignBloc, CampaignState>(
        builder: (context, state) {
          if (state is CampaignLoading || state is CampaignInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CampaignError) {
            return Center(child: Text(state.message));
          }
          if (state is CampaignsLoaded) {
            return _buildCalendarView(context, state.campaigns);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCalendarView(BuildContext context, List<CampaignDto> campaigns) {
    final eventsByDay = _buildEventsMap(campaigns);
    final selectedDayEvents = _selectedDay != null
        ? (eventsByDay[_normalize(_selectedDay!)] ?? [])
        : <CampaignDto>[];

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(AppSpacing.md),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: TableCalendar<CampaignDto>(
              focusedDay: _focusedDay,
                      firstDay: DateTime.utc(DateTime.now().year - 3, 1, 1),
              lastDay: DateTime.utc(DateTime.now().year + 5, 12, 31),
              selectedDayPredicate: (day) =>
                  _selectedDay != null && isSameDay(_selectedDay, day),
              calendarFormat: _format,
              onFormatChanged: (f) => setState(() => _format = f),
              eventLoader: (day) => eventsByDay[_normalize(day)] ?? [],
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return null;
                  return Positioned(
                    bottom: 4,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: events.take(4).map((e) {
                        return Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _statusColor(e.status),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
              ),
            ),
          ),
        ),
        _buildLegend(),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: _selectedDay == null
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)!.selectDayHint,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                )
              : _buildDayList(selectedDayEvents),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    final l10n = AppLocalizations.of(context)!;
    final entries = [
      ('DRAFT', l10n.statusDraft),
      ('IN_NEGOTIATION', l10n.statusInNegotiation),
      ('BOOKED', l10n.statusBooked),
      ('RUNNING', l10n.statusRunning),
      ('FINISHED', l10n.statusFinished),
      ('CANCELLED', l10n.statusCancelled),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _statusColor(e.$1),
                  ),
                ),
                const SizedBox(width: 4),
                Text(e.$2, style: AppTypography.caption),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDayList(List<CampaignDto> events) {
    if (events.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noCampaignsForDay,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (ctx, i) {
        final c = events[i];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: _statusColor(c.status),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name ?? 'Kampanja #${c.id}',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (c.startDate != null && c.endDate != null)
                      Text(
                        '${_fmt(c.startDate!)} — ${_fmt(c.endDate!)}',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.mutedForeground),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => context.push('/app/campaigns/${c.id}'),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<DateTime, List<CampaignDto>> _buildEventsMap(List<CampaignDto> campaigns) {
    final map = <DateTime, List<CampaignDto>>{};
    for (final c in campaigns) {
      if (c.startDate == null || c.endDate == null) continue;
      final start = DateTime.tryParse(c.startDate!);
      final end = DateTime.tryParse(c.endDate!);
      if (start == null || end == null) continue;
      for (var d = start;
          !d.isAfter(end);
          d = d.add(const Duration(days: 1))) {
        final key = _normalize(d);
        map.putIfAbsent(key, () => []).add(c);
      }
    }
    return map;
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  String _fmt(String iso) {
    try {
      return DateFormat('dd.MM.yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  Color _statusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'DRAFT':
        return AppColors.mutedForeground;
      case 'IN_NEGOTIATION':
        return AppColors.warning;
      case 'BOOKED':
        return AppColors.info;
      case 'RUNNING':
        return AppColors.success;
      case 'FINISHED':
        return AppColors.foreground;
      case 'CANCELLED':
        return AppColors.destructive;
      default:
        return AppColors.mutedForeground;
    }
  }
}
