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

class PartnerRegisterScreen extends StatefulWidget {
  const PartnerRegisterScreen({super.key});

  @override
  State<PartnerRegisterScreen> createState() => _PartnerRegisterScreenState();
}

class _PartnerRegisterScreenState extends State<PartnerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.burntOrange,
          content: Text('Please accept the Terms & Conditions to continue.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final businessName = "$name's Salon";
      final email = '${name.toLowerCase().replaceAll(' ', '')}@partner.salontimes.com';

      // Save to local in-memory PartnerState
      PartnerState.instance.registerPartner(
        fullName: name,
        email: email,
        phone: phone,
        businessName: businessName,
      );
      PartnerState.instance.setVerificationStatusDemo(PartnerVerificationStatus.submitted);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.copper,
          content: Text(
            'Welcome $name! Partner account created successfully.',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );

      // Navigate to business document verification / status
      Navigator.pushReplacementNamed(context, AppRoutes.partnerVerificationStatus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: SafeArea(
        child: Stack(
          children: [
            // Bottom Organic Silk Watermark
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 0.25,
                child: SvgPicture.asset(
                  AssetConstants.silkLines,
                  fit: BoxFit.cover,
                  height: 140,
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
                      // Top Bar
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
                      const SizedBox(height: 10),

                      // Prominent "The Salon Times" Brand Title
                      Text(
                        'THE SALON TIMES',
                        style: AppTextStyles.h1(color: AppColors.copper).copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Page Subtitle with Clear Reading Label
                      Text(
                        'Partner Registration (पार्टनर रजिस्ट्रेशन)',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Apna salon register karein aur naye customers payein',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.subtitle(color: AppColors.mutedTextGray).copyWith(
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 1. Owner Full Name
                      _buildTextField(
                        controller: _nameController,
                        label: 'Owner Full Name (सैलून मालिक का नाम)',
                        hint: 'e.g. Ramesh Kumar / Priya Sharma',
                        icon: Icons.person_outline_rounded,
                        validator: (val) => Validators.validateRequired(val, 'Owner name'),
                      ),
                      const SizedBox(height: 16),

                      // 2. Mobile Number
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Mobile Number (मोबाइल नंबर)',
                        hint: '10-digit mobile number',
                        keyboardType: TextInputType.phone,
                        icon: Icons.phone_outlined,
                        validator: Validators.validatePhone,
                      ),
                      const SizedBox(height: 16),

                      // 3. Password
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password (पासवर्ड बनाएं)',
                        hint: 'Kam se kam 6 akshar (Min 6 characters)',
                        obscureText: _obscurePassword,
                        icon: Icons.lock_outline_rounded,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppColors.mutedTextGray,
                            size: 19,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: Validators.validatePassword,
                      ),
                      const SizedBox(height: 16),

                      // 4. Confirm Password
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password (पासवर्ड दोबारा डालें)',
                        hint: 'Re-enter your password',
                        obscureText: _obscureConfirmPassword,
                        icon: Icons.lock_clock_outlined,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppColors.mutedTextGray,
                            size: 19,
                          ),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please confirm password';
                          }
                          if (val != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Terms & Conditions Checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _agreeToTerms,
                              activeColor: AppColors.copper,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (val) => setState(() => _agreeToTerms = val ?? false),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'I agree to The Salon Times Partner Terms of Service and Privacy Policy.',
                              style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Create Account Button
                      AppButton(
                        text: 'Create Partner Account (रजिस्टर करें)',
                        isLoading: _isLoading,
                        backgroundColor: AppColors.copper,
                        onPressed: _onRegister,
                      ),
                      const SizedBox(height: 16),

                      // Already have an account?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Pehle se account hai?',
                            style: AppTextStyles.subtitle(color: AppColors.mutedTextGray).copyWith(
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 6),
                          AppTextButton(
                            text: 'Login Karein',
                            color: AppColors.copper,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTextStyles.body(color: AppColors.warmBlack).copyWith(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.subtitle(color: AppColors.mutedTextGray).copyWith(fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            prefixIcon: Icon(icon, color: AppColors.copper, size: 20),
            suffixIcon: suffixIcon,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFEBE6DF), width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.copper, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.red.shade600, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}
