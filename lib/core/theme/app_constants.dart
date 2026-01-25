import 'package:flutter/animation.dart';

/// Spacing constants - 8pt grid system
class AppSpacing {
  // Base unit (4pt)
  static const double xxxs = 2.0;
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
  static const double huge = 96.0;
  
  // Responsive spacing multipliers
  static const double mobileMultiplier = 1.0;
  static const double tabletMultiplier = 1.25;
  static const double desktopMultiplier = 1.5;
  
  AppSpacing._();
}

/// Border radius constants - matching React config
class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0; // DEFAULT: 1rem
  static const double lg = 24.0;
  static const double xl = 24.0; // 1.5rem
  static const double xxl = 32.0; // 2rem
  static const double xxxl = 40.0; // 2.5rem
  static const double full = 9999.0;
  
  AppRadius._();
}

/// Elevation/Shadow levels
class AppElevation {
  static const double xs = 1.0;
  static const double sm = 2.0;
  static const double md = 4.0;
  static const double lg = 8.0;
  static const double xl = 16.0;
  
  AppElevation._();
}

/// Animation durations
class AppDuration {
  static const Duration instant = Duration(milliseconds: 0);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slower = Duration(milliseconds: 700);
  
  AppDuration._();
}

/// Animation curves
class AppCurves {
  static const cubic = Cubic(0.25, 0.1, 0.25, 1.0);
  static const easeInOut = Cubic(0.42, 0.0, 0.58, 1.0);
  static const easeOut = Cubic(0.0, 0.0, 0.58, 1.0);
  static const easeIn = Cubic(0.42, 0.0, 1.0, 1.0);
  
  AppCurves._();
}
