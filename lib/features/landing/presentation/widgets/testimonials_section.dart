import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ui/ui.dart';
import 'landing_shared.dart';

/// Iskustva klijenata: tri kartice sa citatom, imenom i ulogom.
class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  static const List<(String, String, String)> _testimonials = [
    (
      'Jelena Petrović',
      'Direktorka marketinga, Nova',
      'Alati za planiranje su promenili način na koji radimo. Pronašli smo i zakupili lokacije koje bismo inače propustili, a povrat ulaganja je premašio očekivanja.',
    ),
    (
      'Marko Ilić',
      'Direktor, Bright Solutions',
      'Intuitivna i moćna platforma za spoljno oglašavanje. Od pretrage do zakupa sve je teklo bez zastoja, a podrška je bila odlična od početka do kraja.',
    ),
    (
      'Ana Kovačević',
      'Brend menadžerka, Luxe',
      'Za lansiranje novog proizvoda dosegli smo veliku, ciljanu publiku. Analitika je jasno pokazala efekat, što je bilo ključno za upravu.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LandingSection(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeading(
            title: 'Brendovi koji nam veruju',
            center: true,
          ),
          const SizedBox(height: 44),
          LayoutBuilder(builder: (context, constraints) {
            final w = constraints.maxWidth;
            final cols = w >= 960 ? 3 : (w >= 620 ? 2 : 1);
            const gap = 20.0;
            final tileWidth = (w - gap * (cols - 1)) / cols;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              alignment: WrapAlignment.center,
              children: [
                for (final t in _testimonials)
                  SizedBox(
                    width: tileWidth,
                    child:
                        _TestimonialCard(name: t.$1, role: t.$2, quote: t.$3),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String name;
  final String role;
  final String quote;

  const _TestimonialCard(
      {required this.name, required this.role, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.card(radius: AppRadius.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 114,
            child: Text(
              quote,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.text2),
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.borderSoft),
          const SizedBox(height: 16),
          Row(
            children: [
              AppAvatar(name: name, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTypography.labelLarge),
                    Text(
                      role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption
                          .copyWith(color: AppColors.mutedForeground),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
