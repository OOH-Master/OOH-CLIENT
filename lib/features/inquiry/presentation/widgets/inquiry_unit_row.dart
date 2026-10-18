import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../domain/entities/unit_summary.dart';

/// Jedna oglasna površina u listi (UnitLine) sa desnim delom: cena ili polje za
/// cenu. Na uskoj kartici desni deo prelazi u red ispod, da naziv i oznake
/// ostanu čitljivi.
class InquiryUnitRow extends StatelessWidget {
  final UnitSummary unit;

  /// Desni deo; dobija `narrow = true` kada stoji ispod reda.
  final Widget Function(BuildContext context, bool narrow)? trailing;
  final Widget? leading;
  final VoidCallback? onTap;

  /// Ispod ove širine desni deo prelazi ispod reda.
  final double stackBelow;

  const InquiryUnitRow({
    super.key,
    required this.unit,
    this.trailing,
    this.leading,
    this.onTap,
    this.stackBelow = 540,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final narrow = constraints.maxWidth < stackBelow;
      final line = UnitLine(
        imageUrl: unit.imageUrl,
        digital: unit.isDigital,
        code: unit.codeLabel,
        title: unit.title,
        subtitle: unit.location,
        specs: unit.specs,
        leading: leading,
        compact: narrow,
        onTap: onTap,
        padding: EdgeInsets.only(
            top: 12, bottom: narrow && trailing != null ? 8 : 12),
        trailing:
            !narrow && trailing != null ? trailing!(context, false) : null,
      );
      if (!narrow || trailing == null) return line;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          line,
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: trailing!(context, true),
          ),
        ],
      );
    });
  }
}

/// Cena u desnom delu reda: iznos (tabelarne cifre) i kratko objašnjenje
/// ispod ("2 × 2 nedelje"), poravnati desno.
class PriceColumn extends StatelessWidget {
  final String amount;
  final String? caption;
  final String? footnote;
  final bool muted;
  final double fontSize;

  const PriceColumn({
    super.key,
    required this.amount,
    this.caption,
    this.footnote,
    this.muted = false,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    // U desnom delu reda širina nije ograničena; dugačak vlasnik ili opis ne sme
    // da suzi naziv površine.
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: _content(),
    );
  }

  Widget _content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          amount,
          textAlign: TextAlign.right,
          style: muted
              ? AppTypography.labelMedium
                  .copyWith(color: AppColors.mutedForeground)
              : AppTypography.money.copyWith(fontSize: fontSize),
        ),
        if (caption != null && caption!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            caption!,
            textAlign: TextAlign.right,
            style: AppTypography.caption
                .copyWith(color: AppColors.mutedForeground),
          ),
        ],
        if (footnote != null && footnote!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            footnote!,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(color: AppColors.subtle),
          ),
        ],
      ],
    );
  }
}

/// Zaglavlje grupe površina jednog vlasnika medija: avatar, naziv, broj
/// površina i zbir po valuti desno.
class OwnerGroupHeader extends StatelessWidget {
  final String name;
  final String countLabel;
  final List<String> totals;

  const OwnerGroupHeader({
    super.key,
    required this.name,
    required this.countLabel,
    this.totals = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppAvatar(name: name, size: 36),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.h6),
              Text(countLabel,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.mutedForeground)),
            ],
          ),
        ),
        if (totals.isNotEmpty) ...[
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final t in totals)
                Text(t, style: AppTypography.money.copyWith(fontSize: 15)),
            ],
          ),
        ],
      ],
    );
  }
}
