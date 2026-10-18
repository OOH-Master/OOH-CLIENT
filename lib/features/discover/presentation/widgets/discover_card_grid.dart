import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../domain/entities/ooh_unit.dart';
import 'unit_card_parts.dart';
import 'unit_labels.dart';

/// Kartica oglasne površine: fotografija 16:10 sa tipom, srcem i korpom, zatim
/// šifra, naziv, mesto, svojstva, cena za ciklus zakupa i dostupnost.
///
/// Ista kartica se koristi u mreži pretrage, u listi na telefonu i u omiljenim.
class DiscoverCardGrid extends StatefulWidget {
  final OohUnit unit;

  /// Površina je istaknuta na mapi.
  final bool isSelected;

  /// Površina je u korpi za upit.
  final bool isSelectedForInquiry;
  final VoidCallback? onTap;

  /// Bez ove akcije kartica nema korpu (npr. omiljene površine).
  final VoidCallback? onAddToInquiry;
  final ValueChanged<bool>? onHoverChanged;
  final bool showFavorite;

  const DiscoverCardGrid({
    super.key,
    required this.unit,
    this.isSelected = false,
    this.isSelectedForInquiry = false,
    this.onTap,
    this.onAddToInquiry,
    this.onHoverChanged,
    this.showFavorite = true,
  });

  @override
  State<DiscoverCardGrid> createState() => _DiscoverCardGridState();
}

class _DiscoverCardGridState extends State<DiscoverCardGrid> {
  bool _hovered = false;

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
    widget.onHoverChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final inBasket = widget.isSelectedForInquiry;
    final ring = inBasket
        ? AppColors.primary
        : (widget.isSelected
            ? AppColors.primaryTint
            : AppColors.primary.withValues(alpha: 0));

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
              color: _hovered
                  ? AppColors.subtle.withValues(alpha: 0.5)
                  : AppColors.border),
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: ring, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card - 1),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CardMedia(
                    unit: widget.unit,
                    inBasket: inBasket,
                    showFavorite: widget.showFavorite,
                    onAddToInquiry: widget.onAddToInquiry,
                  ),
                  _CardBody(unit: widget.unit),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardMedia extends StatelessWidget {
  final OohUnit unit;
  final bool inBasket;
  final bool showFavorite;
  final VoidCallback? onAddToInquiry;

  const _CardMedia({
    required this.unit,
    required this.inBasket,
    required this.showFavorite,
    required this.onAddToInquiry,
  });

  @override
  Widget build(BuildContext context) {
    final owner = unit.mediaOwnerName ?? '';
    final hasOwner = owner.isNotEmpty;
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Stack(
        fit: StackFit.expand,
        children: [
          LayoutBuilder(
            builder: (context, box) => UnitThumb(
              imageUrl: unit.imageUrl,
              width: box.maxWidth,
              height: box.maxHeight,
              radius: 0,
              digital: unit.isDigitalUnit,
            ),
          ),
          // Blaga senka pri dnu fotografije, da se vidi naziv vlasnika.
          if (hasOwner)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 76,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x000F1226), Color(0x990F1226)],
                  ),
                ),
              ),
            ),
          Positioned(top: 10, left: 10, child: UnitTypeBadge(unit: unit)),
          Positioned(
            top: 10,
            right: 10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showFavorite)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: UnitFavoriteButton(unit: unit, size: 32),
                  ),
                if (onAddToInquiry != null)
                  InquiryBasketButton(
                      selected: inBasket, onTap: onAddToInquiry),
              ],
            ),
          ),
          if (hasOwner)
            Positioned(
              left: 12,
              right: 12,
              bottom: 9,
              child: Text(
                owner,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  final OohUnit unit;

  const _CardBody({required this.unit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          UnitTitleRow(unit: unit),
          const SizedBox(height: 4),
          UnitPlaceLine(text: unit.placeLine),
          const SizedBox(height: 10),
          OneLineChips(labels: unit.specChips()),
          const SizedBox(height: 12),
          const Divider(height: 1),
          SizedBox(
            height: 50,
            child: Row(
              children: [
                Expanded(child: UnitPriceText(unit: unit)),
                const SizedBox(width: 8),
                StatusPill(
                    label: unit.statusLabel,
                    tone: unit.statusTone,
                    dense: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Oznake svojstava u jednom redu: što ne stane, ne prikazuje se (bez preloma),
/// pa su sve kartice iste visine.
class OneLineChips extends StatelessWidget {
  final List<String> labels;

  const OneLineChips({super.key, required this.labels});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minHeight: 0,
          maxHeight: double.infinity,
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final l in labels) SpecChip(label: l)],
          ),
        ),
      ),
    );
  }
}

/// Kartica dok se rezultati učitavaju.
class DiscoverCardSkeleton extends StatelessWidget {
  const DiscoverCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget bar(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
        );

    return DecoratedBox(
      decoration: AppDecorations.card(),
      child: Shimmer.fromColors(
        baseColor: AppColors.surfaceSunken,
        highlightColor: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppRadius.card)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bar(160, 14),
                  const SizedBox(height: 8),
                  bar(110, 11),
                  const SizedBox(height: 14),
                  Row(children: [
                    bar(64, 20),
                    const SizedBox(width: 6),
                    bar(72, 20),
                  ]),
                  const SizedBox(height: 18),
                  bar(96, 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
