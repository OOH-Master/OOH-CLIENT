import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_format.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../inquiry/domain/entities/inquiry.dart';
import '../../../inquiry/presentation/widgets/inquiry_status_badge.dart';
import '../../data/models/dashboard_models.dart';

/// Oznake osa: IBM Plex Sans 12, prigušeno.
TextStyle get _axisStyle => AppTypography.labelSmall.copyWith(
      fontSize: 12,
      color: AppColors.subtle,
      fontWeight: FontWeight.w500,
    );

String _upita(int n) => SrFormat.count(n, 'upit', 'upita', 'upita');

/// Prazno stanje grafikona.
class ChartEmpty extends StatelessWidget {
  final String title;
  final IconData icon;

  const ChartEmpty({
    super.key,
    this.title = 'Još nema podataka',
    this.icon = Icons.insights_rounded,
  });

  @override
  Widget build(BuildContext context) =>
      EmptyState(compact: true, icon: icon, title: title);
}

/// Jedan vodoravni stubić: naziv, tanka traka i broj (statusi, gradovi,
/// brendovi).
class BarRow extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Color color;
  final double labelWidth;
  final String? tooltip;
  final bool muted;

  const BarRow({
    super.key,
    required this.label,
    required this.value,
    required this.max,
    required this.color,
    this.labelWidth = 150,
    this.tooltip,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final factor = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0).toDouble();
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelMedium.copyWith(
                color: muted ? AppColors.subtle : AppColors.text2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSunken,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  if (factor > 0)
                    FractionallySizedBox(
                      widthFactor: factor < 0.03 ? 0.03 : factor,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 34,
            child: Text(
              '$value',
              textAlign: TextAlign.right,
              style: AppTypography.money.copyWith(
                fontSize: 14,
                color: muted ? AppColors.subtle : AppColors.foreground,
              ),
            ),
          ),
        ],
      ),
    );
    if (tooltip == null) return row;
    return Tooltip(
        message: tooltip!,
        waitDuration: const Duration(milliseconds: 300),
        child: row);
  }
}

/// Upiti po statusu: sve faze redom, od podnetog do zatvorenog, sa brojem
/// upita i trakom u boji faze (tok upita, upiti po statusu).
class PipelineBars extends StatelessWidget {
  final Map<InquiryStatus, int> counts;

  const PipelineBars({super.key, required this.counts});

  @override
  Widget build(BuildContext context) {
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) return const ChartEmpty();
    final max = counts.values.fold<int>(0, (a, b) => b > a ? b : a);
    return LayoutBuilder(builder: (context, constraints) {
      final labelWidth = constraints.maxWidth < 420 ? 118.0 : 150.0;
      return Column(
        children: [
          for (final s in InquiryStatus.values)
            BarRow(
              label: InquiryStatusBadge.labelFor(s),
              value: counts[s] ?? 0,
              max: max,
              color: InquiryStatusBadge.toneFor(s).solid,
              labelWidth: labelWidth,
              muted: (counts[s] ?? 0) == 0,
              tooltip:
                  '${InquiryStatusBadge.labelFor(s)}: ${_upita(counts[s] ?? 0)}',
            ),
        ],
      );
    });
  }
}

/// Rang lista (gradovi, brendovi, statusi zahteva) kao vodoravni stubići.
class RankedBars extends StatelessWidget {
  final List<MapEntry<String, int>> entries;
  final Color? color;

  /// Boja po nazivu stavke (npr. ton statusa zahteva); inače [color].
  final Color Function(String label)? colorOf;
  final int maxItems;
  final String Function(int n) unitLabel;

  const RankedBars({
    super.key,
    required this.entries,
    required this.unitLabel,
    this.color,
    this.colorOf,
    this.maxItems = 7,
  });

  @override
  Widget build(BuildContext context) {
    final visible = entries.where((e) => e.value > 0).toList();
    if (visible.isEmpty) return const ChartEmpty();
    final shown = visible.take(maxItems).toList();
    final rest = visible.length - shown.length;
    final max = shown.fold<int>(0, (a, e) => e.value > a ? e.value : a);
    return LayoutBuilder(builder: (context, constraints) {
      final labelWidth = constraints.maxWidth < 380 ? 104.0 : 132.0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < shown.length; i++)
            BarRow(
              label: shown[i].key,
              value: shown[i].value,
              max: max,
              labelWidth: labelWidth,
              color:
                  colorOf?.call(shown[i].key) ?? (color ?? AppColors.primary),
              tooltip: '${shown[i].key}: ${unitLabel(shown[i].value)}',
            ),
          if (rest > 0) ...[
            const SizedBox(height: 6),
            Text(
              rest == 1 ? 'i još 1 stavka' : 'i još $rest stavki',
              style: AppTypography.caption
                  .copyWith(color: AppColors.mutedForeground),
            ),
          ],
        ],
      );
    });
  }
}

/// Upiti po mesecima: zaobljeni indigo stubići, tanka mreža, opis na srpskom.
class MonthlyBars extends StatelessWidget {
  final List<MonthCount> data;

  const MonthlyBars({super.key, required this.data});

  static const _short = [
    'jan',
    'feb',
    'mar',
    'apr',
    'maj',
    'jun',
    'jul',
    'avg',
    'sep',
    'okt',
    'nov',
    'dec',
  ];

  static const _full = [
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

  /// Zaokružen gornji kraj ose i korak mreže (najviše pet linija).
  static (double, double) _scale(int maxValue) {
    if (maxValue <= 4) return (4, 1);
    const steps = [1, 2, 5, 10, 20, 25, 50, 100, 200, 250, 500, 1000];
    var step = steps.last.toDouble();
    for (final s in steps) {
      if (maxValue / s <= 5) {
        step = s.toDouble();
        break;
      }
    }
    final top = (maxValue / step).ceil() * step;
    return (top, step);
  }

  @override
  Widget build(BuildContext context) {
    final total = data.fold<int>(0, (a, m) => a + m.count);
    if (data.isEmpty || total == 0) return const ChartEmpty();
    final maxValue = data.fold<int>(0, (a, m) => m.count > a ? m.count : a);
    final (top, step) = _scale(maxValue);

    return LayoutBuilder(builder: (context, constraints) {
      final slot = (constraints.maxWidth - 40) / data.length;
      final barWidth = (slot * 0.5).clamp(8.0, 26.0).toDouble();
      final everyOther = slot < 34;

      return SizedBox(
        height: 236,
        child: BarChart(
          BarChartData(
            maxY: top,
            minY: 0,
            alignment: BarChartAlignment.spaceAround,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => AppColors.ink,
                tooltipRoundedRadius: 8,
                tooltipPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                tooltipMargin: 8,
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final m = data[group.x];
                  return BarTooltipItem(
                    '${_full[m.month.month - 1]} ${m.month.year}.\n',
                    AppTypography.caption
                        .copyWith(color: AppColors.inkMuted, height: 1.5),
                    children: [
                      TextSpan(
                        text: _upita(m.count),
                        style: AppTypography.labelMedium.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: step,
                  getTitlesWidget: (value, meta) {
                    if (value % step != 0) return const SizedBox.shrink();
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 8,
                      child: Text(value.toInt().toString(), style: _axisStyle),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= data.length) {
                      return const SizedBox.shrink();
                    }
                    final isLast = i == data.length - 1;
                    if (everyOther && (data.length - 1 - i).isOdd && !isLast) {
                      return const SizedBox.shrink();
                    }
                    final m = data[i].month;
                    final label = m.month == 1 && i > 0
                        ? '${_short[0]} ${m.year % 100}.'
                        : _short[m.month - 1];
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 8,
                      child: Text(label, style: _axisStyle),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: step,
              getDrawingHorizontalLine: (_) =>
                  const FlLine(color: AppColors.borderSoft, strokeWidth: 1),
            ),
            borderData: FlBorderData(
              show: true,
              border: const Border(
                  bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            barGroups: [
              for (var i = 0; i < data.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: data[i].count.toDouble(),
                      width: barWidth,
                      color: i == data.length - 1
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.78),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(6)),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    });
  }
}
