import 'package:flutter/widgets.dart';

/// Responsive breakpoints. Mobile-first thresholds tuned for web.
enum DeviceClass { mobile, tablet, desktop, wide }

class Breakpoints {
  Breakpoints._();

  static const double tablet = 720;
  static const double desktop = 1100;
  static const double wide = 1500;

  static DeviceClass of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);

  static DeviceClass fromWidth(double width) {
    if (width >= wide) return DeviceClass.wide;
    if (width >= desktop) return DeviceClass.desktop;
    if (width >= tablet) return DeviceClass.tablet;
    return DeviceClass.mobile;
  }
}

extension DeviceClassX on DeviceClass {
  bool get isMobile => this == DeviceClass.mobile;
  bool get isTablet => this == DeviceClass.tablet;
  bool get isDesktopOrWider =>
      this == DeviceClass.desktop || this == DeviceClass.wide;
  bool get isTabletOrWider => this != DeviceClass.mobile;
}

/// Convenience BuildContext extensions for responsive code.
extension ResponsiveContext on BuildContext {
  DeviceClass get device => Breakpoints.of(this);
  bool get isMobile => device.isMobile;
  bool get isDesktopOrWider => device.isDesktopOrWider;
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Pick a value per device class, falling back to the nearest smaller one.
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? wide,
  }) {
    switch (device) {
      case DeviceClass.wide:
        return wide ?? desktop ?? tablet ?? mobile;
      case DeviceClass.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceClass.tablet:
        return tablet ?? mobile;
      case DeviceClass.mobile:
        return mobile;
    }
  }
}
