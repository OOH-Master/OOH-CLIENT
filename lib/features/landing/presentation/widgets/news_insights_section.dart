import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ui/ui.dart';
import 'landing_shared.dart';

/// Vesti i uvidi: dva članka sa naslovnom slikom i lista popularnih tema.
class NewsInsightsSection extends StatelessWidget {
  const NewsInsightsSection({super.key});

  static const List<(String, String, String)> _articles = [
    (
      'Spoljno oglašavanje u eri merljivih rezultata: gde se sreću mediji i umetnost',
      '24. novembar',
      LandingAssets.ledSlavija,
    ),
    (
      'Kako voditi kampanju bez zastoja u rascepkanom medijskom prostoru',
      '18. novembar',
      LandingAssets.bilbordBrankov,
    ),
  ];

  static const List<String> _trending = [
    'Kako merenje publike menja spoljno oglašavanje',
    'Održivi materijali u produkciji oglasa',
    'Zašto programatski bilbordi osvajaju gradove',
  ];

  @override
  Widget build(BuildContext context) {
    return LandingSection(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeading(title: 'Vesti i uvidi'),
          const SizedBox(height: 36),
          LayoutBuilder(builder: (context, constraints) {
            final w = constraints.maxWidth;
            const gap = 20.0;
            if (w >= 1000) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final a in _articles) ...[
                    Expanded(
                        flex: 4,
                        child:
                            _ArticleCard(title: a.$1, date: a.$2, asset: a.$3)),
                    const SizedBox(width: gap),
                  ],
                  const Expanded(
                      flex: 3, child: _TrendingCard(items: _trending)),
                ],
              );
            }
            final twoUp = w >= 620;
            final tileWidth = twoUp ? (w - gap) / 2 : w;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final a in _articles)
                      SizedBox(
                        width: tileWidth,
                        child:
                            _ArticleCard(title: a.$1, date: a.$2, asset: a.$3),
                      ),
                  ],
                ),
                const SizedBox(height: gap),
                const _TrendingCard(items: _trending),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatefulWidget {
  final String title;
  final String date;
  final String asset;

  const _ArticleCard(
      {required this.title, required this.date, required this.asset});

  @override
  State<_ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<_ArticleCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: AppDecorations.card().copyWith(
          border: Border.all(
            color: _hovered
                ? AppColors.primary.withValues(alpha: 0.35)
                : AppColors.border,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(widget.asset, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.date,
                      style: AppTypography.caption
                          .copyWith(color: AppColors.mutedForeground),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 46,
                      child: Text(
                        widget.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.h6.copyWith(
                          color: _hovered
                              ? AppColors.primaryStrong
                              : AppColors.foreground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final List<String> items;

  const _TrendingCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Popularno',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 24, color: AppColors.borderSoft),
            Text(
              items[i],
              style: AppTypography.labelLarge
                  .copyWith(color: AppColors.foreground),
            ),
          ],
        ],
      ),
    );
  }
}
