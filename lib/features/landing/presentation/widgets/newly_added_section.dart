import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_format.dart';
import '../../../../core/utils/sr_labels.dart';
import '../../../../core/widgets/ui/ui.dart';
import 'landing_shared.dart';

/// Nove površine na platformi: vodoravni niz kartica sa fotografijom, mestom,
/// formatom i cenom za period zakupa. Kartica otvara pretragu po nazivu.
class NewlyAddedSection extends StatelessWidget {
  const NewlyAddedSection({super.key});

  static const List<_Listing> _listings = [
    _Listing(
      title: 'Knez Mihailova',
      format: 'City light',
      city: 'Beograd',
      country: 'Srbija',
      price: 200,
      currency: 'EUR',
      cycle: 'FOUR_WEEK',
      size: '1,2 × 1,8 m',
      asset: LandingAssets.cityLightKnez,
    ),
    _Listing(
      title: 'Slavija',
      format: 'LED ekran',
      city: 'Beograd',
      country: 'Srbija',
      price: 1450,
      currency: 'EUR',
      cycle: 'TWO_WEEK',
      size: '8 × 4 m',
      asset: LandingAssets.ledSlavija,
      digital: true,
    ),
    _Listing(
      title: 'Brankov most',
      format: 'Bilbord 12 × 4',
      city: 'Beograd',
      country: 'Srbija',
      price: 680,
      currency: 'EUR',
      cycle: 'FOUR_WEEK',
      size: '12 × 4 m',
      asset: LandingAssets.bilbordBrankov,
    ),
    _Listing(
      title: 'Ilica',
      format: 'City light',
      city: 'Zagreb',
      country: 'Hrvatska',
      price: 160,
      currency: 'EUR',
      cycle: 'TWO_WEEK',
      size: '1,2 × 1,8 m',
    ),
    _Listing(
      title: 'Avenija Dubrovnik',
      format: 'Digitalni ekran',
      city: 'Zagreb',
      country: 'Hrvatska',
      price: 950,
      currency: 'EUR',
      cycle: 'ONE_WEEK',
      size: '6 × 3 m',
      digital: true,
    ),
    _Listing(
      title: 'Ferhadija',
      format: 'City light',
      city: 'Sarajevo',
      country: 'Bosna i Hercegovina',
      price: 390,
      currency: 'BAM',
      cycle: 'TWO_WEEK',
      size: '1,2 × 1,8 m',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LandingSection(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeading(
            title: 'Nedavno dodate površine',
            trailing: OutlinedButton(
              onPressed: () => context.go('/discover'),
              child: const Text('Pogledaj mapu'),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 372,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(2, 8, 2, 24),
              itemCount: _listings.length,
              separatorBuilder: (_, __) => const SizedBox(width: 20),
              itemBuilder: (context, index) =>
                  _ListingCard(listing: _listings[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Listing {
  final String title;
  final String format;
  final String city;
  final String country;
  final double price;
  final String currency;
  final String cycle;
  final String size;
  final String? asset;
  final bool digital;

  const _Listing({
    required this.title,
    required this.format,
    required this.city,
    required this.country,
    required this.price,
    required this.currency,
    required this.cycle,
    required this.size,
    this.asset,
    this.digital = false,
  });
}

class _ListingCard extends StatefulWidget {
  final _Listing listing;

  const _ListingCard({required this.listing});

  @override
  State<_ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<_ListingCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final l = widget.listing;
    const width = 284.0;
    const imageHeight = 168.0;

    final image = l.asset != null
        ? Image.asset(l.asset!,
            width: width, height: imageHeight, fit: BoxFit.cover)
        : UnitThumb(
            imageUrl: null,
            width: width,
            height: imageHeight,
            radius: 0,
            digital: l.digital,
          );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go(
            Uri(path: '/discover', queryParameters: {'keyword': l.title})
                .toString()),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: width,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    image,
                    Positioned(
                      top: 12,
                      left: 12,
                      child: StatusPill(
                        label: l.digital ? 'Digitalna' : 'Statična',
                        tone: l.digital ? PillTone.warning : PillTone.dark,
                        dense: true,
                      ),
                    ),
                    const Positioned(
                      top: 12,
                      right: 12,
                      child: StatusPill(
                        label: 'Dostupno',
                        tone: PillTone.success,
                        dense: true,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.h6,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        SrLabels.place(l.city, l.country),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.mutedForeground),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          SpecChip(label: l.format),
                          SpecChip(label: l.size),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: SrFormat.money(l.price, l.currency),
                            style: AppTypography.money.copyWith(fontSize: 18),
                          ),
                          TextSpan(
                            text: ' / ${SrFormat.cycleLabel(l.cycle)}',
                            style: AppTypography.bodySmall
                                .copyWith(color: AppColors.mutedForeground),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
