import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../domain/entities/ooh_unit.dart';
import 'discover_card_grid.dart';
import 'unit_card_parts.dart';
import 'unit_labels.dart';

/// Kartica izabrane površine iznad mape: fotografija, šifra i naziv, mesto,
/// cena za ciklus, dostupnost, korpa i prelaz na detalj.
class InventoryMapCard extends StatelessWidget {
  final OohUnit unit;
  final VoidCallback onClose;
  final VoidCallback onViewDetails;
  final bool isSelectedForInquiry;

  /// Bez ove akcije kartica nema dugme za upit.
  final VoidCallback? onToggleInquiry;

  const InventoryMapCard({
    super.key,
    required this.unit,
    required this.onClose,
    required this.onViewDetails,
    this.isSelectedForInquiry = false,
    this.onToggleInquiry,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.raised,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: onViewDetails,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 108,
                  height: 108,
                  child: Stack(
                    children: [
                      UnitThumb(
                        imageUrl: unit.imageUrl,
                        width: 108,
                        height: 108,
                        radius: 8,
                        digital: unit.isDigitalUnit,
                      ),
                      Positioned(
                        top: 6,
                        left: 6,
                        child: UnitTypeBadge(unit: unit, dense: true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _details()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: UnitTitleRow(unit: unit)),
            const SizedBox(width: 4),
            SizedBox(
              width: 28,
              height: 28,
              child: IconButton(
                tooltip: 'Zatvori',
                onPressed: onClose,
                padding: EdgeInsets.zero,
                iconSize: 18,
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.mutedForeground),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        UnitPlaceLine(text: unit.placeLine),
        const SizedBox(height: 8),
        OneLineChips(labels: unit.specChips(max: 2)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: UnitPriceText(unit: unit, fontSize: 16)),
            const SizedBox(width: 6),
            StatusPill(
                label: unit.statusLabel, tone: unit.statusTone, dense: true),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) =>
              _actions(narrow: constraints.maxWidth < 250),
        ),
      ],
    );
  }

  /// Korpa i "Detalji"; u uskoj kartici korpa je samo ikonica.
  Widget _actions({required bool narrow}) {
    final selected = isSelectedForInquiry;
    final basketStyle = OutlinedButton.styleFrom(
      minimumSize: const Size(36, 36),
      padding: EdgeInsets.symmetric(horizontal: narrow ? 0 : 10),
      foregroundColor:
          selected ? AppColors.primaryStrong : AppColors.foreground,
      backgroundColor: selected ? AppColors.primarySoft : AppColors.surface,
      side:
          BorderSide(color: selected ? AppColors.primaryTint : AppColors.input),
      textStyle:
          AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
    );
    final basketIcon = Icon(
      selected ? Icons.check_rounded : Icons.shopping_basket_outlined,
      size: 16,
    );
    final details = FilledButton(
      onPressed: onViewDetails,
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        textStyle:
            AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
      ),
      child: const Text('Detalji'),
    );

    if (onToggleInquiry == null) {
      return Align(alignment: Alignment.centerLeft, child: details);
    }
    if (narrow) {
      return Row(
        children: [
          Expanded(child: details),
          const SizedBox(width: 8),
          Tooltip(
            message: selected ? 'Ukloni iz upita' : 'Dodaj u upit',
            child: SizedBox(
              width: 36,
              child: OutlinedButton(
                onPressed: onToggleInquiry,
                style: basketStyle,
                child: basketIcon,
              ),
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onToggleInquiry,
            icon: basketIcon,
            label: Text(
              selected ? 'U upitu' : 'Dodaj u upit',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            style: basketStyle,
          ),
        ),
        const SizedBox(width: 8),
        details,
      ],
    );
  }
}
