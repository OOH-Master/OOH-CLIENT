import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_version.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ui/ui.dart';
import 'landing_shared.dart';

/// Podnožje početne strane na tamnoj pozadini, sa oznakom objavljene verzije.
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  /// Kolone veza: naziv i putanja (`null` = bez akcije).
  static const List<(String, List<(String, String?)>)> _columns = [
    (
      'Rešenja',
      [
        ('Oglašivači', '/auth/register'),
        ('Agencije', '/auth/register'),
        ('Vlasnici medija', '/auth/register'),
      ],
    ),
    (
      'Proizvodi',
      [
        ('Pretraga površina', '/discover'),
        ('Planer kampanja', '/auth/login'),
        ('Analitika', '/auth/login'),
      ],
    ),
    (
      'Resursi',
      [
        ('Blog', null),
        ('Studije slučaja', null),
        ('Podrška', null),
      ],
    ),
    (
      'Kompanija',
      [
        ('O nama', null),
        ('Karijera', null),
        ('Kontakt', null),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 1000;
    final side = landingGutter(context);

    final brand = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BrandMark(onDark: true, size: 34),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Text(
            'Oglasni prostor u Srbiji, Hrvatskoj i Bosni i Hercegovini, na jednom mestu: od pretrage do prihvaćene ponude.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.inkMuted),
          ),
        ),
      ],
    );

    final columns = [
      for (final c in _columns) _FooterColumn(title: c.$1, links: c.$2),
    ];

    return ColoredBox(
      color: AppColors.ink,
      child: Padding(
        padding: EdgeInsets.fromLTRB(side, wide ? 64 : 44, side, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: brand),
                      for (final c in columns) Expanded(child: c),
                    ],
                  )
                else ...[
                  brand,
                  const SizedBox(height: 32),
                  Wrap(
                    spacing: 24,
                    runSpacing: 28,
                    children: [
                      for (final c in columns)
                        SizedBox(
                          width: width >= 600
                              ? (width - side * 2 - 24 * 3) / 4
                              : (width - side * 2 - 24) / 2,
                          child: c,
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 40),
                const Divider(height: 1, color: AppColors.inkLine),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 10,
                  children: [
                    Text(
                      '© 2026 OOH Platforma. Sva prava zadržana.',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.inkMuted),
                    ),
                    Text(
                      AppVersion.displayLabel,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.inkMuted.withValues(alpha: 0.8),
                        fontFamily: 'monospace',
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<(String, String?)> links;

  const _FooterColumn({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.labelLarge.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 14),
        for (final l in links)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _FooterLink(label: l.$1, route: l.$2),
          ),
      ],
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String label;
  final String? route;

  const _FooterLink({required this.label, required this.route});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final route = widget.route;
    final text = Text(
      widget.label,
      style: AppTypography.bodySmall.copyWith(
        color: _hovered && route != null ? Colors.white : AppColors.inkMuted,
      ),
    );
    if (route == null) return text;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(onTap: () => context.go(route), child: text),
    );
  }
}
