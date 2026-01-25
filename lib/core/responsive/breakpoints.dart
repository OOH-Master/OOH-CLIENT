/// Responsive breakpoints for different screen sizes
class Breakpoints {
  // Mobile (phones in portrait)
  static const double mobile = 600;
  
  // Tablet (tablets in portrait, phones in landscape)
  static const double tablet = 900;
  
  // Desktop (tablets in landscape, desktop)
  static const double desktop = 1200;
  
  // Large Desktop
  static const double largeDesktop = 1536;
  
  Breakpoints._();
}

/// Device type based on screen width
enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop;
  
  static DeviceType fromWidth(double width) {
    if (width < Breakpoints.mobile) {
      return DeviceType.mobile;
    } else if (width < Breakpoints.tablet) {
      return DeviceType.tablet;
    } else if (width < Breakpoints.desktop) {
      return DeviceType.desktop;
    } else {
      return DeviceType.largeDesktop;
    }
  }
}

/// Responsive value helper
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;
  final T? largeDesktop;
  
  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });
  
  T getValue(DeviceType deviceType) {
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
  }
}
