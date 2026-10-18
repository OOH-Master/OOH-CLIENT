import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ui/ui.dart';
import 'landing_shared.dart';

/// Savet stručnjaka: generalni upit (opišete kampanju, stručnjak za lokacije
/// predlaže površine), uz prikaz razgovora na telefonu.
class ExpertAdviceSection extends StatelessWidget {
  const ExpertAdviceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    final content = _content(context);
    const phone = Center(child: _ExpertPhone());

    return LandingSection(
      key: LandingKeys.expert,
      color: AppColors.background,
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: content),
                const SizedBox(width: 64),
                const Expanded(child: phone),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [content, const SizedBox(height: 40), phone],
            ),
    );
  }

  Widget _content(BuildContext context) {
    const steps = [
      (
        '1',
        'Opišite kampanju',
        'Cilj, gradove, period zakupa i okvirni budžet, bez biranja površina.'
      ),
      (
        '2',
        'Stručnjak predlaže lokacije',
        'Stručnjak za lokacije bira površine koje odgovaraju cilju i publici.'
      ),
      (
        '3',
        'Prihvatite ponudu',
        'Predlog stiže kao jedna ponuda sa cenama svih vlasnika medija.'
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(title: 'Savet stručnjaka, odmah'),
        const SizedBox(height: 28),
        for (final s in steps)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${s.$1}. ${s.$2}', style: AppTypography.labelLarge),
                const SizedBox(height: 3),
                Text(
                  s.$3,
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.mutedForeground),
                ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton(
              onPressed: () => context.push('/app/inquiries/create'),
              child: const Text('Pošalji generalni upit'),
            ),
            OutlinedButton(
              onPressed: () => context.go('/discover'),
              child: const Text('Sam biram površine'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Telefon sa razgovorom: brif klijenta i predlog stručnjaka.
class _ExpertPhone extends StatelessWidget {
  const _ExpertPhone();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(31),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 14),
              color: AppColors.surfaceSunken,
              child: Row(
                children: [
                  const AppAvatar(name: 'Stručnjak Lokacije', size: 38),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Podrška stručnjaka',
                        style: AppTypography.labelLarge),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Bubble(
                    mine: true,
                    text:
                        'Lansiramo novi proizvod. Beograd i Novi Sad, dve nedelje u novembru, budžet oko 5.000 €.',
                  ),
                  const SizedBox(height: 10),
                  const _Bubble(
                    mine: false,
                    text:
                        'Predlažem šest lokacija: tri digitalna ekrana u centru i tri city light vitrine na pešačkim zonama.',
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 90),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final bool mine;
  final String text;

  const _Bubble({required this.mine, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 236),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: mine ? AppColors.primary : AppColors.surfaceSunken,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(mine ? 14 : 4),
            bottomRight: Radius.circular(mine ? 4 : 14),
          ),
        ),
        child: Text(
          text,
          style: AppTypography.bodySmall.copyWith(
            color: mine ? Colors.white : AppColors.foreground,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
