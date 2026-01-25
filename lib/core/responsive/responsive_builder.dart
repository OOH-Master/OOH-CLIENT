import 'package:flutter/widgets.dart';
import 'breakpoints.dart';

/// Responsive builder widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;
  
  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });
  
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final deviceType = DeviceType.fromWidth(width);
    
    return builder(context, deviceType);
  }
}

/// Responsive layout widget with separate widgets for each device type
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;
  
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });
  
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        switch (deviceType) {
          case DeviceType.mobile:
            return mobile;
          case DeviceType.tablet:
            return tablet ?? mobile;
          case DeviceType.desktop:
            return desktop ?? tablet ?? mobile;
          case DeviceType.largeDesktop:
            return largeDesktop ?? desktop ?? tablet ?? mobile;
        }
      },
    );
  }
}

/// Extension on BuildContext for responsive utilities
extension ResponsiveContext on BuildContext {
  /// Get current device type
  DeviceType get deviceType {
    final width = MediaQuery.of(this).size.width;
    return DeviceType.fromWidth(width);
  }
  
  /// Check if current device is mobile
  bool get isMobile => deviceType == DeviceType.mobile;
  
  /// Check if current device is tablet
  bool get isTablet => deviceType == DeviceType.tablet;
  
  /// Check if current device is desktop
  bool get isDesktop => 
      deviceType == DeviceType.desktop || 
      deviceType == DeviceType.largeDesktop;
  
  /// Get responsive value
  T responsive<T>(ResponsiveValue<T> value) {
    return value.getValue(deviceType);
  }
  
  /// Get responsive padding
  EdgeInsets get responsivePadding {
    return EdgeInsets.symmetric(
      horizontal: responsive(
        const ResponsiveValue(
          mobile: 16,
          tablet: 24,
          desktop: 32,
          largeDesktop: 48,
        ),
      ),
    );
  }
  
  /// Get max content width based on device
  double get maxContentWidth {
    return responsive(
      const ResponsiveValue(
        mobile: double.infinity,
        tablet: 768,
        desktop: 1200,
        largeDesktop: 1400,
      ),
    );
  }
}
