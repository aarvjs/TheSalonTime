import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../data/partner_state.dart';
import '../../models/partner_models.dart';
import '../partner_firestore_service.dart';

class AddServiceScreen extends StatefulWidget {
  final SalonModel? targetSalon;
  final SalonServiceModel? serviceToEdit;

  const AddServiceScreen({
    super.key,
    this.targetSalon,
    this.serviceToEdit,
  });

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _durationController;
  late TextEditingController _priceController;
  late TextEditingController _offerPriceController;

  late String _category;
  final List<String> _categories = [
    'Hair Care',
    'Skin Care',
    'Beard & Shave',
    'Hands & Feet',
    'Spa & Wellness',
    'Bridal & Groom',
    'Hair Colour',
    'Facial',
  ];

  late bool _availableAtSalon;
  late bool _availableAtHome;
  late bool _isActive;

  String? _selectedSalonId;
  File? _selectedImageFile;
  String? _currentImageUrl;
  bool _isUploadingImage = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final edit = widget.serviceToEdit;

    _nameController = TextEditingController(text: edit?.name ?? '');
    _descController = TextEditingController(text: edit?.description ?? '');
    _durationController = TextEditingController(text: (edit?.durationMinutes ?? 45).toString());
    _priceController = TextEditingController(text: edit != null ? edit.price.toStringAsFixed(0) : '');
    _offerPriceController = TextEditingController(
      text: (edit?.offerPrice != null) ? edit!.offerPrice!.toStringAsFixed(0) : '',
    );

    _category = (edit != null && _categories.contains(edit.category))
        ? edit.category
        : 'Hair Care';

    _availableAtSalon = edit?.availableAtSalon ?? true;
    _availableAtHome = edit?.availableAtHome ?? false;
    _isActive = edit?.isActive ?? true;
    _currentImageUrl = edit?.imageUrl;

    _selectedSalonId = widget.targetSalon?.salonId ??
        PartnerState.instance.selectedServiceSalonId;
    if ((_selectedSalonId == null || _selectedSalonId!.isEmpty) &&
        PartnerState.instance.salons.isNotEmpty) {
      _selectedSalonId = PartnerState.instance.salons.first.salonId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _offerPriceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (picked != null) {
        setState(() {
          _selectedImageFile = File(picked.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.errorRed,
          content: Text('Error picking image: $e'),
        ),
      );
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                  color: const Color(0xFFD6D0C7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Upload Service Photo',
                style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.copper),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.copper),
                title: const Text('Take Photo with Camera', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSaveService() async {
    if (!_formKey.currentState!.validate()) return;

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

    if (offerPrice != null && offerPrice >= price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.errorRed,
          content: Text('Discount/Offer price must be less than the regular price.'),
        ),
      );
      return;
    }

    final duration = int.tryParse(_durationController.text.trim()) ?? 45;
    final salonId = _selectedSalonId ??
        (PartnerState.instance.salons.isNotEmpty
            ? PartnerState.instance.salons.first.salonId
            : '');

    if (salonId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.errorRed,
          content: Text('Please select a salon location to attach this service to.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final serviceId = widget.serviceToEdit?.id ??
          'srv_${DateTime.now().millisecondsSinceEpoch}';

      String? finalImageUrl = _currentImageUrl;

      // Upload image to Firebase Storage if a new file was chosen
      if (_selectedImageFile != null) {
        setState(() => _isUploadingImage = true);
        finalImageUrl = await PartnerFirestoreService.instance.uploadSalonServicePhoto(
          salonId: salonId,
          serviceId: serviceId,
          file: _selectedImageFile!,
        );
      }

      final updatedService = SalonServiceModel(
        id: serviceId,
        name: _nameController.text.trim(),
        category: _category,
        description: _descController.text.trim(),
        durationMinutes: duration,
        price: price,
        offerPrice: offerPrice,
        imageUrl: finalImageUrl,
        availableAtSalon: _availableAtSalon,
        availableAtHome: _availableAtHome,
        isActive: _isActive,
      );

      if (widget.serviceToEdit != null) {
        await PartnerState.instance.updateServiceInSalon(salonId, updatedService);
      } else {
        await PartnerState.instance.addServiceToSalon(salonId, updatedService);
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.copper,
          content: Text(
            widget.serviceToEdit != null
                ? 'Service "${updatedService.name}" updated!'
                : 'Service "${updatedService.name}" added to salon!',
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isUploadingImage = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.errorRed,
          content: Text('Error saving service: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final salons = PartnerState.instance.salons;
    final isEditing = widget.serviceToEdit != null;

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: AppColors.warmIvory,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.warmBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Service' : 'Add New Service',
          style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              // 1. SALON LOCATION SELECTOR
              if (salons.length > 1) ...[
                Text(
                  'Target Salon Location',
                  style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedSalonId,
                      items: salons.map((s) {
                        return DropdownMenuItem<String>(
                          value: s.salonId,
                          child: Text(
                            '${s.name} (${s.city})',
                            style: TextStyle(fontSize: 13, color: AppColors.warmBlack),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: isEditing
                          ? null // Don't move service to another salon during edit
                          : (newId) {
                              if (newId != null) setState(() => _selectedSalonId = newId);
                            },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 2. IMAGE UPLOAD & PREVIEW CARD
              Text(
                'Service Image',
                style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _showImagePickerModal,
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEBE6DF), width: 1.2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: _selectedImageFile != null
                        ? Image.file(
                            _selectedImageFile!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : (_currentImageUrl != null && _currentImageUrl!.isNotEmpty
                            ? AppImage(
                                imagePath: _currentImageUrl!,
                                fit: BoxFit.cover,
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add_a_photo_outlined, size: 36, color: AppColors.copper),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Upload High-Quality Service Image',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.charcoal,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Tap to choose from Gallery or Camera',
                                      style: TextStyle(fontSize: 11, color: AppColors.mutedTextGray),
                                    ),
                                  ],
                                ),
                              )),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 3. SERVICE NAME
              Text(
                'Service Name',
                style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'e.g. Precision Haircut & Styling, Hydra Glow Facial',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEBE6DF)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEBE6DF)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.copper, width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Service name is required';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 4. CATEGORY SELECTOR
              Text(
                'Service Category',
                style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEBE6DF)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _category,
                    items: _categories.map((c) {
                      return DropdownMenuItem<String>(
                        value: c,
                        child: Text(c, style: TextStyle(fontSize: 13, color: AppColors.warmBlack)),
                      );
                    }).toList(),
                    onChanged: (newCat) {
                      if (newCat != null) setState(() => _category = newCat);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 5. DESCRIPTION
              Text(
                'Service Description',
                style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'What is included in this service, treatment steps, benefits...',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEBE6DF)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEBE6DF)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.copper, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 6. PRICING & DURATION (ROW)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price (₹) *',
                          style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '399',
                            prefixText: '₹ ',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFEBE6DF)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFEBE6DF)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.copper, width: 1.5),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Enter price';
                            final num = double.tryParse(val.trim());
                            if (num == null || num <= 0) return 'Valid price';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Offer Price (Optional)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Offer Price (₹)',
                          style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _offerPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Optional',
                            prefixText: '₹ ',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFEBE6DF)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFEBE6DF)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.copper, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Duration Minutes
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Duration *',
                          style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '45',
                            suffixText: 'm',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFEBE6DF)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFEBE6DF)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.copper, width: 1.5),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Duration';
                            final num = int.tryParse(val.trim());
                            if (num == null || num <= 0) return 'Min 5';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 7. AVAILABILITY CHECKBOXES
              Text(
                'Service Mode & Availability',
                style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEBE6DF)),
                ),
                child: Column(
                  children: [
                    CheckboxListTile(
                      activeColor: AppColors.copper,
                      title: const Text('Available at Salon Location', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Customers can book an appointment at this salon', style: TextStyle(fontSize: 11)),
                      value: _availableAtSalon,
                      onChanged: (val) => setState(() => _availableAtSalon = val ?? true),
                    ),
                    const Divider(height: 1, color: Color(0xFFF3EFE8)),
                    CheckboxListTile(
                      activeColor: AppColors.copper,
                      title: const Text('Available for Home Service', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Specialist can visit the customer’s home location', style: TextStyle(fontSize: 11)),
                      value: _availableAtHome,
                      onChanged: (val) => setState(() => _availableAtHome = val ?? false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 8. ACTIVE STATUS TOGGLE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEBE6DF)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Service Status: ${_isActive ? 'Active' : 'Inactive'}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _isActive ? 'Visible to customers for booking' : 'Hidden from customer view',
                          style: TextStyle(fontSize: 11, color: AppColors.mutedTextGray),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isActive,
                      activeThumbColor: AppColors.copper,
                      onChanged: (val) => setState(() => _isActive = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 9. SUBMIT BUTTON
              AppButton(
                text: isEditing ? 'Update Service' : 'Add Service to Salon',
                isLoading: _isLoading,
                onPressed: _onSaveService,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
