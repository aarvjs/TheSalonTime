import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/role_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../profile/services/customer_profile_service.dart';
import '../services/customer_auth_service.dart';
import 'customer_otp_screen.dart';

class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_isLoading) return; // Prevent duplicate taps

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final rawPhone = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
      final fullPhoneNumber = '${AppConstants.defaultCountryCode}$rawPhone';

      CustomerAuthService.instance.sendOtp(
        fullPhoneNumber: fullPhoneNumber,
        onVerificationFailed: (errorMessage) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _errorMessage = errorMessage;
          });
        },
        onCodeSent: (verificationId, resendToken) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });
          Navigator.pushNamed(
            context,
            AppRoutes.customerOtp,
            arguments: CustomerOtpScreenArgs(
              phoneNumber: fullPhoneNumber,
              verificationId: verificationId,
              resendToken: resendToken,
            ),
          );
        },
        onVerificationCompleted: (credential) async {
          // Automatic SMS retrieval on Android devices
          try {
            final userCredential = await CustomerAuthService.instance.signInWithCredential(credential);
            final uid = userCredential.user?.uid;
            if (uid != null && mounted) {
              final profile = await CustomerProfileService.instance.getCustomerProfile(uid);
              if (!mounted) return;
              if (profile == null || !profile.profileCompleted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.customerProfileSetup,
                  (route) => false,
                );
              } else {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.customerHome,
                  (route) => false,
                );
              }
            }
          } catch (e) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _errorMessage = e.toString();
              });
            }
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = RoleTheme.controllerOf(context);
    final isMaleTheme = themeNotifier.mode == AppRoleThemeMode.customerMale;
    final isFemaleTheme = themeNotifier.mode == AppRoleThemeMode.customerFemale;

    final bgColor = isFemaleTheme
        ? const Color(0xFFFAF2F0)
        : AppColors.warmIvory;

    final primaryAccent = isFemaleTheme
        ? AppColors.softRose
        : (isMaleTheme ? AppColors.deepNavy : AppColors.copper);

    final illuAsset = isFemaleTheme
        ? AssetConstants.femaleLoginIllu
        : (isMaleTheme ? AssetConstants.maleLoginIllu : AssetConstants.femaleLoginIllu);

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            // Top Left Navy Curve for Male Theme
            if (isMaleTheme)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SvgPicture.asset(
                  AssetConstants.maleTopCurve,
                  fit: BoxFit.cover,
                  height: 120,
                ),
              ),
            // Bottom Flourish Leaves
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SvgPicture.asset(
                isFemaleTheme
                    ? AssetConstants.femaleLeafFlourish
                    : (isMaleTheme
                        ? AssetConstants.maleLeafFlourish
                        : AssetConstants.femaleLeafFlourish),
                fit: BoxFit.cover,
                height: 160,
              ),
            ),
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top Navigation Header Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_rounded,
                              color: isMaleTheme ? Colors.white : AppColors.warmBlack,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          SvgPicture.asset(
                            AssetConstants.leafLogo,
                            width: 28,
                            height: 34,
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Center Vector Artwork Avatar Illustration
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryAccent.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(70),
                          child: Image.asset(
                            illuAsset,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Welcome Back Title & Subtitle
                      Text(
                        'Welcome Back',
                        style: AppTextStyles.h1(color: AppColors.warmBlack).copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Login with your mobile number to continue',
                        style: AppTextStyles.subtitle(color: AppColors.mutedTextGray).copyWith(
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Mobile Number Input Field with +91 Prefix
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: Validators.validatePhone,
                        onChanged: (_) {
                          if (_errorMessage != null) {
                            setState(() => _errorMessage = null);
                          }
                        },
                        style: AppTextStyles.body(color: AppColors.warmBlack).copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: '10-Digit Mobile Number',
                          hintStyle: AppTextStyles.subtitle(color: AppColors.mutedTextGray),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          prefixIcon: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            margin: const EdgeInsets.only(right: 12),
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(color: Color(0xFFEBE6DF), width: 1.2),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppConstants.defaultCountryCode,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.warmBlack,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.mutedTextGray),
                              ],
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFFEBE6DF), width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: primaryAccent, width: 1.8),
                          ),
                        ),
                      ),

                      // Error Banner (if any)
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red.shade900,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),
                      // Primary Continue CTA Button
                      AppButton(
                        text: 'Get Verification Code',
                        isLoading: _isLoading,
                        backgroundColor: primaryAccent,
                        onPressed: _onContinue,
                      ),
                      const SizedBox(height: 20),
                      // Terms & Privacy Policy Text
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text.rich(
                          TextSpan(
                            text: 'By continuing, you agree to our\n',
                            style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(
                              fontSize: 12,
                              height: 1.5,
                            ),
                            children: [
                              TextSpan(
                                text: 'Terms of Service & Privacy Policy',
                                style: AppTextStyles.caption(color: primaryAccent).copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
