class AppBreakpoints {
  static const double mobileSmall = 359.0;
  static const double mobile = 599.0;
  static const double tablet = 1023.0;
  static const double desktop = 1439.0;

  static bool isMobile(double width) => width <= mobile;
  static bool isTablet(double width) => width > mobile && width <= tablet;
  static bool isDesktop(double width) => width > tablet;
}
