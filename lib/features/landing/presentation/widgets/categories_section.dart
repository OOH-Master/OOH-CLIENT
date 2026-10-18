import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ui/ui.dart';
import 'landing_shared.dart';

/// Kategorije oglasnog prostora: četiri kartice koje vode na pretragu.
class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  static const List<_Category> _categories = [
    _Category(
      title: 'Digitalni bilbordi',
      subtitle: 'Upečatljivi LED ekrani na najprometnijim lokacijama u gradu.',
    ),
    _Category(
      title: 'Ekrani u javnom prevozu',
      subtitle: 'Publika putnika na stanicama, terminalima i u vozilima.',
    ),
    _Category(
      title: 'City light na stajalištima',
      subtitle:
          'Osvetljene vitrine u nivou ulice, na nadstrešnicama i trotoarima.',
    ),
    _Category(
      title: 'Aerodromi',
      subtitle: 'Putnici iz zemlje i sveta u zonama dolazaka i odlazaka.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LandingSection(
      key: LandingKeys.categories,
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeading(
            title: 'Istražite oglasni prostor po vrsti',
            trailing: OutlinedButton(
              onPressed: () => context.go('/discover'),
              child: const Text('Sve površine'),
            ),
          ),
          const SizedBox(height: 40),
          LayoutBuilder(builder: (context, constraints) {
            final w = constraints.maxWidth;
            final cols = w >= 1000 ? 4 : (w >= 560 ? 2 : 1);
            const gap = 20.0;
            final tileWidth = (w - gap * (cols - 1)) / cols;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final c in _categories)
                  SizedBox(width: tileWidth, child: _CategoryCard(category: c)),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _Category {
  final String title;
  final String subtitle;

  const _Category({required this.title, required this.subtitle});
}

class _CategoryCard extends StatefulWidget {
  final _Category category;

  const _CategoryCard({required this.category});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.category;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go('/discover'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(22),
          decoration: AppDecorations.card().copyWith(
            border: Border.all(
              color: _hovered
                  ? AppColors.primary.withValues(alpha: 0.35)
                  : AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c.title, style: AppTypography.h5),
              const SizedBox(height: 6),
              SizedBox(
                height: 42,
                child: Text(
                  c.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.mutedForeground),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pogledaj površine',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
