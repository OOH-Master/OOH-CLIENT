import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../favorite/presentation/blocs/favorite_bloc.dart';
import '../../domain/entities/ooh_unit.dart';
import 'unit_labels.dart';

/// Oznaka tipa preko fotografije: "Digitalna" ćilibarno, "Statična" belo.
class UnitTypeBadge extends StatelessWidget {
  final OohUnit unit;
  final bool dense;

  const UnitTypeBadge({super.key, required this.unit, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final label = unit.typeLabel;
    if (label.isEmpty) return const SizedBox.shrink();
    final digital = unit.isDigitalUnit;
    // Ćilibarna samo za digitalne površine; tamniji ton zbog čitljivosti.
    final fg = digital ? PillTone.warning.foreground : AppColors.foreground;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: dense ? 6 : 8, vertical: dense ? 2 : 3),
      decoration: BoxDecoration(
        color: digital
            ? AppColors.warningSoft
            : Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: dense ? 11 : 11.5,
          height: 1.2,
        ),
      ),
    );
  }
}

/// Šifra površine u sivoj pločici, cifre iste širine.
class UnitCodeChip extends StatelessWidget {
  final String code;

  const UnitCodeChip({super.key, required this.code});

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
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.text2,
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// Šifra i naziv u jednom redu.
class UnitTitleRow extends StatelessWidget {
  final OohUnit unit;
  final TextStyle? style;

  const UnitTitleRow({super.key, required this.unit, this.style});

  @override
  Widget build(BuildContext context) {
    final code = unit.code;
    return Row(
      children: [
        if (code != null && code.isNotEmpty && code != unit.title) ...[
          UnitCodeChip(code: code),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            unit.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style ??
                AppTypography.labelLarge
                    .copyWith(fontSize: 15, color: AppColors.foreground),
          ),
        ),
      ],
    );
  }
}

/// Mesto: "Beograd, Srbija".
class UnitPlaceLine extends StatelessWidget {
  final String text;
  final Color? color;

  const UnitPlaceLine({super.key, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.bodySmall
          .copyWith(color: color ?? AppColors.mutedForeground),
    );
  }
}

/// Cena sa ciklusom: "200 €" krupno i "/ 4 nedelje" prigušeno, u jednom redu.
/// Kada red ne stane (npr. "3.519.000 RSD"), ciklus prelazi u drugi red.
class UnitPriceText extends StatelessWidget {
  final OohUnit unit;
  final double fontSize;

  /// Poravnanje kada je cena desno (red liste).
  final CrossAxisAlignment alignment;

  const UnitPriceText({
    super.key,
    required this.unit,
    this.fontSize = 17,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final amountStyle = unit.hasPrice
        ? AppTypography.money.copyWith(fontSize: fontSize)
        : AppTypography.labelLarge
            .copyWith(color: AppColors.text2, fontSize: fontSize - 3);
    final cycle = unit.hasPrice ? unit.cycleText : '';
    final cycleStyle = AppTypography.caption.copyWith(
      color: AppColors.mutedForeground,
      fontSize: (fontSize * 0.74).clamp(11.5, 15).toDouble(),
    );
    final end = alignment == CrossAxisAlignment.end;
    final amount = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: end ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(unit.priceAmount, style: amountStyle, maxLines: 1),
    );
    if (cycle.isEmpty) return amount;

    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(children: [
          TextSpan(text: unit.priceAmount, style: amountStyle),
          TextSpan(text: '  / $cycle', style: cycleStyle),
        ]);
        final painter = TextPainter(
          text: span,
          maxLines: 1,
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.textScalerOf(context),
        )..layout();
        final fits = painter.width <= constraints.maxWidth;
        painter.dispose();
        if (fits) {
          // FittedBox čuva red i kada se font učita posle merenja.
          return FittedBox(
            fit: BoxFit.scaleDown,
            alignment: end ? Alignment.centerRight : Alignment.centerLeft,
            child: Text.rich(span, maxLines: 1),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: alignment,
          children: [
            amount,
            Text('/ $cycle',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: cycleStyle),
          ],
        );
      },
    );
  }
}

/// Okruglo dugme preko fotografije (korpa, omiljeno).
class RoundOverlayButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool active;
  final double size;
  final Color? activeIconColor;
  final Color? activeBackground;

  const RoundOverlayButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.active = false,
    this.size = 34,
    this.activeIconColor,
    this.activeBackground,
  });

  @override
  Widget build(BuildContext context) {
    final bg = active
        ? (activeBackground ?? AppColors.primary)
        : Colors.white.withValues(alpha: 0.96);
    final fg =
        active ? (activeIconColor ?? Colors.white) : AppColors.foreground;
    final ring = active && activeBackground == null;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: bg,
        shape: CircleBorder(
          side: ring
              ? const BorderSide(color: Colors.white, width: 1.5)
              : BorderSide.none,
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: size * 0.5, color: fg),
          ),
        ),
      ),
    );
  }
}

/// Korpa na kartici: dodaje površinu u upit, a izabrana postaje indigo sa
/// kvačicom.
class InquiryBasketButton extends StatelessWidget {
  final bool selected;
  final VoidCallback? onTap;
  final double size;

  const InquiryBasketButton(
      {super.key, required this.selected, this.onTap, this.size = 34});

  @override
  Widget build(BuildContext context) {
    return RoundOverlayButton(
      icon: selected ? Icons.check_rounded : Icons.shopping_basket_outlined,
      tooltip: selected ? 'Ukloni iz upita' : 'Dodaj u upit',
      onTap: onTap,
      active: selected,
      size: size,
    );
  }
}

/// Srce za omiljene površine; vidi ga samo prijavljen korisnik.
class UnitFavoriteButton extends StatelessWidget {
  final OohUnit unit;
  final double size;

  /// Na beloj podlozi (detalj) umesto preko fotografije.
  final bool onSurface;

  const UnitFavoriteButton(
      {super.key, required this.unit, this.size = 34, this.onSurface = false});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();

    final favoriteState = context.watch<FavoriteBloc>().state;
    final id = unit.intId;
    final favorited = (id != null && favoriteState is FavoritesLoaded)
        ? favoriteState.favoritedIds.contains(id)
        : unit.favorited;

    void toggle() {
      if (id == null) return;
      context.read<FavoriteBloc>().add(ToggleFavorite(id));
    }

    final tooltip = favorited ? 'Ukloni iz omiljenih' : 'Sačuvaj u omiljene';
    if (onSurface) {
      return IconButton(
        tooltip: tooltip,
        onPressed: toggle,
        style: IconButton.styleFrom(
          backgroundColor:
              favorited ? AppColors.primarySoft : AppColors.surfaceSunken,
          fixedSize: Size(size, size),
          minimumSize: Size(size, size),
          padding: EdgeInsets.zero,
        ),
        icon: Icon(
          favorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: size * 0.52,
          color: favorited ? AppColors.primary : AppColors.text2,
        ),
      );
    }
    return RoundOverlayButton(
      icon: favorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
      tooltip: tooltip,
      onTap: toggle,
      active: favorited,
      size: size,
      activeBackground: Colors.white.withValues(alpha: 0.96),
      activeIconColor: AppColors.primary,
    );
  }
}
