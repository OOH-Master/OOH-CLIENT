import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_format.dart';
import '../../../../core/utils/sr_labels.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../discover/data/dto/dto.dart';

/// Status površine vlasnika: "Aktivna" (vidljiva u pretrazi) ili "Neaktivna".
class InventoryStatus {
  InventoryStatus._();

  /// Server podrazumeva ACTIVE kada status nije upisan.
  static bool isActive(String? status) {
    final s = (status ?? 'ACTIVE').toUpperCase();
    return s == 'ACTIVE' || s == 'AVAILABLE';
  }

  static String label(String? status) {
    switch ((status ?? 'ACTIVE').toUpperCase()) {
      case 'ACTIVE':
      case 'AVAILABLE':
        return 'Aktivna';
      case 'DISABLED':
      case 'INACTIVE':
        return 'Neaktivna';
      case 'BOOKED':
        return 'Zakupljena';
      default:
        return status!;
    }
  }

  static PillTone tone(String? status) {
    switch ((status ?? 'ACTIVE').toUpperCase()) {
      case 'ACTIVE':
      case 'AVAILABLE':
        return PillTone.success;
      case 'BOOKED':
        return PillTone.primary;
      default:
        return PillTone.neutral;
    }
  }
}

/// Podaci jedne površine pripremljeni za prikaz (naziv, mesto, svojstva, cena).
class InventoryView {
  final InventoryItemDto item;

  const InventoryView(this.item);

  String? get code {
    final c = item.vendorInventoryId?.trim();
    return (c == null || c.isEmpty) ? null : c;
  }

  String get title {
    final name = item.siteName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return code ?? 'Površina #${item.id}';
  }

  String get place => SrLabels.place(item.city?.name, item.country?.name);

  String? get address {
    final a = item.fullAddress?.trim();
    return (a == null || a.isEmpty) ? null : a;
  }

  bool get digital => SrLabels.isDigital(item.unitType?.name);

  String get typeLabel => SrLabels.unitType(item.unitType?.name);

  String get formatLabel =>
      SrLabels.format(item.mediaFormat?.name ?? item.vendorMediaFormatName);

  String get venueLabel =>
      SrLabels.venue(item.venueType?.name ?? item.environment);

  String get sizeLabel {
    final physical = SrLabels.dimensions(
        item.physicalWidth, item.physicalHeight, item.sizeUnit);
    if (physical.isNotEmpty) return physical;
    final pw = item.pixelWidth;
    final ph = item.pixelHeight;
    if (pw != null && ph != null && pw > 0 && ph > 0) return '$pw × $ph px';
    return '';
  }

  bool get hasPrice => item.pricePerCycle != null;

  String get price => SrFormat.money(item.pricePerCycle, item.currency);

  String get cycle => SrFormat.cycleLabel(item.cycleType);

}

/// Mala oznaka šifre površine ("LiD95").
class InventoryCodeTag extends StatelessWidget {
  final String code;

  const InventoryCodeTag(this.code, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        code,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.text2,
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// Oznake svojstava; digitalni tip dobija ćilibarnu boju.
class InventorySpecChips extends StatelessWidget {
  final InventoryView view;
  final bool withVenue;

  const InventorySpecChips(this.view, {super.key, this.withVenue = false});

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    if (view.typeLabel.isNotEmpty) {
      chips.add(SpecChip(
        label: view.typeLabel,
        color: view.digital ? AppColors.warning : null,
      ));
    }
    for (final s in [view.formatLabel, view.sizeLabel]) {
      if (s.isNotEmpty && s != view.typeLabel) chips.add(SpecChip(label: s));
    }
    if (withVenue && view.venueLabel.isNotEmpty) {
      chips.add(SpecChip(label: view.venueLabel));
    }
    if (chips.isEmpty) {
      return Text('—',
          style: AppTypography.bodySmall.copyWith(color: AppColors.subtle));
    }
    return Wrap(spacing: 6, runSpacing: 6, children: chips);
  }
}

/// Cena po ciklusu, poravnata desno; bez cene stoji napomena.
class InventoryPrice extends StatelessWidget {
  final InventoryView view;
  final CrossAxisAlignment alignment;

  const InventoryPrice(this.view,
      {super.key, this.alignment = CrossAxisAlignment.end});

  @override
  Widget build(BuildContext context) {
    if (!view.hasPrice) {
      return Text('Bez cene',
          style: AppTypography.labelMedium
              .copyWith(color: AppColors.mutedForeground));
    }
    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(view.price, style: AppTypography.money.copyWith(fontSize: 15)),
        if (view.cycle.isNotEmpty)
          Text('/ ${view.cycle}',
              style: AppTypography.caption
                  .copyWith(color: AppColors.mutedForeground)),
      ],
    );
  }
}

/// Akcije reda: izmena, uključivanje/isključivanje i brisanje.
class InventoryRowMenu extends StatelessWidget {
  final bool active;
  final ValueChanged<String> onSelected;

  const InventoryRowMenu(
      {super.key, required this.active, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Akcije',
      icon: const Icon(Icons.more_horiz_rounded, color: AppColors.text2),
      onSelected: onSelected,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: _MenuLine(icon: Icons.edit_outlined, label: 'Izmeni'),
        ),
        PopupMenuItem(
          value: 'toggle',
          child: _MenuLine(
            icon: active
                ? Icons.pause_circle_outline_rounded
                : Icons.play_circle_outline_rounded,
            label: active ? 'Deaktiviraj' : 'Aktiviraj',
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: _MenuLine(
            icon: Icons.delete_outline_rounded,
            label: 'Obriši',
            color: AppColors.destructive,
          ),
        ),
      ],
    );
  }
}

class _MenuLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MenuLine({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.foreground;
    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? AppColors.text2),
        const SizedBox(width: 10),
        Text(label, style: AppTypography.bodyMedium.copyWith(color: c)),
      ],
    );
  }
}

/// Zaglavlje tabele površina (širok ekran).
class InventoryTableHeader extends StatelessWidget {
  final bool? allSelected;
  final ValueChanged<bool?> onSelectAll;

  const InventoryTableHeader(
      {super.key, required this.allSelected, required this.onSelectAll});

  @override
  Widget build(BuildContext context) {
    final style =
        AppTypography.labelSmall.copyWith(color: AppColors.mutedForeground);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: const BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Checkbox(
              value: allSelected,
              tristate: true,
              onChanged: onSelectAll,
            ),
          ),
          Expanded(flex: 6, child: Text('Površina', style: style)),
          const SizedBox(width: 12),
          Expanded(flex: 3, child: Text('Mesto', style: style)),
          const SizedBox(width: 12),
          Expanded(flex: 4, child: Text('Tip i format', style: style)),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text('Cena', style: style, textAlign: TextAlign.right),
          ),
          const SizedBox(width: 24),
          SizedBox(width: 108, child: Text('Status', style: style)),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

/// Red tabele: izbor, sličica, šifra i naziv, mesto, svojstva, cena, status, akcije.
class InventoryTableRow extends StatefulWidget {
  final InventoryItemDto item;
  final bool selected;
  final VoidCallback onToggleSelect;
  final VoidCallback onOpen;
  final ValueChanged<String> onAction;

  const InventoryTableRow({
    super.key,
    required this.item,
    required this.selected,
    required this.onToggleSelect,
    required this.onOpen,
    required this.onAction,
  });

  @override
  State<InventoryTableRow> createState() => _InventoryTableRowState();
}

class _InventoryTableRowState extends State<InventoryTableRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final view = InventoryView(widget.item);
    final status = widget.item.status;
    final bg = widget.selected
        ? AppColors.primarySoft.withValues(alpha: 0.6)
        : (_hover ? AppColors.surfaceSunken.withValues(alpha: 0.6) : null);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: bg ?? Colors.transparent,
        child: InkWell(
          onTap: widget.onOpen,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Checkbox(
                    value: widget.selected,
                    onChanged: (_) => widget.onToggleSelect(),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Row(
                    children: [
                      UnitThumb(
                        imageUrl: widget.item.assetUrl,
                        width: 72,
                        height: 52,
                        digital: view.digital,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (view.code != null) ...[
                              InventoryCodeTag(view.code!),
                              const SizedBox(height: 3),
                            ],
                            Text(
                              view.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelLarge,
                            ),
                            if (view.address != null)
                              Text(
                                view.address!,
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        view.place.isEmpty ? '—' : view.place,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelMedium
                            .copyWith(color: AppColors.foreground),
                      ),
                      if (view.venueLabel.isNotEmpty)
                        Text(
                          view.venueLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption
                              .copyWith(color: AppColors.mutedForeground),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(flex: 4, child: InventorySpecChips(view)),
                const SizedBox(width: 12),
                Expanded(flex: 3, child: InventoryPrice(view)),
                const SizedBox(width: 24),
                SizedBox(
                  width: 108,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: StatusPill(
                      label: InventoryStatus.label(status),
                      tone: InventoryStatus.tone(status),
                      dense: true,
                    ),
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: InventoryRowMenu(
                    active: InventoryStatus.isActive(status),
                    onSelected: widget.onAction,
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

/// Kartica površine za uži ekran; dugi pritisak uključuje izbor.
class InventoryCard extends StatelessWidget {
  final InventoryItemDto item;
  final bool selected;
  final bool selectionMode;
  final VoidCallback onToggleSelect;
  final VoidCallback onOpen;
  final ValueChanged<String> onAction;

  const InventoryCard({
    super.key,
    required this.item,
    required this.selected,
    required this.selectionMode,
    required this.onToggleSelect,
    required this.onOpen,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final view = InventoryView(item);
    final status = item.status;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? AppColors.primarySoft : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: selectionMode ? onToggleSelect : onOpen,
          onLongPress: onToggleSelect,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (selectionMode)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Checkbox(
                          value: selected,
                          onChanged: (_) => onToggleSelect(),
                        ),
                      ),
                    UnitThumb(
                      imageUrl: item.assetUrl,
                      width: 92,
                      height: 68,
                      digital: view.digital,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (view.code != null) ...[
                            InventoryCodeTag(view.code!),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            view.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                AppTypography.labelLarge.copyWith(fontSize: 15),
                          ),
                          if (view.place.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              view.place,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySmall
                                  .copyWith(color: AppColors.mutedForeground),
                            ),
                          ],
                        ],
                      ),
                    ),
                    InventoryRowMenu(
                      active: InventoryStatus.isActive(status),
                      onSelected: onAction,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InventorySpecChips(view, withVenue: true),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: InventoryPrice(view,
                            alignment: CrossAxisAlignment.start),
                      ),
                      StatusPill(
                        label: InventoryStatus.label(status),
                        tone: InventoryStatus.tone(status),
                        dense: true,
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
