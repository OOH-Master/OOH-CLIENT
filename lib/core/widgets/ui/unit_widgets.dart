import 'package:flutter/material.dart';

import '../../config/api_config.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'status_pill.dart';

/// Sličica oglasne površine. Bez slike crta tamnu "noćnu" pozadinu sa ikonicom
/// panela (digitalne površine dobijaju topao, ćilibarni sjaj).
class UnitThumb extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final double radius;
  final bool digital;

  const UnitThumb({
    super.key,
    required this.imageUrl,
    this.width = 72,
    this.height = 54,
    this.radius = 6,
    this.digital = false,
  });

  static String? resolve(String? url) {
    if (url == null || url.isEmpty) return null;
    final ownOrRemote = url.startsWith('/') || url.startsWith('http');
    return ownOrRemote ? ApiConfig.absoluteUrl(url) : null;
  }

  @override
  Widget build(BuildContext context) {
    final src = resolve(imageUrl);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: src == null
            ? _placeholder()
            : Image.network(
                src,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
                frameBuilder: (context, child, frame, sync) =>
                    frame == null && !sync ? _placeholder() : child,
              ),
      ),
    );
  }

  Widget _placeholder() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: digital
              ? const [Color(0xFF2A1F4B), Color(0xFF6B2D5C)]
              : const [AppColors.inkRaised, Color(0xFF2D3470)],
        ),
      ),
      child: Center(
        child: Icon(
          digital ? Icons.smart_display_outlined : Icons.crop_landscape_rounded,
          size: (height * 0.42).clamp(14, 40),
          color: digital ? const Color(0xFFFBBF77) : AppColors.primaryTint,
        ),
      ),
    );
  }
}

/// Red jedne oglasne površine: sličica, šifra, naziv, mesto, svojstva i desni deo
/// (cena, polje za cenu ili akcija). Koristi se u ponudi, zahtevu vlasnika,
/// detalju upita i dodeli površina.
class UnitLine extends StatelessWidget {
  final String? imageUrl;
  final bool digital;
  final String? code;
  final String title;
  final String? subtitle;
  final List<String> specs;
  final Widget? trailing;
  final Widget? leading;
  final EdgeInsetsGeometry padding;
  final bool compact;
  final VoidCallback? onTap;

  const UnitLine({
    super.key,
    this.imageUrl,
    this.digital = false,
    this.code,
    required this.title,
    this.subtitle,
    this.specs = const [],
    this.trailing,
    this.leading,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final thumbW = compact ? 64.0 : 88.0;
    final thumbH = compact ? 48.0 : 64.0;

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (code != null && code!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSunken,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  code!,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.text2,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelLarge
                    .copyWith(fontSize: compact ? 14 : 15),
              ),
            ),
          ],
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.mutedForeground),
          ),
        ],
        if (specs.isNotEmpty) ...[
          const SizedBox(height: 7),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in specs.where((s) => s.isNotEmpty))
                SpecChip(label: s)
            ],
          ),
        ],
      ],
    );

    final row = Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 10)],
          UnitThumb(
              imageUrl: imageUrl,
              width: thumbW,
              height: thumbH,
              digital: digital),
          const SizedBox(width: 14),
          Expanded(child: info),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );

    if (onTap == null) return row;
    return InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(12), child: row);
  }
}

/// Krug sa inicijalima (korisnik, brend, vlasnik medija).
class AppAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color? color;

  const AppAvatar({super.key, required this.name, this.size = 36, this.color});

  static const _palette = [
    Color(0xFF3B3F6B),
    Color(0xFF2F5D62),
    Color(0xFF5B4B7A),
    Color(0xFF7A5C3A),
    Color(0xFF3F6B4F),
    Color(0xFF6B3F55),
  ];

  String get _initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts[1].characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bg = color ??
        _palette[
            name.codeUnits.fold<int>(0, (a, b) => a + b) % _palette.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(size * 0.22)),
      child: Text(
        _initials,
        style: AppTypography.labelLarge
            .copyWith(color: Colors.white, fontSize: size * 0.36, height: 1),
      ),
    );
  }
}

/// Znak platforme: ravna indigo tabla u razmeri bilborda sa "OOH" i reč
/// "Platforma". Bez prelaza boja i sjaja.
class BrandMark extends StatelessWidget {
  final bool onDark;
  final bool compact;
  final double size;

  const BrandMark(
      {super.key, this.onDark = false, this.compact = false, this.size = 34});

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      width: size * 1.42,
      height: size * 0.9,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        'OOH',
        style: AppTypography.money.copyWith(
            color: Colors.white,
            fontSize: size * 0.4,
            letterSpacing: 0.4,
            height: 1),
      ),
    );
    if (compact) return panel;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        panel,
        const SizedBox(width: 9),
        Text(
          'Platforma',
          style: AppTypography.h5.copyWith(
            color: onDark ? Colors.white : AppColors.foreground,
            fontSize: size * 0.54,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
