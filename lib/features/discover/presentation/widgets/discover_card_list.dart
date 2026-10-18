import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../domain/entities/ooh_unit.dart';
import 'unit_card_parts.dart';
import 'unit_labels.dart';

/// Površina kao red liste: sličica, šifra, naziv, mesto, svojstva, cena,
/// dostupnost i korpa. Isti podaci kao na kartici, gušće složeni.
class DiscoverCardList extends StatefulWidget {
  final OohUnit unit;
  final bool isSelected;
  final bool isSelectedForInquiry;
  final VoidCallback? onTap;
  final VoidCallback? onAddToInquiry;
  final ValueChanged<bool>? onHoverChanged;

  const DiscoverCardList({
    super.key,
    required this.unit,
    this.isSelected = false,
    this.isSelectedForInquiry = false,
    this.onTap,
    this.onAddToInquiry,
    this.onHoverChanged,
  });

  @override
  State<DiscoverCardList> createState() => _DiscoverCardListState();
}

class _DiscoverCardListState extends State<DiscoverCardList> {
  bool _hovered = false;

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
    widget.onHoverChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.unit;
    final inBasket = widget.isSelectedForInquiry;
    final ring = inBasket
        ? AppColors.primary
        : (widget.isSelected
            ? AppColors.primaryTint
            : AppColors.primary.withValues(alpha: 0));

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 520;
        final specs = [
          if (unit.typeLabel.isNotEmpty) unit.typeLabel,
          ...unit.specChips(max: narrow ? 1 : 3),
        ];

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
                child: UnitLine(
                  imageUrl: unit.imageUrl,
                  digital: unit.isDigitalUnit,
                  code: unit.code == unit.title ? null : unit.code,
                  title: unit.title,
                  subtitle: unit.placeLine,
                  specs: specs,
                  compact: narrow,
                  padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                  onTap: widget.onTap,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: narrow ? 104 : 150),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            UnitPriceText(
                              unit: unit,
                              fontSize: 15.5,
                              alignment: CrossAxisAlignment.end,
                            ),
                            const SizedBox(height: 6),
                            StatusPill(
                              label: unit.statusLabel,
                              tone: unit.statusTone,
                              dense: true,
                            ),
                          ],
                        ),
                      ),
                      if (widget.onAddToInquiry != null) ...[
                        const SizedBox(width: 12),
                        InquiryBasketButton(
                          selected: inBasket,
                          onTap: widget.onAddToInquiry,
                          size: 36,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
