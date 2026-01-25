import 'package:flutter/material.dart';

/// App color palette - matching React web app design system
class AppColors {
  // Primary Color: Indigo (#6366F1)
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryForeground = Color(0xFFFFFFFF);
  
  // Background
  static const Color background = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF111827); // gray-900
  
  // Card
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF111827);
  
  // Popover
  static const Color popover = Color(0xFFFFFFFF);
  static const Color popoverForeground = Color(0xFF111827);
  
  // Secondary
  static const Color secondary = Color(0xFFF5F6FF); // indigo-50
  static const Color secondaryForeground = Color(0xFF111827);
  
  // Muted
  static const Color muted = Color(0xFFF9FAFB); // gray-50
  static const Color mutedForeground = Color(0xFF6B7280); // gray-500
  
  // Accent
  static const Color accent = Color(0xFFF5F6FF);
  static const Color accentForeground = Color(0xFF111827);
  
  // Destructive
  static const Color destructive = Color(0xFFEF4444); // red-500
  static const Color destructiveForeground = Color(0xFFFFFFFF);
  
  // Border & Input
  static const Color border = Color(0xFFE5E7EB); // gray-200
  static const Color input = Color(0xFFE5E7EB);
  static const Color ring = Color(0xFF6366F1);
  
  // Additional semantic colors
  static const Color success = Color(0xFF10B981); // green-500
  static const Color warning = Color(0xFFF59E0B); // yellow-500
  static const Color info = Color(0xFF3B82F6); // blue-500
  
  AppColors._();
}

/// Dark theme colors (for future dark mode)
class AppColorsDark {
  static const Color primary = Color(0xFF818CF8); // lighter indigo
  static const Color primaryForeground = Color(0xFF1F2937);
  
  static const Color background = Color(0xFF0F172A); // slate-900
  static const Color foreground = Color(0xFFF1F5F9); // slate-100
  
  static const Color card = Color(0xFF1E293B); // slate-800
  static const Color cardForeground = Color(0xFFF1F5F9);
  
  static const Color border = Color(0xFF334155); // slate-700
  
  AppColorsDark._();
}
