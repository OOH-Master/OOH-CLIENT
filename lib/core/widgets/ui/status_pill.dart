import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Ton oznake: boja teksta i blede podloge.
enum PillTone { neutral, primary, success, warning, danger, info, violet, dark }

extension PillToneColors on PillTone {
  Color get foreground {
    switch (this) {
      case PillTone.neutral:
        return AppColors.text2;
      case PillTone.primary:
        return AppColors.primaryStrong;
      case PillTone.success:
        return const Color(0xFF047857);
      case PillTone.warning:
        return const Color(0xFFB45309);
      case PillTone.danger:
        return const Color(0xFFB91C1C);
      case PillTone.info:
        return const Color(0xFF0369A1);
      case PillTone.violet:
        return const Color(0xFF6D28D9);
      case PillTone.dark:
        return Colors.white;
    }
  }

  Color get background {
    switch (this) {
      case PillTone.neutral:
        return AppColors.surfaceSunken;
      case PillTone.primary:
        return AppColors.primarySoft;
      case PillTone.success:
        return AppColors.successSoft;
      case PillTone.warning:
        return AppColors.warningSoft;
      case PillTone.danger:
        return AppColors.destructiveSoft;
      case PillTone.info:
        return AppColors.infoSoft;
      case PillTone.violet:
        return AppColors.violetSoft;
      case PillTone.dark:
        return AppColors.ink;
    }
  }

  /// Puna boja (tačka, ikonica, traka napretka).
  Color get solid {
    switch (this) {
      case PillTone.neutral:
        return AppColors.subtle;
      case PillTone.primary:
        return AppColors.primary;
      case PillTone.success:
        return AppColors.success;
      case PillTone.warning:
        return AppColors.warning;
      case PillTone.danger:
        return AppColors.destructive;
      case PillTone.info:
        return AppColors.info;
      case PillTone.violet:
        return AppColors.violet;
      case PillTone.dark:
        return AppColors.ink;
    }
  }
}

/// Oznaka statusa ili svojstva: blaga podloga u boji faze, bez ukrasa.
class StatusPill extends StatelessWidget {
  final String label;
  final PillTone tone;
  final IconData? icon;
  final bool dot;
  final bool dense;

  const StatusPill({
    super.key,
    required this.label,
    this.tone = PillTone.neutral,
    this.icon,
    this.dot = false,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = tone.foreground;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: dense ? 6 : 8, vertical: dense ? 2 : 3),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 13 : 14, color: fg),
            SizedBox(width: dense ? 4 : 5),
          ] else if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration:
                  BoxDecoration(color: tone.solid, shape: BoxShape.circle),
            ),
            SizedBox(width: dense ? 5 : 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(
                color: fg,
                fontSize: dense ? 11.5 : 12.5,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mala oznaka svojstva površine (tip, format, dimenzije), tiha siva podloga.
class SpecChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool onDark;

  const SpecChip(
      {super.key,
      required this.label,
      this.icon,
      this.color,
      this.onDark = false});

  @override
  Widget build(BuildContext context) {
    final fg = color ?? (onDark ? AppColors.inkText : AppColors.text2);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: onDark
            ? Colors.white.withValues(alpha: 0.08)
            : AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(color: fg, height: 1.25),
            ),
          ),
        ],
      ),
    );
  }
}
