import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/role_theme.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../customer/profile/services/customer_profile_service.dart';
import '../../partner/data/partner_state.dart';
import '../../partner/models/partner_models.dart';
import '../../partner/services/partner_firestore_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    _timer = Timer(const Duration(milliseconds: 2200), () async {
      if (!mounted) return;
      await _checkAuthStateAndNavigate();
    });
  }

  Future<void> _checkAuthStateAndNavigate() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // 1. Check if persistently signed-in user is a Partner
        final isPartnerPattern = user.email != null && user.email!.startsWith('partner_');
        PartnerModel? partnerProfile;

        if (isPartnerPattern) {
          partnerProfile = await PartnerFirestoreService.instance.getPartnerProfile(user.uid);
        } else {
          partnerProfile = await PartnerFirestoreService.instance.getPartnerProfile(user.uid);
        }

        if (partnerProfile != null) {
          if (!mounted) return;
          PartnerState.instance.setPartner(partnerProfile);
          RoleTheme.controllerOf(context).setThemeMode(AppRoleThemeMode.partner);

          if (partnerProfile.verificationStatus == PartnerVerificationStatus.approved) {
            Navigator.pushReplacementNamed(context, AppRoutes.partnerMain);
          } else if (partnerProfile.verificationStatus == PartnerVerificationStatus.notSubmitted) {
            Navigator.pushReplacementNamed(context, AppRoutes.partnerVerification);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.partnerVerificationStatus);
          }
          return;
        }

        // 2. Otherwise handle Customer session
        final profile = await CustomerProfileService.instance.getCustomerProfile(user.uid);
        if (!mounted) return;

        if (profile == null || !profile.profileCompleted) {
          Navigator.pushReplacementNamed(context, AppRoutes.customerProfileSetup);
        } else {
          // Restore saved gender preference from Firestore
          final isMale = profile.gender.toLowerCase() == 'male' || profile.gender == 'Man';
          RoleTheme.controllerOf(context).setThemeMode(
            isMale ? AppRoleThemeMode.customerMale : AppRoleThemeMode.customerFemale,
          );
          Navigator.pushReplacementNamed(context, AppRoutes.customerHome);
        }
      } else {
        // Signed out -> Onboarding
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    } catch (_) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: Stack(
        children: [
          // Elegant Silk Curve Background Lines
          Positioned.fill(
            child: SvgPicture.asset(
              AssetConstants.silkLines,
              fit: BoxFit.cover,
            ),
          ),
          // Centered Brand Logo & Leaf Mark
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: const AppLogo(
                  scale: 1.1,
                  showLeafMark: true,
                  showTagline: true,
                ),
              ),
            ),
          ),
          // Minimal Bottom Loading Accent
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 50,
                  height: 3.5,
                  decoration: BoxDecoration(
                    color: AppColors.champagneGold.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
