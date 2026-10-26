import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/role_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../models/customer_profile_model.dart';
import '../services/customer_profile_service.dart';

class CustomerProfileSetupScreen extends StatefulWidget {
  const CustomerProfileSetupScreen({super.key});

  @override
  State<CustomerProfileSetupScreen> createState() => _CustomerProfileSetupScreenState();
}

class _CustomerProfileSetupScreenState extends State<CustomerProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String _selectedGender = 'Female';
  File? _selectedPhotoFile;
  String? _existingPhotoUrl;

  bool _isLoading = false;
  bool _isUploadingPhoto = false;
  String? _errorMessage;

  CustomerProfileModel? _existingProfile;

  @override
  void initState() {
    super.initState();
    _loadExistingProfileData();
  }

  Future<void> _loadExistingProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final profile = await CustomerProfileService.instance.getCustomerProfile(user.uid);
      if (profile != null && mounted) {
        setState(() {
          _existingProfile = profile;
          _nameController.text = profile.displayName;
          if (profile.gender.isNotEmpty) {
            _selectedGender = profile.gender;
          }
          _existingPhotoUrl = profile.photoUrl;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked != null) {
        setState(() {
          _selectedPhotoFile = File(picked.path);
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not access image. Please grant permission in device settings.';
      });
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFEBE6DF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Profile Photo',
                style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.copper),
                title: const Text('Take a Photo', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.copper),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickPhoto(ImageSource.gallery);
                },
              ),
              if (_selectedPhotoFile != null || _existingPhotoUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  title: const Text('Remove Photo', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _selectedPhotoFile = null;
                      _existingPhotoUrl = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _errorMessage = 'Session expired. Please sign in again.');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _isUploadingPhoto = _selectedPhotoFile != null;
      _errorMessage = null;
    });

    try {
      final phone = (_existingProfile != null && _existingProfile!.phoneNumber.isNotEmpty)
          ? _existingProfile!.phoneNumber
          : (user.phoneNumber ?? '');

      final updated = CustomerProfileModel(
        uid: user.uid,
        phoneNumber: phone,
        displayName: _nameController.text.trim(),
        gender: _selectedGender,
        photoUrl: _existingPhotoUrl,
        profileCompleted: true,
        createdAt: _existingProfile?.createdAt,
        latitude: _existingProfile?.latitude,
        longitude: _existingProfile?.longitude,
        locationUpdatedAt: _existingProfile?.locationUpdatedAt,
        locationPermissionStatus: _existingProfile?.locationPermissionStatus,
      );

      await CustomerProfileService.instance.saveCustomerProfile(
        updated,
        newPhotoFile: _selectedPhotoFile,
      );

      // Personalize theme preference smoothly
      if (mounted) {
        final themeController = RoleTheme.controllerOf(context);
        final isMale = _selectedGender.toLowerCase() == 'male' || _selectedGender == 'Man';
        themeController.setThemeMode(isMale ? AppRoleThemeMode.customerMale : AppRoleThemeMode.customerFemale);
      }

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.customerHome,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isUploadingPhoto = false;
        _errorMessage = 'Failed to save profile: $e';
      });
    }
  }

  Future<void> _skipForNow() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await CustomerProfileService.instance.recordProfileSkipped(
        user.uid,
        user.phoneNumber ?? '',
      );
    }

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.customerHome,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final phone = user?.phoneNumber ?? '+91 ••••• •••••';

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: SafeArea(
        child: Stack(
          children: [
            // Silk Lines Watermark Accent
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top Row with Skip Action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SvgPicture.asset(
                            AssetConstants.leafLogo,
                            width: 24,
                            height: 30,
                          ),
                          TextButton(
                            onPressed: _isLoading ? null : _skipForNow,
                            child: const Text(
                              'Skip for now',
                              style: TextStyle(
                                color: AppColors.copper,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Screen Header
                      Text(
                        'Set Up Your Profile',
                        style: AppTextStyles.h1(color: AppColors.warmBlack).copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Personalize your salon bookings and styling preferences.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.subtitle(color: AppColors.mutedTextGray).copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 24),

                      // Profile Photo Picker Avatar
                      Center(
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: _showPhotoOptions,
                              child: Container(
                                width: 104,
                                height: 104,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(color: AppColors.champagneGold, width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.copper.withValues(alpha: 0.15),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: _selectedPhotoFile != null
                                      ? Image.file(
                                          _selectedPhotoFile!,
                                          fit: BoxFit.cover,
                                        )
                                      : (_existingPhotoUrl != null && _existingPhotoUrl!.isNotEmpty
                                          ? Image.network(
                                              _existingPhotoUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) => const Icon(
                                                Icons.person_rounded,
                                                size: 52,
                                                color: AppColors.champagneGold,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.add_a_photo_rounded,
                                              size: 38,
                                              color: AppColors.copper,
                                            )),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _showPhotoOptions,
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: const BoxDecoration(
                                    color: AppColors.copper,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit_rounded,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedPhotoFile != null
                            ? 'Photo selected'
                            : 'Add profile photo (optional)',
                        style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                      ),
                      const SizedBox(height: 24),

                      // 1. Verified Phone Number Field (Read-only)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Verified Mobile Number',
                          style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFEBE6DF)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.phone_iphone_rounded, color: AppColors.mutedTextGray, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                phone,
                                style: AppTextStyles.body(color: AppColors.warmBlack).copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_rounded, size: 12, color: Colors.green.shade700),
                                  const SizedBox(width: 4),
                                  Text(
                                    'VERIFIED',
                                    style: TextStyle(
                                      color: Colors.green.shade800,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 2. Display Name Field
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Your Full Name (Optional)',
                          style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        validator: (val) {
                          if (val != null && val.trim().isNotEmpty && val.trim().length < 2) {
                            return 'Name should be at least 2 characters long';
                          }
                          if (val != null && val.trim().length > 50) {
                            return 'Name must not exceed 50 characters';
                          }
                          return null;
                        },
                        style: AppTextStyles.body(color: AppColors.warmBlack).copyWith(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'e.g. Arvind Sharma',
                          hintStyle: AppTextStyles.subtitle(color: AppColors.mutedTextGray).copyWith(fontSize: 13),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.copper, size: 20),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFFEBE6DF), width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.copper, width: 1.8),
                          ),
                        ),
                      ),

                      // Error message banner
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
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

                      // Save & Continue Button
                      AppButton(
                        text: _isUploadingPhoto ? 'Uploading Photo & Saving...' : 'Save & Continue',
                        isLoading: _isLoading,
                        backgroundColor: AppColors.copper,
                        onPressed: _saveProfile,
                      ),
                      const SizedBox(height: 12),

                      // Secondary Skip Button
                      TextButton(
                        onPressed: _isLoading ? null : _skipForNow,
                        child: Text(
                          'Skip setup for now',
                          style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
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
