import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/partner_state.dart';
import '../../models/partner_models.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _durationController = TextEditingController(text: '45');
  final _priceController = TextEditingController();
  final _offerPriceController = TextEditingController();

  String _category = 'Hair Care';
  final List<String> _categories = [
    'Hair Care',
    'Skin Care',
    'Beard & Shave',
    'Hands & Feet',
    'Spa & Wellness',
    'Bridal & Groom',
  ];

  bool _availableAtSalon = true;
  bool _availableAtHome = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _offerPriceController.dispose();
    super.dispose();
  }

  void _onSaveService() {
    if (!_formKey.currentState!.validate()) return;

    // Requirement: Show error if neither Salon nor Home is selected
    if (!_availableAtSalon && !_availableAtHome) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.burntOrange,
          content: Text('Please select at least one availability: Salon Visit or Home Service.'),
        ),
      );
      return;
    }

    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final offerPrice = _offerPriceController.text.trim().isNotEmpty
        ? double.tryParse(_offerPriceController.text.trim())
        : null;
    final duration = int.tryParse(_durationController.text.trim()) ?? 45;

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final newService = SalonServiceModel(
        id: 'srv_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        category: _category,
        description: _descController.text.trim(),
        durationMinutes: duration,
        price: price,
        offerPrice: offerPrice,
        availableAtSalon: _availableAtSalon,
        availableAtHome: _availableAtHome,
        isActive: true,
      );

      PartnerState.instance.addService(newService);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.copper,
          content: Text('Service "${newService.name}" added to catalog!'),
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
          'Add New Service',
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
                  label: 'Service Name',
                  hint: 'e.g. Keratin Silk Hair Treatment',
                  validator: (v) => Validators.validateRequired(v, 'Service name'),
                ),
                const SizedBox(height: 14),

                // Category Dropdown
                Text(
                  'Service Category',
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
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _category = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                _buildField(
                  controller: _descController,
                  label: 'Description',
                  hint: 'Explain the benefits, products used, and procedure...',
                  maxLines: 3,
                  validator: (v) => Validators.validateRequired(v, 'Description'),
                ),
                const SizedBox(height: 14),

                // Duration in minutes
                _buildField(
                  controller: _durationController,
                  label: 'Duration (Minutes)',
                  hint: '45',
                  keyboardType: TextInputType.number,
                  validator: (v) => Validators.validateRequired(v, 'Duration'),
                ),
                const SizedBox(height: 14),

                // Price and Offer Price
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        controller: _priceController,
                        label: 'Standard Price (₹)',
                        hint: '999',
                        keyboardType: TextInputType.number,
                        validator: (v) => Validators.validateRequired(v, 'Price'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        controller: _offerPriceController,
                        label: 'Offer Price (₹) [Optional]',
                        hint: '799',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Service Delivery Options (Salon Visit & Home Service)
                Text(
                  'Service Availability',
                  style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Specify where this particular service can be performed',
                  style: AppTextStyles.caption(color: AppColors.mutedTextGray),
                ),
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
                  ),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Available for Salon Visit',
                          style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                        ),
                        subtitle: const Text('Customer visits the physical salon branch'),
                        value: _availableAtSalon,
                        activeColor: AppColors.copper,
                        onChanged: (val) => setState(() => _availableAtSalon = val ?? false),
                      ),
                      const Divider(height: 1, color: Color(0xFFEBE6DF)),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Available for Home Service',
                          style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                        ),
                        subtitle: const Text('Stylist carries tools to customer doorstep'),
                        value: _availableAtHome,
                        activeColor: AppColors.copper,
                        onChanged: (val) => setState(() => _availableAtHome = val ?? false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                AppButton(
                  text: 'Add to Salon Catalog',
                  isLoading: _isLoading,
                  backgroundColor: AppColors.copper,
                  onPressed: _onSaveService,
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
}
