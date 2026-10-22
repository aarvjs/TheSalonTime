import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/branch_manager_state.dart';

class ManagerLoginScreen extends StatefulWidget {
  const ManagerLoginScreen({super.key});

  @override
  State<ManagerLoginScreen> createState() => _ManagerLoginScreenState();
}

class _ManagerLoginScreenState extends State<ManagerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'vikram.manager@velvetsalon.com');
  final _passwordController = TextEditingController(text: 'manager123');
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
      setState(() => _isLoading = true);

      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() => _isLoading = false);

        final branch = BranchManagerState.instance.session;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.managerEmerald,
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Welcome ${branch.managerName}! Connected to ${branch.assignedBranchName}.',
                  ),
                ),
              ],
            ),
          ),
        );

        // Open the dashboard for the manager's assigned branch
        Navigator.pushReplacementNamed(context, AppRoutes.managerMain);
      });
    }
  }

  void _fillDemoCredentials() {
    setState(() {
      _emailController.text = 'vikram.manager@velvetsalon.com';
      _passwordController.text = 'manager123';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.managerEmerald,
        duration: Duration(seconds: 1),
        content: Text('Demo Branch Manager credentials applied.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            // Silk Flourish Background Accent
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 0.25,
                child: SvgPicture.asset(
                  AssetConstants.silkLines,
                  fit: BoxFit.cover,
                  height: 150,
                ),
              ),
            ),
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top Header Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.warmBlack),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  AssetConstants.leafLogo,
                                  width: 20,
                                  height: 24,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'THE SALON TIMES',
                                    style: AppTextStyles.h1(color: AppColors.managerEmerald).copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Avatar Silhouette
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: AppColors.managerBorder, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.managerEmerald.withValues(alpha: 0.12),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            AssetConstants.managerLoginIllu,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Heading & Supporting Text
                      Text(
                        'Branch Manager Login',
                        style: AppTextStyles.h1(color: AppColors.warmBlack).copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sign in to manage your assigned salon.',
                        style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Branch Role Badge - Zero Overflow Proof
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.managerEmeraldBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.managerBorder),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lock_clock_outlined, size: 13, color: AppColors.managerEmerald),
                              const SizedBox(width: 5),
                              Text(
                                'Authorized Credentials Only • Read-Only Business Access',
                                style: TextStyle(
                                  color: AppColors.managerEmerald,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email or Mobile Field
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Email or Mobile Number',
                          style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) => Validators.validateRequired(val, 'Email or Mobile number'),
                        style: AppTextStyles.body(color: AppColors.warmBlack).copyWith(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'manager@thesalontimes.com',
                          hintStyle: AppTextStyles.subtitle(color: AppColors.mutedTextGray).copyWith(fontSize: 13),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          prefixIcon: const Icon(
                            Icons.badge_outlined,
                            color: AppColors.managerEmerald,
                            size: 20,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFFEBE6DF), width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.managerEmerald, width: 1.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Password Field
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Manager Password',
                          style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: Validators.validatePassword,
                        style: AppTextStyles.body(color: AppColors.warmBlack).copyWith(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Enter password',
                          hintStyle: AppTextStyles.subtitle(color: AppColors.mutedTextGray).copyWith(fontSize: 13),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.managerEmerald,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: AppColors.mutedTextGray,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFFEBE6DF), width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.managerEmerald, width: 1.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: Text(
                                  'Branch Manager Password Help',
                                  style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 17),
                                ),
                                content: Text(
                                  'Manager credentials are issued and maintained by your Salon Partner (${BranchManagerState.instance.session.assignedPartnerName}). Please contact your partner or the salon owner to retrieve or reset your login credentials.',
                                  style: AppTextStyles.body(color: AppColors.charcoal).copyWith(fontSize: 13),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Understood', style: TextStyle(color: AppColors.managerEmerald, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              'Forgot Password?',
                              style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Sign In Button
                      AppButton(
                        text: 'Sign In to Branch Console',
                        isLoading: _isLoading,
                        backgroundColor: AppColors.managerEmerald,
                        onPressed: _onLogin,
                      ),
                      const SizedBox(height: 14),

                      // Demo Auto-fill Credentials Button - Zero Overflow Proof
                      InkWell(
                        onTap: _fillDemoCredentials,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.managerBorder),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.flash_on_rounded, size: 15, color: AppColors.managerGold),
                                const SizedBox(width: 6),
                                Text(
                                  'Fill Demo Credentials (Vikram Malhotra)',
                                  style: AppTextStyles.caption(color: AppColors.managerEmerald).copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
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
