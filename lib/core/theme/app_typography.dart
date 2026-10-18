import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Tipografija: Space Grotesk za naslove, brojeve i cene, IBM Plex Sans za tekst
/// i podatke (čitljiv i u gustim listama). Isti par fontova koristi prezentacija.
///
/// Fontovi su ugrađeni u `google_fonts/`, pa se ne preuzimaju u toku rada.
class AppTypography {
  // Font family
  static TextStyle get baseTextStyle => GoogleFonts.ibmPlexSans(
        color: AppColors.foreground,
      );

  static TextStyle get _display => GoogleFonts.spaceGrotesk(
        color: AppColors.foreground,
      );

  /// Cene, iznosi i KPI vrednosti: Space Grotesk sa ciframa iste širine.
  static TextStyle get money => _display.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.2,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  // Display styles (for hero sections)
  static TextStyle get displayLarge => _display.copyWith(
        fontSize: 64,
        fontWeight: FontWeight.w700,
        height: 1.04,
        letterSpacing: -1.6,
      );

  static TextStyle get displayMedium => _display.copyWith(
        fontSize: 52,
        fontWeight: FontWeight.w700,
        height: 1.06,
        letterSpacing: -1.2,
      );

  static TextStyle get displaySmall => _display.copyWith(
        fontSize: 42,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -0.8,
      );

  // Headings
  static TextStyle get h1 => _display.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.6,
      );

  static TextStyle get h2 => _display.copyWith(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.4,
      );

  static TextStyle get h3 => _display.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.3,
      );

  static TextStyle get h4 => _display.copyWith(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.2,
      );

  static TextStyle get h5 => _display.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.35,
        letterSpacing: -0.1,
      );

  static TextStyle get h6 => _display.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.35,
      );

  // Body text
  static TextStyle get bodyLarge => baseTextStyle.copyWith(
        fontSize: 16.5,
        fontWeight: FontWeight.w400,
        height: 1.55,
      );

  static TextStyle get bodyMedium => baseTextStyle.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodySmall => baseTextStyle.copyWith(
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        height: 1.45,
      );

  // Lead text (for important paragraphs)
  static TextStyle get lead => baseTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.55,
      );

  // Labels & UI text
  static TextStyle get labelLarge => baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.35,
      );

  static TextStyle get labelMedium => baseTextStyle.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.35,
      );

  static TextStyle get labelSmall => baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.35,
      );

  // Button text
  static TextStyle get button => baseTextStyle.copyWith(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );

  // Captions & small text
  static TextStyle get caption => baseTextStyle.copyWith(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  static TextStyle get overline => baseTextStyle.copyWith(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.4,
      );

  AppTypography._();
}
