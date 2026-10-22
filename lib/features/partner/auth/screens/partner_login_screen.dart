import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_button.dart';
import '../../data/partner_state.dart';
import '../../models/partner_models.dart';

class PartnerLoginScreen extends StatefulWidget {
  const PartnerLoginScreen({super.key});

  @override
  State<PartnerLoginScreen> createState() => _PartnerLoginScreenState();
}

class _PartnerLoginScreenState extends State<PartnerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        final partner = PartnerState.instance.partner;
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
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.partnerVerificationStatus);
        }
      });
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
                      // Mobile / Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) => Validators.validateRequired(val, 'Mobile / Email'),
                        style: AppTextStyles.body(color: AppColors.warmBlack).copyWith(
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Mobile / Email',
                          hintStyle: AppTextStyles.subtitle(color: AppColors.mutedTextGray),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
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
