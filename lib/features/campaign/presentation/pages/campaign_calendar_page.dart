import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

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

/// Kalendarski prikaz kampanja: tačke u bojama statusa i spisak za izabrani dan.
class CampaignCalendarPage extends StatelessWidget {
  const CampaignCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CampaignBloc(context.read<CampaignRepository>())
        ..add(const LoadCampaigns()),
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
  static const _months = [
    'januar',
    'februar',
    'mart',
    'april',
    'maj',
    'jun',
    'jul',
    'avgust',
    'septembar',
    'oktobar',
    'novembar',
    'decembar',
  ];
  static const _weekdays = ['Pon', 'Uto', 'Sre', 'Čet', 'Pet', 'Sub', 'Ned'];
  static const _weekdaysLong = [
    'Ponedeljak',
    'Utorak',
    'Sreda',
    'Četvrtak',
    'Petak',
    'Subota',
    'Nedelja',
  ];

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  CalendarFormat _format = CalendarFormat.month;

  void _backToList() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/app/campaigns');
    }
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
              title: Text(l10n.campaignCalendarTitle),
              actions: [
                IconButton(
                  icon: const Icon(Icons.view_list_rounded),
                  tooltip: l10n.listView,
                  onPressed: _backToList,
                ),
              ],
            ),
      body: BlocBuilder<CampaignBloc, CampaignState>(
        builder: (context, state) {
          if (state is CampaignError) {
            return EmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Kalendar trenutno nije dostupan',
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

          return LayoutBuilder(
            builder: (context, constraints) {
              final side = wide ? 32.0 : 16.0;
              final gutter = math.max(side, (constraints.maxWidth - 1240) / 2);
              final width = constraints.maxWidth - 2 * gutter;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(gutter, wide ? 0 : 16, gutter, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (wide)
                      PageHeader(
                        title: l10n.campaignCalendarTitle,
                        showBack: true,
                        padding: const EdgeInsets.only(top: 28, bottom: 22),
                        actions: [
                          OutlinedButton.icon(
                            onPressed: _backToList,
                            icon: const Icon(Icons.view_list_rounded, size: 18),
                            label: Text(l10n.listView),
                          ),
                        ],
                      ),
                    _buildCalendarView(state.campaigns, width),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCalendarView(List<CampaignDto> campaigns, double width) {
    final eventsByDay = _buildEventsMap(campaigns);
    final selectedDayEvents = _selectedDay != null
        ? (eventsByDay[_normalize(_selectedDay!)] ?? <CampaignDto>[])
        : <CampaignDto>[];

    final calendar = SectionCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TableCalendar<CampaignDto>(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(DateTime.now().year - 3, 1, 1),
            lastDay: DateTime.utc(DateTime.now().year + 5, 12, 31),
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) =>
                _selectedDay != null && isSameDay(_selectedDay, day),
            calendarFormat: _format,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Mesec',
              CalendarFormat.twoWeeks: '2 nedelje',
              CalendarFormat.week: 'Nedelja',
            },
            onFormatChanged: (f) => setState(() => _format = f),
            onPageChanged: (focused) => _focusedDay = focused,
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
                  bottom: 5,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: events.take(4).map((e) {
                      return Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CampaignStatusBadge.toneFor(e.status).solid,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              dowTextFormatter: (date, locale) => _weekdays[date.weekday - 1],
              weekdayStyle: AppTypography.labelSmall
                  .copyWith(color: AppColors.mutedForeground),
              weekendStyle:
                  AppTypography.labelSmall.copyWith(color: AppColors.subtle),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: AppTypography.bodyMedium,
              weekendTextStyle:
                  AppTypography.bodyMedium.copyWith(color: AppColors.text2),
              todayDecoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              todayTextStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.primaryStrong,
                fontWeight: FontWeight.w600,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: AppTypography.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: true,
              formatButtonShowsNext: false,
              titleTextFormatter: (date, locale) =>
                  '${_capitalize(_months[date.month - 1])} ${date.year}',
              titleTextStyle: AppTypography.h6,
              formatButtonTextStyle:
                  AppTypography.labelMedium.copyWith(color: AppColors.text2),
              formatButtonDecoration: BoxDecoration(
                border: Border.all(color: AppColors.input),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              leftChevronIcon: const Icon(Icons.chevron_left_rounded,
                  color: AppColors.text2),
              rightChevronIcon: const Icon(Icons.chevron_right_rounded,
                  color: AppColors.text2),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          _buildLegend(),
        ],
      ),
    );

    final dayCard = SectionCard(
      title: _selectedDay == null ? 'Izabrani dan' : _dayTitle(_selectedDay!),
      subtitle: (_selectedDay == null || selectedDayEvents.isEmpty)
          ? null
          : SrFormat.count(selectedDayEvents.length, 'kampanja traje',
              'kampanje traju', 'kampanja traje'),
      child: _buildDayList(selectedDayEvents),
    );

    if (width >= 900) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: calendar),
          const SizedBox(width: 20),
          Expanded(flex: 2, child: dayCard),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [calendar, const SizedBox(height: 16), dayCard],
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _dayTitle(DateTime d) =>
      '${_weekdaysLong[d.weekday - 1]}, ${SrFormat.dateShort(d)}';

  Widget _buildLegend() {
    const entries = [
      'DRAFT',
      'IN_NEGOTIATION',
      'BOOKED',
      'RUNNING',
      'FINISHED',
      'CANCELLED',
    ];
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        for (final e in entries)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CampaignStatusBadge.toneFor(e).solid,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                CampaignStatusBadge.labelFor(e),
                style: AppTypography.caption.copyWith(color: AppColors.text2),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDayList(List<CampaignDto> events) {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedDay == null) {
      return EmptyState(
        icon: Icons.touch_app_outlined,
        title: l10n.selectDayHint,
        compact: true,
      );
    }
    if (events.isEmpty) {
      return EmptyState(
        icon: Icons.event_busy_outlined,
        title: l10n.noCampaignsForDay,
        compact: true,
      );
    }
    return Column(
      children: [
        for (var i = 0; i < events.length; i++) ...[
          if (i > 0) const Divider(height: 1, color: AppColors.borderSoft),
          _DayCampaignLine(
            campaign: events[i],
            onTap: () => context.push('/app/campaigns/${events[i].id}'),
          ),
        ],
      ],
    );
  }

  Map<DateTime, List<CampaignDto>> _buildEventsMap(
      List<CampaignDto> campaigns) {
    final map = <DateTime, List<CampaignDto>>{};
    for (final c in campaigns) {
      if (c.startDate == null || c.endDate == null) continue;
      final start = DateTime.tryParse(c.startDate!);
      final end = DateTime.tryParse(c.endDate!);
      if (start == null || end == null) continue;
      for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
        final key = _normalize(d);
        map.putIfAbsent(key, () => []).add(c);
      }
    }
    return map;
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);
}

class _DayCampaignLine extends StatelessWidget {
  final CampaignDto campaign;
  final VoidCallback onTap;

  const _DayCampaignLine({required this.campaign, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = campaign;
    final name = (c.name == null || c.name!.trim().isEmpty)
        ? 'Kampanja #${c.id}'
        : c.name!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelLarge),
                    const SizedBox(height: 2),
                    Text(
                      [
                        SrFormat.period(c.startDate, c.endDate),
                        if (c.budget != null) SrFormat.money(c.budget, 'EUR'),
                      ].join(', '),
                      style: AppTypography.caption
                          .copyWith(color: AppColors.mutedForeground),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CampaignStatusBadge(
                status: CampaignStatus.fromApi(c.status),
                raw: c.status,
                dense: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
