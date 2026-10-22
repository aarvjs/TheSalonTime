import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/partner_state.dart';

class EditSalonScreen extends StatefulWidget {
  const EditSalonScreen({super.key});

  @override
  State<EditSalonScreen> createState() => _EditSalonScreenState();
}

class _EditSalonScreenState extends State<EditSalonScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;

  late String _category;
  late String _openingHours;
  late String _closingHours;
  late List<String> _facilities;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final salon = PartnerState.instance.salon;
    _nameController = TextEditingController(text: salon.name);
    _descController = TextEditingController(text: salon.description);
    _phoneController = TextEditingController(text: salon.phone);
    _emailController = TextEditingController(text: salon.email);
    _addressController = TextEditingController(text: salon.address);
    _category = salon.category;
    _openingHours = salon.openingHours;
    _closingHours = salon.closingHours;
    _facilities = List.from(salon.facilities);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final current = PartnerState.instance.salon;
      final updated = current.copyWith(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        category: _category,
        openingHours: _openingHours,
        closingHours: _closingHours,
        facilities: _facilities,
      );

      PartnerState.instance.updateSalon(updated);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.copper,
          content: Text('Salon details updated successfully!'),
        ),
      );

      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: AppColors.warmIvory,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Edit Salon Information',
          style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.warmBlack),
          onPressed: () => Navigator.pop(context),
        ),
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
                _buildField(
                  controller: _nameController,
                  label: 'Salon Name',
                  hint: 'Enter salon brand name',
                  validator: (v) => Validators.validateRequired(v, 'Salon name'),
                ),
                const SizedBox(height: 14),

                _buildField(
                  controller: _descController,
                  label: 'Salon Description',
                  hint: 'About your salon experience',
                  maxLines: 3,
                  validator: (v) => Validators.validateRequired(v, 'Description'),
                ),
                const SizedBox(height: 14),

                // Category Dropdown
                Text(
                  'Salon Category',
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
                      value: _category,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.copper),
                      style: AppTextStyles.body(color: AppColors.warmBlack).copyWith(fontSize: 14),
                      items: [
                        'Unisex Premium Salon & Spa',
                        'Women Beauty & Bridal Lounge',
                        'Men Grooming & Barber Club',
                        'Luxury Hair Spa & Skin Clinic',
                      ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _category = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                _buildField(
                  controller: _addressController,
                  label: 'Street Address',
                  hint: 'Full physical address',
                  validator: (v) => Validators.validateRequired(v, 'Address'),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        controller: _phoneController,
                        label: 'Phone',
                        hint: 'Phone number',
                        keyboardType: TextInputType.phone,
                        validator: Validators.validatePhone,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Business email',
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _buildTimeDropdown('Opening Time', _openingHours, (val) => setState(() => _openingHours = val)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTimeDropdown('Closing Time', _closingHours, (val) => setState(() => _closingHours = val)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                AppButton(
                  text: 'Save Changes',
                  isLoading: _isLoading,
                  backgroundColor: AppColors.copper,
                  onPressed: _onSave,
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
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
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
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTextStyles.body(color: AppColors.warmBlack).copyWith(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.subtitle(color: AppColors.mutedTextGray).copyWith(fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

  Widget _buildTimeDropdown(String label, String value, ValueChanged<String> onChanged) {
    final times = [
      '08:00 AM',
      '08:30 AM',
      '09:00 AM',
      '09:30 AM',
      '10:00 AM',
      '07:30 PM',
      '08:00 PM',
      '08:30 PM',
      '09:00 PM',
      '09:30 PM',
      '10:00 PM',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEBE6DF)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: times.contains(value) ? value : times.first,
              isExpanded: true,
              icon: const Icon(Icons.access_time_rounded, color: AppColors.copper, size: 18),
              style: AppTextStyles.body(color: AppColors.warmBlack).copyWith(fontSize: 14),
              items: times.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ),
        ),
      ],
    );
  }
}
