import 'package:flutter/material.dart';

/// Paleta aplikacije, ista kao u prezentaciji platforme: noćna tamnoplava
/// (meni, zaglavlja), svetla podloga sa belim karticama i indigo kao boja akcije.
///
/// Stara imena (primary, foreground, mutedForeground, border...) ostaju jer ih
/// koriste svi ekrani; nova imena (ink*, *Soft, text2...) služe redizajnu.
class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF4F46E5); // indigo
  static const Color primaryForeground = Color(0xFFFFFFFF);
  static const Color primaryStrong = Color(0xFF3730A3);
  static const Color primarySoft = Color(0xFFECEBFD);
  static const Color primaryTint =
      Color(0xFFA5B4FC); // indigo na tamnoj podlozi

  // ── Noć (meni, hero, tamni paneli) ───────────────────────────────────────
  static const Color ink = Color(0xFF0F1226);
  static const Color inkRaised = Color(0xFF1C2042);
  static const Color inkLine = Color(0xFF2A2E4B);
  static const Color inkMuted = Color(0xFF8E93B5);
  static const Color inkText = Color(0xFFE8E9F5);

  // ── Podloga i površine ─────────────────────────────────────────────────
  static const Color background = Color(0xFFF5F6FA); // platno ekrana
  static const Color surface = Color(0xFFFFFFFF); // kartice
  static const Color surfaceSunken =
      Color(0xFFF0F1F7); // uvučene zone, zaglavlja tabela
  static const Color foreground = Color(0xFF15172B);
  static const Color text2 = Color(0xFF393E56);

  // Card
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF15172B);

  // Popover
  static const Color popover = Color(0xFFFFFFFF);
  static const Color popoverForeground = Color(0xFF15172B);

  // Secondary
  static const Color secondary = Color(0xFFECEBFD);
  static const Color secondaryForeground = Color(0xFF3730A3);

  // Muted
  static const Color muted = Color(0xFFF0F1F7);
  static const Color mutedForeground = Color(0xFF666B86);
  static const Color subtle = Color(0xFF8A8FA8);

  // Accent
  static const Color accent = Color(0xFFECEBFD);
  static const Color accentForeground = Color(0xFF3730A3);

  // Destructive
  static const Color destructive = Color(0xFFDC2626);
  static const Color destructiveForeground = Color(0xFFFFFFFF);
  static const Color destructiveSoft = Color(0xFFFCE9E9);

  // Border & Input
  static const Color border = Color(0xFFE2E4EE);
  static const Color borderSoft = Color(0xFFECEEF5);
  static const Color input = Color(0xFFD9DCE8);
  static const Color ring = Color(0xFF4F46E5);

  // ── Semantika ──────────────────────────────────────────────────────────
  static const Color success = Color(0xFF059669);
  static const Color successSoft = Color(0xFFE3F5EC);
  static const Color warning =
      Color(0xFFD97706); // i oznaka digitalnih površina
  static const Color warningSoft = Color(0xFFFDF1E1);
  static const Color info = Color(0xFF0284C7);
  static const Color infoSoft = Color(0xFFE3F1FA);
  static const Color violet = Color(0xFF7C3AED);
  static const Color violetSoft = Color(0xFFF0E9FD);

  AppColors._();
}

/// Dark theme colors (for future dark mode)
class AppColorsDark {
  static const Color primary = Color(0xFF818CF8); // lighter indigo
  static const Color primaryForeground = Color(0xFF1F2937);

  static const Color background = Color(0xFF0F1226);
  static const Color foreground = Color(0xFFF1F5F9);

  static const Color card = Color(0xFF1C2042);
  static const Color cardForeground = Color(0xFFF1F5F9);

  static const Color border = Color(0xFF2A2E4B);

  AppColorsDark._();
}
