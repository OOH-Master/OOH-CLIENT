import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system - using Space Grotesk like React web app
class AppTypography {
  // Font family
  static TextStyle get baseTextStyle => GoogleFonts.spaceGrotesk();
  
  // Display styles (for hero sections)
  static TextStyle get displayLarge => baseTextStyle.copyWith(
    fontSize: 72,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.02,
  );
  
  static TextStyle get displayMedium => baseTextStyle.copyWith(
    fontSize: 60,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.02,
  );
  
  static TextStyle get displaySmall => baseTextStyle.copyWith(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.01,
  );
  
  // Headings
  static TextStyle get h1 => baseTextStyle.copyWith(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  
  static TextStyle get h2 => baseTextStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );
  
  static TextStyle get h3 => baseTextStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  static TextStyle get h4 => baseTextStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  static TextStyle get h5 => baseTextStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  static TextStyle get h6 => baseTextStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  // Body text
  static TextStyle get bodyLarge => baseTextStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );
  
  static TextStyle get bodyMedium => baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );
  
  static TextStyle get bodySmall => baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  // Lead text (for important paragraphs)
  static TextStyle get lead => baseTextStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );
  
  // Labels & UI text
  static TextStyle get labelLarge => baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  
  static TextStyle get labelMedium => baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  
  static TextStyle get labelSmall => baseTextStyle.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  
  // Button text
  static TextStyle get button => baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.01,
  );
  
  // Captions & small text
  static TextStyle get caption => baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  
  static TextStyle get overline => baseTextStyle.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
  );
  
  AppTypography._();
}
