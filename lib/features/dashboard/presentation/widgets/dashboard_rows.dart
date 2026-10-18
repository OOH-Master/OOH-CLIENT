import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_format.dart';
import '../../../../core/utils/sr_labels.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../inquiry/domain/entities/inquiry.dart';
import '../../../inquiry/presentation/widgets/inquiry_status_badge.dart';
import '../../data/models/dashboard_models.dart';

/// Podaci reda spojeni zarezom: "16.11. – 29.11.2026., 3 površine, Beograd".
/// Prvo slovo postaje veliko kada red počinje oznakom ("generalni upit"), a
/// ne nazivom klijenta.
String _metaLine(List<String> parts, {bool capitalize = true}) {
  final text = parts.where((p) => p.trim().isNotEmpty).join(', ');
  if (!capitalize || text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

TextStyle get _titleStyle =>
    AppTypography.labelLarge.copyWith(color: AppColors.foreground);

TextStyle get _metaStyle =>
    AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground);

/// Red koji reaguje na prelaz miša i dodir.
class _HoverRow extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _HoverRow({required this.child, this.onTap});

  @override
  State<_HoverRow> createState() => _HoverRowState();
}

class _HoverRowState extends State<_HoverRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor:
          widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: _hovered && widget.onTap != null
              ? AppColors.surfaceSunken.withValues(alpha: 0.7)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Gradovi površina upita: "Beograd, Zagreb +1".
String inquiryCities(Inquiry inquiry, {int max = 2}) {
  final names = <String>[];
  for (final item in inquiry.items) {
    final c = SrLabels.city(item.inventoryItemCity);
    if (c.isNotEmpty && !names.contains(c)) names.add(c);
  }
  if (names.length <= max) return names.join(', ');
  return '${names.take(max).join(', ')} +${names.length - max}';
}

/// Upit u listi table: "Upit #9" i status, ispod period, broj površina,
/// gradovi i budžet. Stručnjak za lokacije ispred toga vidi klijenta i tip
/// klijenta, a na kraju kada je upit podnet.
class InquiryActivityRow extends StatelessWidget {
  final Inquiry inquiry;
  final VoidCallback? onTap;
  final bool adminView;

  const InquiryActivityRow({
    super.key,
    required this.inquiry,
    this.onTap,
    this.adminView = false,
  });

  @override
  Widget build(BuildContext context) {
    final brief = inquiry.isBrief ||
        (inquiry.inquiryType == null && inquiry.items.isEmpty);
    final cities = inquiryCities(inquiry);
    final hasPeriod = inquiry.startDate != null || inquiry.endDate != null;
    final budget = inquiry.budget;
    final client = adminView ? (inquiry.clientName ?? '').trim() : '';

    final meta = _metaLine(
      [
        client,
        if (adminView && (inquiry.requesterType ?? '').isNotEmpty)
          SrLabels.requesterType(inquiry.requesterType).toLowerCase(),
        if (hasPeriod) SrFormat.period(inquiry.startDate, inquiry.endDate),
        brief
            ? (adminView ? 'brif kampanje' : 'generalni upit')
            : SrFormat.count(
                inquiry.unitCount, 'površina', 'površine', 'površina'),
        cities,
        if (budget != null && budget > 0)
          'budžet ${SrFormat.money(budget, 'EUR', decimals: false)}',
        if (adminView && inquiry.createdAt != null)
          'podnet ${SrFormat.relative(inquiry.createdAt)}',
      ],
      capitalize: client.isEmpty,
    );

    return _HoverRow(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Upit #${inquiry.id}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _titleStyle,
                ),
              ),
              const SizedBox(width: 8),
              InquiryStatusBadge(status: inquiry.status, dense: true),
            ],
          ),
          if (meta.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              meta,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _metaStyle,
            ),
          ],
        ],
      ),
    );
  }
}

/// Ton i naziv statusa zahteva za ponudu vlasnika medija.
PillTone quoteTone(String status) {
  switch (status.toUpperCase()) {
    case 'NEW':
      return PillTone.violet;
    case 'IN_PROGRESS':
      return PillTone.info;
    case 'SUBMITTED':
      return PillTone.primary;
    case 'DECLINED':
      return PillTone.neutral;
    default:
      return PillTone.neutral;
  }
}

/// Zahtev za ponudu u listi table: "Upit #4" i status, ispod klijent, period,
/// broj površina i gradovi, a desno iznos po valutama.
class QuoteRequestRow extends StatelessWidget {
  final OwnerQuoteSummary quote;
  final VoidCallback? onTap;

  const QuoteRequestRow({super.key, required this.quote, this.onTap});

  @override
  Widget build(BuildContext context) {
    final amounts = quote.amounts.entries.toList();
    final hasPeriod = quote.startDate != null || quote.endDate != null;

    final meta = _metaLine(
      [
        quote.requesterLabel,
        if (hasPeriod) SrFormat.period(quote.startDate, quote.endDate),
        SrFormat.count(quote.items.length, 'površina', 'površine', 'površina'),
        quote.cities,
      ],
      capitalize: false,
    );

    return _HoverRow(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Upit #${quote.inquiryId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _titleStyle,
                ),
              ),
              const SizedBox(width: 8),
              StatusPill(
                label: SrLabels.quoteStatus(quote.status),
                tone: quoteTone(quote.status),
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  meta,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _metaStyle,
                ),
              ),
              if (amounts.isNotEmpty) ...[
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      SrFormat.money(amounts.first.value, amounts.first.key,
                          decimals: false),
                      style: AppTypography.money.copyWith(fontSize: 15),
                    ),
                    for (final extra in amounts.skip(1))
                      Text(
                        SrFormat.money(extra.value, extra.key, decimals: false),
                        style: AppTypography.money.copyWith(
                            fontSize: 12.5, color: AppColors.mutedForeground),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Površina sa brojem zahteva u kojima se pojavila.
class TopUnitRow extends StatelessWidget {
  final QuoteUnitLine unit;
  final int requests;
  final VoidCallback? onTap;

  const TopUnitRow(
      {super.key, required this.unit, required this.requests, this.onTap});

  @override
  Widget build(BuildContext context) {
    final price = unit.pricePerCycle == null
        ? null
        : SrFormat.priceWithCycle(
            unit.pricePerCycle, unit.currency, unit.cycleType);
    final specs = <String>[
      SrLabels.format(unit.mediaFormat),
      SrLabels.unitType(unit.unitType),
      SrLabels.dimensions(unit.width, unit.height, unit.sizeUnit),
    ].where((s) => s.isNotEmpty).toList();

    return _HoverRow(
      onTap: onTap,
      child: UnitLine(
        padding: EdgeInsets.zero,
        compact: true,
        imageUrl: unit.imageUrl,
        digital: unit.digital,
        code: unit.code,
        title: unit.title,
        subtitle: unit.place,
        specs: specs,
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              SrFormat.count(requests, 'zahtev', 'zahteva', 'zahteva'),
              style: AppTypography.labelLarge
                  .copyWith(color: AppColors.foreground),
            ),
            if (price != null) ...[
              const SizedBox(height: 2),
              Text(
                price,
                style: AppTypography.caption.copyWith(
                  color: AppColors.mutedForeground,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
