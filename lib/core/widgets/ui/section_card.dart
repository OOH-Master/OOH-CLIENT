import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_constants.dart';
import '../../theme/app_typography.dart';

/// Površine: bela kartica sa tankom ivicom, bez senke. Senka je samo za ono što
/// pluta iznad sadržaja (meniji, traka izbora).
class AppDecorations {
  AppDecorations._();

  static BoxDecoration card(
          {double radius = AppRadius.card,
          Color? color,
          bool shadow = false}) =>
      BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.border),
        boxShadow: shadow ? AppShadows.card : null,
      );

  static BoxDecoration sunken({double radius = AppRadius.sm}) => BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(radius),
      );
}

/// Sekcija stranice: bela kartica sa naslovom, opcionim podatkom ispod naslova
/// (npr. "4 površine") i akcijama desno.
class SectionCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;

  const SectionCard({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 10,
                    children: [
                      Text(title!,
                          style: AppTypography.labelLarge.copyWith(
                              fontSize: 15.5, color: AppColors.foreground)),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.mutedForeground),
                        ),
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 12), trailing!],
              ],
            ),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );

    return DecoratedBox(
      decoration: AppDecorations.card(color: color),
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.card),
                onTap: onTap,
                child: content,
              ),
            ),
    );
  }
}

/// Prazno stanje: tiha ikonica, naslov, jedna rečenica i akcija.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  final bool compact;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: 24, vertical: compact ? 20 : 48),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: compact ? 24 : 30, color: AppColors.subtle),
              SizedBox(height: compact ? 10 : 14),
              Text(title,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelLarge.copyWith(
                      fontSize: compact ? 14.5 : 15.5,
                      color: AppColors.foreground)),
              if (message != null) ...[
                const SizedBox(height: 4),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.mutedForeground),
                ),
              ],
              if (action != null) ...[const SizedBox(height: 16), action!],
            ],
          ),
        ),
      ),
    );
  }
}

/// Podatak: oznaka iznad vrednosti, bez ikonice. Parametar [icon] ostaje radi
/// postojećih poziva, ali se ne crta.
class MetaItem extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String value;
  final String? note;
  final Color? valueColor;
  final bool emphasize;

  const MetaItem({
    super.key,
    this.icon,
    required this.label,
    required this.value,
    this.note,
    this.valueColor,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: AppTypography.caption
                .copyWith(color: AppColors.mutedForeground)),
        const SizedBox(height: 2),
        Text(
          value,
          style: (emphasize
                  ? AppTypography.money.copyWith(fontSize: 15.5)
                  : AppTypography.bodyMedium
                      .copyWith(fontWeight: FontWeight.w500, fontSize: 14.5))
              .copyWith(color: valueColor ?? AppColors.foreground),
        ),
        if (note != null && note!.isNotEmpty)
          Text(note!,
              style: AppTypography.caption
                  .copyWith(color: AppColors.mutedForeground)),
      ],
    );
  }
}

/// Jedna brojka sa oznakom (deo [StatStrip] ili samostalno). Parametri [icon] i
/// [accent] ostaju radi postojećih poziva, ali se ne crtaju.
class KpiTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final String? hint;
  final Color accent;
  final VoidCallback? onTap;

  const KpiTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.hint,
    this.accent = AppColors.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: StatCell(label: label, value: value, note: hint),
    );
  }
}

/// Sadržaj jedne brojke: oznaka, vrednost (Space Grotesk) i tiha napomena.
class StatCell extends StatelessWidget {
  final String label;
  final String value;
  final String? note;

  const StatCell(
      {super.key, required this.label, required this.value, this.note});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.mutedForeground)),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value,
              style: AppTypography.money.copyWith(fontSize: 26, height: 1.1)),
        ),
        if (note != null && note!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            note!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption
                .copyWith(color: AppColors.mutedForeground),
          ),
        ],
      ],
    );
  }
}

/// Podatak za [StatStrip].
class StatItem {
  final String label;
  final String value;
  final String? note;
  final VoidCallback? onTap;

  const StatItem(this.label, this.value, {this.note, this.onTap});
}

/// Niz brojki u jednoj kartici, razdvojenih tankim linijama (umesto niza
/// zasebnih KPI kartica). Na uskom ekranu prelazi u dve kolone.
class StatStrip extends StatelessWidget {
  final List<StatItem> items;

  const StatStrip({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: AppDecorations.card(),
      child: LayoutBuilder(builder: (context, constraints) {
        final perRow = constraints.maxWidth >= 720
            ? items.length
            : (items.length > 2 ? 2 : items.length);
        final rows = <List<StatItem>>[];
        for (var i = 0; i < items.length; i += perRow) {
          rows.add(items.sublist(i, (i + perRow).clamp(0, items.length)));
        }
        Widget cell(StatItem it) {
          final c = Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: StatCell(label: it.label, value: it.value, note: it.note),
          );
          return it.onTap == null ? c : InkWell(onTap: it.onTap, child: c);
        }

        return Column(
          children: [
            for (var r = 0; r < rows.length; r++) ...[
              if (r > 0) const Divider(height: 1),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < perRow; i++) ...[
                      if (i > 0) const VerticalDivider(width: 1),
                      Expanded(
                        child: i < rows[r].length
                            ? cell(rows[r][i])
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}
