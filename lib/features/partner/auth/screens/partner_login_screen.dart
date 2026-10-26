import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/role_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_button.dart';
import '../../../customer/profile/services/customer_profile_service.dart';
import '../services/partner_auth_service.dart';
import '../../services/partner_firestore_service.dart';
import '../../data/partner_state.dart';
import '../../models/partner_models.dart';

class PartnerLoginScreen extends StatefulWidget {
  const PartnerLoginScreen({super.key});

  @override
  State<PartnerLoginScreen> createState() => _PartnerLoginScreenState();
}

class _PartnerLoginScreenState extends State<PartnerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (_isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final phone = _phoneController.text.trim();
      final password = _passwordController.text;

      // 1. Authenticate with Firebase using phone-to-auth credential mapping
      final credential = await PartnerAuthService.instance.loginPartner(
        phone: phone,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw 'Authentication failed. Please verify credentials.';
      }

      // 2. Fetch Partner document from Firestore
      var partner = await PartnerFirestoreService.instance.getPartnerProfile(user.uid);

      if (partner == null) {
        // Prevent customer accounts from accessing partner portal
        final customer = await CustomerProfileService.instance.getCustomerProfile(user.uid);
        if (customer != null) {
          await PartnerAuthService.instance.signOut();
          throw 'This account is registered as a Customer, not a Salon Partner. Please use Customer login.';
        }

        // Safe auto-recovery for interrupted registration: create Partner profile
        partner = await PartnerFirestoreService.instance.createPartnerProfile(
          uid: user.uid,
          fullName: 'Salon Partner',
          phone: phone,
        );
      }

      // 3. Set local partner state
      PartnerState.instance.setPartner(partner);

      if (mounted) {
        RoleTheme.controllerOf(context).setThemeMode(AppRoleThemeMode.partner);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.copper,
            content: Text(
              'Welcome back, ${partner.fullName}! Connected to Partner Portal.',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );

        // If verified, go to partner main dashboard. Otherwise prompt verification.
        if (partner.verificationStatus == PartnerVerificationStatus.approved) {
          Navigator.pushReplacementNamed(context, AppRoutes.partnerMain);
        } else if (partner.verificationStatus == PartnerVerificationStatus.notSubmitted) {
          Navigator.pushReplacementNamed(context, AppRoutes.partnerVerification);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.partnerVerificationStatus);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            content: Text(
              e.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            // Bottom Organic Silk Leaf Flourish
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 0.35,
                child: SvgPicture.asset(
                  AssetConstants.silkLines,
                  fit: BoxFit.cover,
                  height: 160,
                ),
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
                      // Top Bar Header with Golden Leaf Logo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.warmBlack),
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
                      // Prominent The Salon Times Branding
                      Text(
                        'THE SALON TIMES',
                        style: AppTextStyles.h1(color: AppColors.copper).copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Header Title & Subtitle
                      Text(
                        'Partner Login (सैलून लॉगिन)',
                        style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Apne salon business ko grow karein aur bookings manage karein',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.subtitle(color: AppColors.mutedTextGray).copyWith(
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Center Storefront 3D Illustration Avatar Icon
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.copper.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(70),
                          child: Image.asset(
                            AssetConstants.partnerLoginIllu,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Mobile Number Field
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: Validators.validatePhone,
                        style: AppTextStyles.body(color: AppColors.warmBlack).copyWith(
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: '10-digit mobile number (मोबाइल नंबर)',
                          hintStyle: AppTextStyles.subtitle(color: AppColors.mutedTextGray),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          prefixIcon: const Icon(
                            Icons.phone_outlined,
                            color: AppColors.copper,
                            size: 20,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFFEBE6DF), width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.copper, width: 1.8),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.red.shade600, width: 1.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: Validators.validatePassword,
                        style: AppTextStyles.body(color: AppColors.warmBlack).copyWith(
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: AppTextStyles.subtitle(color: AppColors.mutedTextGray),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.copper,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.mutedTextGray,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFFEBE6DF), width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.copper, width: 1.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: AppTextButton(
                          text: 'Forgot Password?',
                          color: AppColors.copper,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Password reset link sent.')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Primary Login CTA Button
                      AppButton(
                        text: 'Login',
                        isLoading: _isLoading,
                        backgroundColor: AppColors.copper,
                        onPressed: _onLogin,
                      ),
                      const SizedBox(height: 16),
                      // Don't have an account? Register Salon
                      Text(
                        'Don\'t have an account?',
                        style: AppTextStyles.subtitle(color: AppColors.mutedTextGray).copyWith(
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      AppButton(
                        text: 'Register Salon',
                        isOutlined: true,
                        backgroundColor: AppColors.copper,
                        textColor: AppColors.copper,
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.partnerRegister);
                        },
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
