import 'package:flutter/material.dart';
import 'app_colors.dart';

enum AppRoleThemeMode {
  defaultBrand,
  customerFemale,
  customerMale,
  customerNeutral,
  partner,
  manager,
}

class RoleThemeNotifier extends ChangeNotifier {
  AppRoleThemeMode _mode = AppRoleThemeMode.defaultBrand;
  AppColorsData _colors = AppColors.defaultTheme;

  AppRoleThemeMode get mode => _mode;
  AppColorsData get colors => _colors;

  void setThemeMode(AppRoleThemeMode newMode) {
    if (_mode == newMode) return;
    _mode = newMode;
    switch (newMode) {
      case AppRoleThemeMode.customerFemale:
        _colors = AppColors.customerFemaleTheme;
        break;
      case AppRoleThemeMode.customerMale:
        _colors = AppColors.customerMaleTheme;
        break;
      case AppRoleThemeMode.customerNeutral:
      case AppRoleThemeMode.defaultBrand:
        _colors = AppColors.defaultTheme;
        break;
      case AppRoleThemeMode.partner:
        _colors = AppColors.partnerTheme;
        break;
      case AppRoleThemeMode.manager:
        _colors = AppColors.managerTheme;
        break;
    }
    notifyListeners();
  }
}

class RoleTheme extends InheritedNotifier<RoleThemeNotifier> {
  const RoleTheme({
    super.key,
    required RoleThemeNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AppColorsData of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<RoleTheme>();
    return provider?.notifier?._colors ?? AppColors.defaultTheme;
  }

  static RoleThemeNotifier controllerOf(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<RoleTheme>();
    assert(provider != null && provider.notifier != null,
        'RoleTheme not found in widget tree');
    return provider!.notifier!;
  }
}
