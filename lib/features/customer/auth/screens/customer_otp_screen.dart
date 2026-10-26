import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/role_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../profile/services/customer_profile_service.dart';
import '../services/customer_auth_service.dart';

class CustomerOtpScreenArgs {
  final String phoneNumber;
  final String verificationId;
  final int? resendToken;

  const CustomerOtpScreenArgs({
    required this.phoneNumber,
    required this.verificationId,
    this.resendToken,
  });
}

class CustomerOtpScreen extends StatefulWidget {
  final CustomerOtpScreenArgs args;

  const CustomerOtpScreen({
    super.key,
    required this.args,
  });

  @override
  State<CustomerOtpScreen> createState() => _CustomerOtpScreenState();
}

class _CustomerOtpScreenState extends State<CustomerOtpScreen> {
  // Standard 6-digit SMS OTP from Firebase Authentication
  static const int _otpLength = 6;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  late String _currentVerificationId;
  int? _currentResendToken;

  bool _isVerifying = false;
  bool _isResending = false;
  String? _errorMessage;

  Timer? _timer;
  int _countdown = 45;

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.args.verificationId;
    _currentResendToken = widget.args.resendToken;
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _countdown = 45;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String _getOtpCode() {
    return _controllers.map((c) => c.text).join();
  }

  String _maskPhoneNumber(String phone) {
    if (phone.length >= 10) {
      final last4 = phone.substring(phone.length - 4);
      final firstPart = phone.substring(0, phone.length - 7);
      return '$firstPart •••• $last4';
    }
    return phone;
  }

  Future<void> _verifyOtp() async {
    final code = _getOtpCode().trim();
    if (code.length < _otpLength) {
      setState(() {
        _errorMessage = 'Please enter all 6 digits of the verification code received via SMS.';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final credential = await CustomerAuthService.instance.signInWithOtp(
        verificationId: _currentVerificationId,
        smsCode: code,
      );

      final user = credential.user;
      if (user == null) {
        throw 'User session could not be established. Please retry.';
      }

      // Save the initially selected gender in customer Firestore document customers/{uid}
      if (mounted) {
        final isMale = RoleTheme.controllerOf(context).mode == AppRoleThemeMode.customerMale;
        final initialGender = isMale ? 'Male' : 'Female';
        await CustomerProfileService.instance.saveInitialGender(
          uid: user.uid,
          phoneNumber: user.phoneNumber ?? widget.args.phoneNumber,
          gender: initialGender,
        );
      }

      // Check user's Firestore customer profile
      final profile = await CustomerProfileService.instance.getCustomerProfile(user.uid);

      if (!mounted) return;

      if (profile == null || !profile.profileCompleted) {
        // First login or incomplete profile -> Profile Setup
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.customerProfileSetup,
          (route) => false,
        );
      } else {
        // Profile already complete -> Customer Home
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.customerHome,
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _resendOtp() async {
    if (_countdown > 0 || _isResending) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();

    await CustomerAuthService.instance.sendOtp(
      fullPhoneNumber: widget.args.phoneNumber,
      resendToken: _currentResendToken,
      onVerificationFailed: (error) {
        if (!mounted) return;
        setState(() {
          _isResending = false;
          _errorMessage = error;
        });
      },
      onCodeSent: (newVerificationId, newResendToken) {
        if (!mounted) return;
        setState(() {
          _isResending = false;
          _currentVerificationId = newVerificationId;
          _currentResendToken = newResendToken;
        });
        _startCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.copper,
            duration: Duration(seconds: 2),
            content: Text('A fresh 6-digit verification code has been sent to your phone.'),
          ),
        );
      },
    );
  }

  void _onDigitChanged(int index, String value) {
    setState(() => _errorMessage = null);

    // Auto-fill full 6-digit code if pasted or auto-retrieved
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < _otpLength && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      if (digits.length >= _otpLength) {
        _focusNodes[_otpLength - 1].unfocus();
        _verifyOtp();
      }
      return;
    }

    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_getOtpCode().length == _otpLength) {
          _verifyOtp();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = RoleTheme.controllerOf(context);
    final isMaleTheme = themeNotifier.mode == AppRoleThemeMode.customerMale;
    final primaryAccent = isMaleTheme ? AppColors.deepNavy : AppColors.copper;

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: SafeArea(
        child: Stack(
          children: [
            // Silk Flourish Background Lines
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 0.25,
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top Navigation Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.warmBlack),
                          onPressed: () => Navigator.pop(context),
                        ),
                        SvgPicture.asset(
                          AssetConstants.leafLogo,
                          width: 24,
                          height: 30,
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Verification Icon Badge
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.champagneGold, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: primaryAccent.withValues(alpha: 0.12),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.mark_email_read_rounded,
                          size: 36,
                          color: primaryAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Screen Title & Subtitle
                    Text(
                      'Verify 6-Digit OTP',
                      style: AppTextStyles.h1(color: AppColors.warmBlack).copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Enter the 6-digit verification code sent to\n',
                        style: AppTextStyles.subtitle(color: AppColors.mutedTextGray).copyWith(fontSize: 13),
                        children: [
                          TextSpan(
                            text: _maskPhoneNumber(widget.args.phoneNumber),
                            style: AppTextStyles.subtitle(color: AppColors.warmBlack).copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 6-digit OTP Input Boxes Row (Zero overflow proof with FittedBox)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_otpLength, (index) {
                          final isFocused = _focusNodes[index].hasFocus;
                          final hasValue = _controllers[index].text.isNotEmpty;

                          return Container(
                            width: 46,
                            height: 58,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isFocused
                                    ? primaryAccent
                                    : (hasValue ? AppColors.champagneGold : const Color(0xFFEBE6DF)),
                                width: isFocused ? 2.0 : 1.3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isFocused
                                      ? primaryAccent.withValues(alpha: 0.12)
                                      : Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: KeyboardListener(
                              focusNode: FocusNode(),
                              onKeyEvent: (event) {
                                if (event is KeyDownEvent &&
                                    event.logicalKey == LogicalKeyboardKey.backspace &&
                                    _controllers[index].text.isEmpty &&
                                    index > 0) {
                                  _focusNodes[index - 1].requestFocus();
                                }
                              },
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                autofocus: index == 0,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 1,
                                style: AppTextStyles.h1(color: AppColors.warmBlack).copyWith(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  counterText: '',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (val) => _onDigitChanged(index, val),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // Error Message Banner (if any)
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 18),
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

                    const SizedBox(height: 28),

                    // Verify & Continue Button
                    AppButton(
                      text: 'Verify & Sign In',
                      isLoading: _isVerifying,
                      backgroundColor: primaryAccent,
                      onPressed: _verifyOtp,
                    ),

                    const SizedBox(height: 22),

                    // Resend OTP Countdown & Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Didn\'t receive the code? ',
                          style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 13),
                        ),
                        if (_countdown > 0)
                          Text(
                            'Resend in ${_countdown}s',
                            style: AppTextStyles.caption(color: primaryAccent).copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else
                          InkWell(
                            onTap: _isResending ? null : _resendOtp,
                            child: _isResending
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(
                                    'Resend OTP',
                                    style: AppTextStyles.caption(color: primaryAccent).copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
