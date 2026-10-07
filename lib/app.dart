import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/role_theme.dart';

class SalonTimesApp extends StatefulWidget {
  const SalonTimesApp({super.key});

  @override
  State<SalonTimesApp> createState() => _SalonTimesAppState();
}

class _SalonTimesAppState extends State<SalonTimesApp> {
  late final RoleThemeNotifier _roleThemeNotifier;

  @override
  void initState() {
    super.initState();
    _roleThemeNotifier = RoleThemeNotifier();
  }

  @override
  void dispose() {
    _roleThemeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RoleTheme(
      notifier: _roleThemeNotifier,
      child: Builder(
        builder: (context) {
          final colors = RoleTheme.of(context);
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getTheme(colors),
            initialRoute: AppRoutes.splash,
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}
