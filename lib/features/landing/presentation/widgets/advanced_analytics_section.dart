import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ui/ui.dart';
import 'landing_shared.dart';

/// Analitika: naslov i tri prednosti, uz prikaz kontrolne table.
class AdvancedAnalyticsSection extends StatelessWidget {
  const AdvancedAnalyticsSection({super.key});

  static const List<(String, String)> _features = [
    (
      'Pregled u realnom vremenu',
      'Status svakog upita i ponude osvežava se čim se nešto promeni.',
    ),
    (
      'Merenje publike',
      'Procena broja prikaza po površini pomaže da uporedite lokacije.',
    ),
    (
      'Praćenje povrata ulaganja',
      'Vrednost prihvaćenih ponuda po valutama, za svaku kampanju.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    final content = _content(context);
    const preview = _DashboardPreview();

    return LandingSection(
      key: LandingKeys.analytics,
      color: AppColors.surface,
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(child: preview),
                const SizedBox(width: 64),
                Expanded(child: content),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [content, const SizedBox(height: 40), preview],
            ),
    );
  }

  Widget _content(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(title: 'Analitika koja meri ono što je važno'),
        const SizedBox(height: 28),
        for (final f in _features)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.$1, style: AppTypography.labelLarge),
                const SizedBox(height: 3),
                Text(
                  f.$2,
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.mutedForeground),
                ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: () => context.go('/auth/login'),
          child: const Text('Pogledaj analitiku'),
        ),
      ],
    );
  }
}

/// Umanjen prikaz kontrolne table na tamnom panelu: tri brojke i stubići po
/// mesecima.
class _DashboardPreview extends StatelessWidget {
  const _DashboardPreview();

  static const _bars = [5, 8, 6, 11, 9, 14, 12, 17, 15, 21, 19, 24];
  static const _months = [
    'nov',
    'dec',
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
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const BrandMark(size: 26, compact: true),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Kontrolna tabla',
                    style:
                        AppTypography.labelLarge.copyWith(color: Colors.white)),
              ),
              Text('poslednjih 12 meseci',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.inkMuted)),
            ],
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(child: _MiniKpi(label: 'Aktivni upiti', value: '12')),
              SizedBox(width: 10),
              Expanded(child: _MiniKpi(label: 'Ponude za odluku', value: '3')),
              SizedBox(width: 10),
              Expanded(
                  child: _MiniKpi(label: 'Ukupna vrednost', value: '18.400 €')),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.inkLine),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Upiti po mesecima',
                    style: AppTypography.labelMedium
                        .copyWith(color: AppColors.inkText)),
                const SizedBox(height: 14),
                SizedBox(
                  height: 120,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < _bars.length; i++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: FractionallySizedBox(
                              heightFactor: _bars[i] / 24,
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: i == _bars.length - 1
                                      ? AppColors.primaryTint
                                      : AppColors.primary
                                          .withValues(alpha: 0.75),
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4)),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (var i = 0; i < _months.length; i++)
                      Expanded(
                        child: Text(
                          i.isEven ? _months[i] : '',
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                              color: AppColors.inkMuted, fontSize: 11),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniKpi extends StatelessWidget {
  final String label;
  final String value;

  const _MiniKpi({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inkLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(color: AppColors.inkMuted)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: AppTypography.money
                    .copyWith(fontSize: 20, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
