import 'package:flutter/material.dart';
import '../../features/branch_manager/auth/screens/manager_login_screen.dart';
import '../../features/customer/auth/screens/customer_login_screen.dart';
import '../../features/customer/navigation/customer_navigation_shell.dart';
import '../../features/customer/preference/screens/customer_preference_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/partner/auth/screens/partner_login_screen.dart';
import '../../features/role_selection/screens/choose_role_screen.dart';
import '../../features/splash/screens/splash_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String chooseRole = '/choose-role';
  static const String customerPreference = '/customer-preference';
  static const String customerLogin = '/customer-login';
  static const String customerHome = '/customer-home';
  static const String partnerLogin = '/partner-login';
  static const String managerLogin = '/manager-login';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        onboarding: (context) => const OnboardingScreen(),
        chooseRole: (context) => const ChooseRoleScreen(),
        customerPreference: (context) => const CustomerPreferenceScreen(),
        customerLogin: (context) => const CustomerLoginScreen(),
        customerHome: (context) => const CustomerNavigationShell(),
        partnerLogin: (context) => const PartnerLoginScreen(),
        managerLogin: (context) => const ManagerLoginScreen(),
      };
}
