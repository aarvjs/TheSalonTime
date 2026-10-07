import 'package:flutter/material.dart';

class Responsive {
  Responsive._();

  static double width(BuildContext context) => MediaQuery.of(context).size.width;
  static double height(BuildContext context) => MediaQuery.of(context).size.height;

  static bool isSmallPhone(BuildContext context) => width(context) < 375;
  static bool isTablet(BuildContext context) => width(context) >= 600;

  static double horizontalPadding(BuildContext context) {
    if (isTablet(context)) return 48.0;
    if (isSmallPhone(context)) return 16.0;
    return 24.0;
  }
}
