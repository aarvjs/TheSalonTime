import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/partner_state.dart';
import '../../models/partner_models.dart';

class CreateBranchManagerScreen extends StatefulWidget {
  const CreateBranchManagerScreen({super.key});

  @override
  State<CreateBranchManagerScreen> createState() => _CreateBranchManagerScreenState();
}

class _CreateBranchManagerScreenState extends State<CreateBranchManagerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _tempPasswordController = TextEditingController();
  bool _obscurePassword = true;

  String? _selectedBranchId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final branches = PartnerState.instance.branches;
    if (branches.isNotEmpty) {
      _selectedBranchId = branches.first.branchId;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _tempPasswordController.dispose();
    super.dispose();
  }

  void _onSaveManager() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBranchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.burntOrange,
          content: Text('Please select an assigned branch for this manager.'),
        ),
      );
      return;
    }

    final salon = PartnerState.instance.salon;
    final branch = PartnerState.instance.branches.firstWhere(
      (b) => b.branchId == _selectedBranchId,
      orElse: () => PartnerState.instance.branches.first,
    );

    // Show confirmation dialog with summary before saving
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Confirm Manager Assignment',
          style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please verify assignment details:',
              style: AppTextStyles.caption(color: AppColors.mutedTextGray),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow('Manager Name:', _fullNameController.text.trim()),
            _buildSummaryRow('Mobile:', _phoneController.text.trim()),
            _buildSummaryRow('Email:', _emailController.text.trim()),
            _buildSummaryRow('Salon:', salon.name),
            _buildSummaryRow('Assigned Branch:', branch.branchName),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warmGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Note: A manager will only have access to operations for this assigned branch.',
                style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(fontSize: 11),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Edit Details', style: TextStyle(color: AppColors.charcoal)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.copper,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _commitManagerCreation(branch, salon);
            },
            child: const Text('Confirm & Save'),
          ),
        ],
      ),
    );
  }

  void _commitManagerCreation(BranchModel branch, SalonModel salon) {
    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final newManager = BranchManagerModel(
        managerId: 'mgr_${DateTime.now().millisecondsSinceEpoch}',
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        assignedSalonId: salon.salonId,
        assignedSalonName: salon.name,
        assignedBranchId: branch.branchId,
        assignedBranchName: branch.branchName,
        isActive: true,
        createdAt: DateTime.now(),
      );

      PartnerState.instance.addManager(newManager);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.copper,
          content: Text(
            'Manager ${newManager.fullName} assigned to ${branch.branchName}!',
          ),
        ),
      );

      // Navigate to the main Partner Dashboard shell!
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.partnerMain, (route) => false);
    });
  }

  void _skipForNow() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.charcoal,
        content: Text('Branch Manager creation skipped. You can add managers later from the Staff menu.'),
      ),
    );
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.partnerMain, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final salon = PartnerState.instance.salon;
    final branches = PartnerState.instance.branches;

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: AppColors.warmIvory,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Assign Branch Manager',
          style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.warmBlack),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _skipForNow,
            child: const Text('Skip', style: TextStyle(color: AppColors.copper, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Progress Indicator
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.copper,
                          shape: BoxShape.circle,
                        ),
                        child: const Text('2', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Branch Manager Delegation',
                              style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                            ),
                            Text(
                              'Step 2 of 2: Assign operational manager for your branch',
                              style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Assigned Salon Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.warmGray,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront_rounded, color: AppColors.copper, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              salon.name,
                              style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 14),
                            ),
                            Text(
                              'Category: ${salon.category}',
                              style: AppTextStyles.caption(color: AppColors.mutedTextGray),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Assigned Branch Selector
                Text(
                  'Assign to Branch',
                  style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedBranchId ?? (branches.isNotEmpty ? branches.first.branchId : null),
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.copper),
                      style: AppTextStyles.body(color: AppColors.warmBlack).copyWith(fontSize: 14),
                      items: branches.map((b) {
                        return DropdownMenuItem<String>(
                          value: b.branchId,
                          child: Text('${b.branchName} (${b.city})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedBranchId = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Manager Full Name
                _buildField(
                  controller: _fullNameController,
                  label: 'Manager Full Name',
                  hint: 'e.g. Vikram Malhotra',
                  icon: Icons.person_outline_rounded,
                  validator: (v) => Validators.validateRequired(v, 'Manager full name'),
                ),
                const SizedBox(height: 14),

                // Contact Phone
                _buildField(
                  controller: _phoneController,
                  label: 'Manager Mobile Number',
                  hint: '10-digit contact number',
                  keyboardType: TextInputType.phone,
                  icon: Icons.phone_outlined,
                  validator: Validators.validatePhone,
                ),
                const SizedBox(height: 14),

                // Manager Email
                _buildField(
                  controller: _emailController,
                  label: 'Manager Email Address',
                  hint: 'manager@velvetsalon.com',
                  keyboardType: TextInputType.emailAddress,
                  icon: Icons.email_outlined,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 14),

                // Temporary Password for Demo
                _buildField(
                  controller: _tempPasswordController,
                  label: 'Temporary Password (Demo)',
                  hint: 'Min 6 characters',
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
                const SizedBox(height: 10),

                // Demo Notice on Security
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F6F0),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.security_outlined, size: 16, color: AppColors.copper),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Temporary passwords are used for frontend prototype testing only. Real credentials will be securely dispatched via OTP and backend authentication.',
                          style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                AppButton(
                  text: 'Create & Assign Branch Manager',
                  isLoading: _isLoading,
                  backgroundColor: AppColors.copper,
                  onPressed: _onSaveManager,
                ),
                const SizedBox(height: 12),
                AppButton(
                  text: 'Skip & Finish Setup Later',
                  isOutlined: true,
                  backgroundColor: AppColors.copper,
                  textColor: AppColors.copper,
                  onPressed: _skipForNow,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.caption(color: AppColors.mutedTextGray)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
