import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';

/// Ilustracije platforme koje prate početnu stranu.
class LandingAssets {
  LandingAssets._();

  static const ledSlavija = 'assets/images/led-slavija.jpg';
  static const cityLightKnez = 'assets/images/citylight-knez-mihailova.jpg';
  static const bilbordBrankov = 'assets/images/bilbord-brankov-most.jpg';
}

/// Sekcije do kojih vode veze u zaglavlju početne strane.
class LandingKeys {
  LandingKeys._();

  static final categories = GlobalKey(debugLabel: 'landing-categories');
  static final analytics = GlobalKey(debugLabel: 'landing-analytics');
  static final expert = GlobalKey(debugLabel: 'landing-expert');

  /// Pomeri stranu do sekcije; vraća `false` kada sekcija nije na ekranu
  /// (zaglavlje se koristi i na stranici pretrage).
  static bool scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return false;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeInOutCubic,
    );
    return true;
  }
}

/// Bočni razmak sadržaja početne strane.
double landingGutter(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  if (w >= 1200) return 48;
  if (w >= 600) return 32;
  return 16;
}

/// Sekcija početne strane: pozadina preko cele širine, sadržaj do 1240 px.
class LandingSection extends StatelessWidget {
  final Color color;
  final Widget child;
  final double? vertical;

  const LandingSection({
    super.key,
    required this.child,
    this.color = AppColors.surface,
    this.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final side = landingGutter(context);
    return ColoredBox(
      color: color,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: side, vertical: vertical ?? (wide ? 96 : 64)),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Naslov sekcije (Space Grotesk), opciono jedna rečenica ispod i akcija
/// desno.
class SectionHeading extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool center;
  final bool onDark;
  final Widget? trailing;

  const SectionHeading({
    super.key,
    required this.title,
    this.subtitle,
    this.center = false,
    this.onDark = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final align = center ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final textAlign = center ? TextAlign.center : TextAlign.start;

    final block = Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            title,
            textAlign: textAlign,
            style: (wide ? AppTypography.h1 : AppTypography.h3).copyWith(
              color: onDark ? Colors.white : AppColors.foreground,
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(
              subtitle!,
              textAlign: textAlign,
              style: AppTypography.bodyLarge.copyWith(
                color: onDark
                    ? AppColors.inkText.withValues(alpha: 0.78)
                    : AppColors.mutedForeground,
              ),
            ),
          ),
        ],
      ],
    );

    if (trailing == null || center) return block;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: block),
        if (wide) ...[const SizedBox(width: 24), trailing!],
      ],
    );
  }
}

/// Fotografija/ilustracija površine: ravna slika 16 : 9, blago zaobljena,
/// popunjava širinu koju dobije.
class LandingShot extends StatelessWidget {
  final String asset;
  final double radius;
  final double aspectRatio;

  const LandingShot({
    super.key,
    required this.asset,
    this.radius = AppRadius.sm,
    this.aspectRatio = 16 / 9,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Image.asset(asset, fit: BoxFit.cover),
      ),
    );
  }
}
