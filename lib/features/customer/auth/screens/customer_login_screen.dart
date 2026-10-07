import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/role_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';

class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        _showOtpDialog();
      });
    }
  }

  void _showOtpDialog() {
    final colors = RoleTheme.of(context);
    final otpControllers = List.generate(4, (_) => TextEditingController());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: AppDimensions.lg,
            left: AppDimensions.screenPaddingHorizontal,
            right: AppDimensions.screenPaddingHorizontal,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppDimensions.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppDimensions.lg),
              Text(
                'Verify Phone Number',
                style: AppTextStyles.h2(color: colors.textPrimary),
              ),
              const SizedBox(height: AppDimensions.xs),
              Text(
                'Enter the 4-digit code sent to ${AppConstants.defaultCountryCode} ${_phoneController.text}',
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitle(color: colors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 54,
                    height: 58,
                    child: TextField(
                      controller: otpControllers[index],
                      autofocus: index == 0,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: AppTextStyles.h2(color: colors.textPrimary),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: colors.surface,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.border, width: 1.2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.primary, width: 2.0),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 3) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppDimensions.xl),
              AppButton(
                text: 'Verify & Continue',
                backgroundColor: colors.primary,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.customerHome,
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: AppDimensions.sm),
            ],
          ),
        );
      },
    );
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
                        width: 150,
                        height: 150,
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
                          borderRadius: BorderRadius.circular(75),
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
                        'Login to continue your journey',
                        style: AppTextStyles.subtitle(color: AppColors.mutedTextGray).copyWith(
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Mobile Number Input Field with +91 Prefix Dropdown
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: Validators.validatePhone,
                        style: AppTextStyles.body(color: AppColors.warmBlack).copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Mobile Number',
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
                      const SizedBox(height: 20),
                      // Primary Continue CTA Button
                      AppButton(
                        text: 'Continue',
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
