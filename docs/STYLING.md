# Styling & Design System

## Overview

OOH Mobile uses a comprehensive design system built on Material Design 3 principles with custom branding. The theme system is located in `lib/core/theme/` and provides a consistent visual language across all platforms.

## Theme Architecture

### Theme Files Structure

```
lib/core/theme/
├── app_theme.dart          # Main theme configuration
├── app_colors.dart         # Color palette
├── app_typography.dart     # Text styles
└── app_constants.dart      # Spacing, radius, elevation
```

## Colors

### Color Palette

Defined in `lib/core/theme/app_colors.dart`:

#### Primary Colors
```dart
static const Color primary = Color(0xFF6366F1);           // Indigo-600
static const Color primaryForeground = Color(0xFFFFFFFF); // White
```
- **Usage**: Primary actions, links, focused states
- **Examples**: Buttons, active navigation, CTA elements

#### Background Colors
```dart
static const Color background = Color(0xFFFFFFFF);        // White
static const Color foreground = Color(0xFF111827);        // Gray-900
```
- **Usage**: Main app background and primary text
- **Contrast Ratio**: 16.37:1 (WCAG AAA)

#### Card Colors
```dart
static const Color card = Color(0xFFFFFFFF);              // White
static const Color cardForeground = Color(0xFF111827);    // Gray-900
```
- **Usage**: Elevated containers, cards
- **Border**: 1px solid border (Color: 0xFFE5E7EB)

#### Secondary Colors
```dart
static const Color secondary = Color(0xFFF5F6FF);         // Indigo-50
static const Color secondaryForeground = Color(0xFF111827);
```
- **Usage**: Secondary buttons, subtle backgrounds

#### Muted Colors
```dart
static const Color muted = Color(0xFFF9FAFB);             // Gray-50
static const Color mutedForeground = Color(0xFF6B7280);   // Gray-500
```
- **Usage**: Disabled states, placeholders, secondary text

#### Accent Colors
```dart
static const Color accent = Color(0xFFF5F6FF);            // Indigo-50
static const Color accentForeground = Color(0xFF111827);
```
- **Usage**: Highlights, badges, notifications

#### Semantic Colors
```dart
static const Color destructive = Color(0xFFEF4444);       // Red-500
static const Color success = Color(0xFF10B981);           // Green-500
static const Color warning = Color(0xFFF59E0B);           // Yellow-500
static const Color info = Color(0xFF3B82F6);              // Blue-500
```
- **Usage**: Status indicators, alerts, toasts

#### Border & Input
```dart
static const Color border = Color(0xFFE5E7EB);            // Gray-200
static const Color input = Color(0xFFE5E7EB);             // Gray-200
static const Color ring = Color(0xFF6366F1);              // Indigo-600
```
- **Usage**: Input borders, dividers, focus rings

### Dark Theme Colors

```dart
class AppColorsDark {
  static const Color primary = Color(0xFF818CF8);         // Lighter Indigo
  static const Color background = Color(0xFF0F172A);      // Slate-900
  static const Color foreground = Color(0xFFF1F5F9);      // Slate-100
  static const Color card = Color(0xFF1E293B);            // Slate-800
  static const Color border = Color(0xFF334155);          // Slate-700
}
```

## Typography

### Font Family

**Space Grotesk** - Modern, geometric sans-serif font

```dart
static const String fontFamily = 'Space Grotesk';
```

Configured in `pubspec.yaml` using Google Fonts:
```yaml
dependencies:
  google_fonts: ^6.2.1
```

### Text Styles

Defined in `lib/core/theme/app_typography.dart`:

#### Display Styles
```dart
// Display Large - 72px/80px, weight: 800
static final TextStyle displayLarge = GoogleFonts.spaceGrotesk(
  fontSize: 72,
  height: 1.111,
  fontWeight: FontWeight.w800,
  letterSpacing: -0.02,
);

// Display Medium - 60px/68px, weight: 800
// Display Small - 48px/56px, weight: 700
```

**Usage**: Hero headings, landing page titles

#### Heading Styles
```dart
// H1 - 40px/48px, weight: 700
// H2 - 32px/40px, weight: 700
// H3 - 28px/36px, weight: 600
// H4 - 24px/32px, weight: 600
// H5 - 20px/28px, weight: 600
// H6 - 18px/26px, weight: 600
```

**Usage**: Page titles, section headers, card titles

#### Body Styles
```dart
// Body Large - 18px/28px, weight: 400
// Body Medium - 16px/24px, weight: 400
// Body Small - 14px/20px, weight: 400
```

**Usage**: Paragraphs, descriptions, general content

#### Label Styles
```dart
// Label Large - 16px/24px, weight: 500
// Label Medium - 14px/20px, weight: 500
// Label Small - 12px/16px, weight: 500
```

**Usage**: Form labels, button text, captions

#### Button Style
```dart
// Button - 16px/24px, weight: 600
```

**Usage**: All button text

### Text Usage Examples

```dart
// Hero Heading
Text(
  'Find Perfect OOH Spaces',
  style: AppTypography.displayMedium.copyWith(
    color: Colors.white,
  ),
)

// Section Title
Text(
  'Featured Categories',
  style: AppTypography.h2,
)

// Body Text
Text(
  'Browse thousands of advertising spaces...',
  style: AppTypography.bodyLarge.copyWith(
    color: AppColors.mutedForeground,
  ),
)

// Button Text
Text(
  'Get Started',
  style: AppTypography.button,
)
```

## Spacing System

### Spacing Scale

Defined in `lib/core/theme/app_constants.dart`:

```dart
class AppSpacing {
  static const double xs = 4.0;    // Extra small
  static const double sm = 8.0;    // Small
  static const double md = 16.0;   // Medium (base)
  static const double lg = 24.0;   // Large
  static const double xl = 32.0;   // Extra large
  static const double xl2 = 48.0;  // 2XL
  static const double xl3 = 64.0;  // 3XL
  static const double xl4 = 96.0;  // 4XL
}
```

### Spacing Usage

```dart
// Padding
Padding(
  padding: EdgeInsets.all(AppSpacing.md),  // 16px
  child: child,
)

// Symmetric spacing
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,  // 24px
    vertical: AppSpacing.md,    // 16px
  ),
)

// Gap between widgets
Column(
  children: [
    Widget1(),
    SizedBox(height: AppSpacing.sm),  // 8px gap
    Widget2(),
  ],
)
```

## Border Radius

### Radius Scale

```dart
class AppRadius {
  static const double sm = 4.0;     // Small corners
  static const double md = 8.0;     // Medium (buttons, inputs)
  static const double lg = 12.0;    // Large (cards)
  static const double xl = 16.0;    // Extra large (modals)
  static const double xl2 = 24.0;   // 2XL (large cards)
  static const double full = 9999;  // Fully rounded (pills)
}
```

### Radius Usage

```dart
// Card with rounded corners
Container(
  decoration: BoxDecoration(
    color: AppColors.card,
    borderRadius: BorderRadius.circular(AppRadius.lg),  // 12px
  ),
)

// Pill-shaped button
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppRadius.full),  // Fully rounded
  ),
)

// Different corner radii
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(AppRadius.xl),
      topRight: Radius.circular(AppRadius.xl),
    ),
  ),
)
```

## Elevation

### Elevation Scale

```dart
class AppElevation {
  static const double sm = 2;   // Subtle lift
  static const double md = 4;   // Default
  static const double lg = 12;  // Prominent (dialogs)
}
```

### Shadow Usage

```dart
// Card shadow
Container(
  decoration: BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  ),
)

// Using Material elevation
Material(
  elevation: AppElevation.md,  // 4dp
  child: child,
)
```

## Responsive Design

### Breakpoints

```dart
class Breakpoints {
  static const double mobile = 600;       // 0-599px
  static const double tablet = 900;       // 600-899px
  static const double desktop = 1200;     // 900-1199px
  static const double largeDesktop = 1536; // 1200px+
}
```

### Responsive Layout Example

```dart
// Extension metode (iz responsive_builder.dart)
if (context.isDesktop) {
  // >= 900px (tablet threshold)
  return DesktopLayout();
} else {
  return MobileLayout();
}

// ResponsiveBuilder widget
ResponsiveBuilder(
  builder: (context, deviceType) {
    switch (deviceType) {
      case DeviceType.mobile: return MobileLayout();
      case DeviceType.tablet: return TabletLayout();
      case DeviceType.desktop: return DesktopLayout();
      case DeviceType.largeDesktop: return WideLayout();
    }
  },
)
```

### Responsive Spacing

```dart
// Adaptive padding based on screen size
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: context.isMobile
        ? AppSpacing.md
        : AppSpacing.xl,
  ),
)
```

### Responsive Grid

```dart
// Responsive columns
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: _getCrossAxisCount(context),
    crossAxisSpacing: AppSpacing.md,
    mainAxisSpacing: AppSpacing.md,
  ),
)

int _getCrossAxisCount(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < Breakpoints.mobile) return 1;    // < 600
  if (width < Breakpoints.tablet) return 2;    // < 900
  if (width < Breakpoints.desktop) return 3;   // < 1200
  return 4;
}
```

## Component Themes

### Input Fields

```dart
inputDecorationTheme: InputDecorationTheme(
  filled: true,
  fillColor: Colors.white,
  contentPadding: EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.md,
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
    borderSide: BorderSide(color: AppColors.input),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
    borderSide: BorderSide(color: AppColors.ring, width: 2),
  ),
),
```

### Buttons

#### Elevated Button
```dart
ElevatedButton(
  onPressed: () {},
  child: Text('Primary Action'),
  // Theme automatically applied from AppTheme
)
```

#### Outlined Button
```dart
OutlinedButton(
  onPressed: () {},
  child: Text('Secondary Action'),
)
```

#### Text Button
```dart
TextButton(
  onPressed: () {},
  child: Text('Tertiary Action'),
)
```

### Cards

```dart
Card(
  // Theme automatically applied
  child: Padding(
    padding: EdgeInsets.all(AppSpacing.md),
    child: content,
  ),
)
```

### Dropdown Menus

```dart
DropdownButton<String>(
  dropdownColor: Colors.white,
  style: AppTypography.bodyMedium.copyWith(
    color: AppColors.foreground,
  ),
  items: items.map((item) {
    return DropdownMenuItem(
      value: item,
      child: Text(
        item,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.foreground,
        ),
      ),
    );
  }).toList(),
  onChanged: (value) {},
)
```

## Animations

### Duration Constants

```dart
class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}
```

### Curves

```dart
class AppCurves {
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
}
```

### Animation Example

```dart
AnimatedContainer(
  duration: AppDurations.normal,
  curve: AppCurves.easeInOut,
  decoration: BoxDecoration(
    color: isHovered ? AppColors.accent : AppColors.card,
  ),
)
```

## Best Practices

### 1. Use Theme Constants
❌ **Don't**:
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Color(0xFF6366F1),
    borderRadius: BorderRadius.circular(8),
  ),
)
```

✅ **Do**:
```dart
Container(
  padding: EdgeInsets.all(AppSpacing.md),
  decoration: BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(AppRadius.md),
  ),
)
```

### 2. Responsive Design
❌ **Don't**:
```dart
Container(width: 300)
```

✅ **Do**:
```dart
Container(
  width: MediaQuery.of(context).size.width * 0.8,
  constraints: BoxConstraints(maxWidth: 400),
)
```

### 3. Text Styling
❌ **Don't**:
```dart
Text(
  'Title',
  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
)
```

✅ **Do**:
```dart
Text('Title', style: AppTypography.h4)
```

### 4. Consistent Spacing
❌ **Don't**:
```dart
SizedBox(height: 20)
```

✅ **Do**:
```dart
SizedBox(height: AppSpacing.lg)
```

### 5. Color Usage
❌ **Don't**:
```dart
Text('Error', style: TextStyle(color: Colors.red))
```

✅ **Do**:
```dart
Text('Error', style: TextStyle(color: AppColors.destructive))
```

## Accessibility

### Color Contrast
- All text meets WCAG AA standards (4.5:1 minimum)
- Important elements meet WCAG AAA standards (7:1 minimum)

### Touch Targets
- Minimum touch target size: 44x44 logical pixels
- Spacing between touch targets: 8px minimum

### Text Scaling
- Support system font scaling up to 200%
- Use `MediaQuery.textScaleFactorOf(context)` for adjustments

```dart
Text(
  'Scalable Text',
  style: AppTypography.bodyMedium.copyWith(
    fontSize: 16 * MediaQuery.textScaleFactorOf(context).clamp(1.0, 1.5),
  ),
)
```

---

**Maintained by**: Design System Team  
**Last Updated**: January 2026
