import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_format.dart';
import '../../../../core/utils/sr_labels.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../domain/entities/inquiry.dart';
import 'inquiry_status_badge.dart';

/// Kartica upita u listi: broj, tip i starost upita sa statusom, zatim period
/// kampanje, budžet i broj površina, pa sličice izabranih površina sa gradovima.
/// Kada je ponuda stigla, dno kartice nosi dugme "Pogledaj ponudu".
class InquiryCard extends StatefulWidget {
  final Inquiry inquiry;
  final VoidCallback onTap;

  /// Kada nije null, dno kartice nosi dugme za pregled ponude.
  final VoidCallback? onViewOffer;

  /// Prikazuje klijenta (stručnjaku i agenciji koja radi za više brendova).
  final bool showClient;

  /// Dodatni red na dnu (akcije stručnjaka).
  final Widget? footer;

  /// Kartica popunjava visinu reda u mreži od dve kolone.
  final bool fill;

  const InquiryCard({
    super.key,
    required this.inquiry,
    required this.onTap,
    this.onViewOffer,
    this.showClient = false,
    this.footer,
    this.fill = false,
  });

  @override
  State<InquiryCard> createState() => _InquiryCardState();
}

class _InquiryCardState extends State<InquiryCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final inquiry = widget.inquiry;
    final hasStrip = _UnitStrip.hasContent(inquiry);

    final body = Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _CardHeader(inquiry: inquiry),
          if (widget.showClient && (inquiry.clientName ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            _ClientLine(inquiry: inquiry),
          ],
          const SizedBox(height: 16),
          _CardMeta(inquiry: inquiry),
          if (hasStrip) ...[
            const SizedBox(height: 16),
            _UnitStrip(inquiry: inquiry),
          ],
          if (widget.footer != null) ...[
            const SizedBox(height: 16),
            widget.footer!,
          ],
        ],
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: _hover
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.border,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: widget.fill ? MainAxisSize.max : MainAxisSize.min,
              children: [
                body,
                if (widget.fill) const Spacer(),
                if (widget.onViewOffer != null)
                  _OfferFooter(onPressed: widget.onViewOffer!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final Inquiry inquiry;

  const _CardHeader({required this.inquiry});

  @override
  Widget build(BuildContext context) {
    final type = SrLabels.inquiryType(inquiry.inquiryType);
    final age = SrFormat.relative(inquiry.createdAt);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Text('Upit #${inquiry.id}', style: AppTypography.h5),
              if (type.isNotEmpty) SpecChip(label: type),
              if (age.isNotEmpty)
                Text(age,
                    style: AppTypography.caption
                        .copyWith(color: AppColors.subtle)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        InquiryStatusBadge(status: inquiry.status),
      ],
    );
  }
}

/// Klijent sa tipom u zagradi: "Aurora Kozmetika d.o.o. (brend)".
class _ClientLine extends StatelessWidget {
  final Inquiry inquiry;

  const _ClientLine({required this.inquiry});

  @override
  Widget build(BuildContext context) {
    final type = SrLabels.requesterType(inquiry.requesterType).toLowerCase();
    return Text(
      type.isEmpty ? inquiry.clientName! : '${inquiry.clientName!} ($type)',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.bodySmall.copyWith(color: AppColors.text2),
    );
  }
}

class _CardMeta extends StatelessWidget {
  final Inquiry inquiry;

  const _CardMeta({required this.inquiry});

  @override
  Widget build(BuildContext context) {
    final count = inquiry.unitCount;
    // Širina ograničena, da merenje visine (IntrinsicHeight) i raspored daju
    // isti prelom teksta.
    Widget capped(Widget child) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300), child: child);
    final noPeriod = inquiry.startDate == null && inquiry.endDate == null;
    return Wrap(
      spacing: 28,
      runSpacing: 14,
      children: [
        capped(MetaItem(
          label: 'Period kampanje',
          value: noPeriod
              ? 'Nije naveden'
              : SrFormat.period(inquiry.startDate, inquiry.endDate),
          note: noPeriod ? null : SrFormat.daysLabel(inquiry.days),
        )),
        capped(MetaItem(
          label: 'Budžet',
          value: inquiry.budget == null
              ? 'Nije naveden'
              : SrFormat.money(inquiry.budget, 'EUR'),
          emphasize: inquiry.budget != null,
        )),
        capped(MetaItem(
          label: 'Površine',
          value: count > 0
              ? SrFormat.count(count, 'površina', 'površine', 'površina')
              : (inquiry.isBrief ? 'Bira stručnjak' : 'Nema površina'),
        )),
      ],
    );
  }
}

/// Do četiri sličice izabranih površina (+N) i gradovi; za brif bez površina
/// ciljani gradovi iz brifa.
class _UnitStrip extends StatelessWidget {
  final Inquiry inquiry;

  const _UnitStrip({required this.inquiry});

  /// Brif bez površina i bez ciljanih gradova nema šta da prikaže.
  static bool hasContent(Inquiry inquiry) =>
      inquiry.items.isNotEmpty || inquiry.targetCityNames.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final units = inquiry.items.map((i) => i.summary).toList();
    if (units.isEmpty) {
      return Text(
        'Ciljani gradovi: ${inquiry.targetCityNames.join(', ')}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.bodySmall.copyWith(color: AppColors.text2),
      );
    }

    final shown = units.take(4).toList();
    final extra = units.length - shown.length;
    final cities = inquiry.unitCities;
    // Bez Wrap-a: u mreži od dve kolone visina se meri unapred (IntrinsicHeight),
    // a tekst u Expanded dobija pravu širinu i pri merenju.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < shown.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              UnitThumb(
                imageUrl: shown[i].imageUrl,
                digital: shown[i].isDigital,
                width: 52,
                height: 40,
                radius: 8,
              ),
            ],
            if (extra > 0) ...[
              const SizedBox(width: 6),
              Container(
                width: 52,
                height: 40,
                alignment: Alignment.center,
                decoration: AppDecorations.sunken(radius: 8),
                child: Text('+$extra',
                    style: AppTypography.labelLarge
                        .copyWith(color: AppColors.text2)),
              ),
            ],
          ],
        ),
        if (cities.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            cities.join(', '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.mutedForeground),
          ),
        ],
      ],
    );
  }
}

/// Dno kartice kada je ponuda stigla: samo dugme za pregled ponude.
class _OfferFooter extends StatelessWidget {
  final VoidCallback onPressed;

  const _OfferFooter({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderSoft)),
      ),
      alignment: Alignment.centerRight,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 38),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text('Pogledaj ponudu'),
      ),
    );
  }
}
