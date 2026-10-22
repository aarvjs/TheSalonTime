import 'package:flutter/material.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/partner_state.dart';
import '../../models/partner_models.dart';

class CreateSalonScreen extends StatefulWidget {
  const CreateSalonScreen({super.key});

  @override
  State<CreateSalonScreen> createState() => _CreateSalonScreenState();
}

class _CreateSalonScreenState extends State<CreateSalonScreen> {
  final _formKey = GlobalKey<FormState>();

  // Salon Showcase Image
  String _selectedSalonImage = AssetConstants.maleBanner1;

  final List<Map<String, String>> _salonImagePresets = [
    {
      'title': 'The Flagship Studio',
      'tag': 'Unisex Luxury',
      'asset': AssetConstants.maleBanner1,
    },
    {
      'title': 'Bridal Glamour Lounge',
      'tag': 'Women Bridal',
      'asset': AssetConstants.partnerLoginIllu,
    },
    {
      'title': 'Master Barber Club',
      'tag': 'Men Grooming',
      'asset': AssetConstants.roleCustomer,
    },
    {
      'title': 'Holistic Wellness Spa',
      'tag': 'Spa & Therapies',
      'asset': AssetConstants.rolePartner,
    },
  ];

  // Basic Info
  final _nameController = TextEditingController(text: 'The Royal Velvet Luxury Salon');
  final _descController = TextEditingController(
    text: 'Award-winning luxury grooming & beauty destination offering bespoke haircuts, Parisian hair spa treatments, organic bridal skin therapies, and doorstep concierge services.',
  );
  String _category = 'Unisex Premium Salon & Spa';
  final _phoneController = TextEditingController(text: '+91 512 2309871');
  final _emailController = TextEditingController(text: 'contact@velvetsalon.com');

  // Address
  final _countryController = TextEditingController(text: 'India');
  final _stateController = TextEditingController(text: 'Uttar Pradesh');
  final _cityController = TextEditingController(text: 'Kanpur');
  final _areaController = TextEditingController(text: 'Civil Lines');
  final _addressController = TextEditingController(text: 'Plot 14/82, The Mall Avenue, Opp. Green Park');
  final _postalCodeController = TextEditingController(text: '208001');

  // Location Coordinates
  final _latController = TextEditingController(text: '26.4719');
  final _lngController = TextEditingController(text: '80.3524');

  // Salon Details
  String _openingHours = '09:00 AM';
  String _closingHours = '08:30 PM';
  final List<String> _selectedOperatingDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> _allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final List<String> _selectedFacilities = [
    'Private VIP Suites',
    'Air Conditioned',
    'Complimentary Artisanal Coffee & Tea',
    'Free High-Speed Wi-Fi',
    'Valet Parking',
  ];
  final List<String> _allFacilities = [
    'Private VIP Suites',
    'Air Conditioned',
    'Complimentary Artisanal Coffee & Tea',
    'Free High-Speed Wi-Fi',
    'Valet Parking',
    'Sterilized Tools',
    'Kids Play Zone',
    'Shower Facility',
  ];

  // Home Service Setup
  bool _enableHomeService = true;
  double _homeServiceRadius = 12.0;
  final _homeServiceFeeController = TextEditingController(text: '149');
  final _homeServiceNoticeController = TextEditingController(text: '2');
  final List<String> _homeServiceAreas = [
    'Civil Lines',
    'Swaroop Nagar',
    'Tilak Nagar',
    'Kakadeo',
    'Sharda Nagar',
    'Kidwai Nagar',
  ];

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _homeServiceFeeController.dispose();
    _homeServiceNoticeController.dispose();
    super.dispose();
  }

  void _showSalonImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6D0C7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Upload Salon Showcase Photo',
                style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 17),
              ),
              const SizedBox(height: 4),
              Text(
                'This photo will be displayed on customer listings and the Branch Manager console.',
                style: AppTextStyles.caption(color: AppColors.mutedTextGray),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt_outlined, size: 16),
                      label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Take Camera Photo')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.copper,
                        side: const BorderSide(color: AppColors.copper),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() => _selectedSalonImage = AssetConstants.maleBanner1);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.copper,
                            content: Text('Camera photo captured and attached to salon profile.'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library_outlined, size: 16),
                      label: const FittedBox(fit: BoxFit.scaleDown, child: Text('From Gallery')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.copper,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() => _selectedSalonImage = AssetConstants.partnerLoginIllu);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.copper,
                            content: Text('Gallery photo selected and attached to salon profile.'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Or Choose from Curated Salon Presets:',
                style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _salonImagePresets.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final item = _salonImagePresets[i];
                    final isSel = _selectedSalonImage == item['asset'];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() => _selectedSalonImage = item['asset']!);
                      },
                      child: Container(
                        width: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSel ? AppColors.copper : const Color(0xFFEBE6DF),
                            width: isSel ? 2.5 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(item['asset']!, fit: BoxFit.cover),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 6,
                                left: 6,
                                right: 6,
                                child: Text(
                                  item['title']!,
                                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _useCurrentLocation() {
    setState(() {
      _latController.text = '26.4719';
      _lngController.text = '80.3524';
      _cityController.text = 'Kanpur';
      _areaController.text = 'Civil Lines';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.copper,
        content: Text('Coordinates set from GPS sensor (Kanpur: 26.4719° N, 80.3524° E)'),
      ),
    );
  }

  void _showMapPickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Precise Salon Location',
                    style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 17),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Map preview simulation
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EFEA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Map grid lines
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          6,
                          (i) => Divider(color: Colors.grey.withValues(alpha: 0.2), height: 1),
                        ),
                      ),
                      // Pin Marker
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.warmBlack,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _nameController.text,
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Icon(Icons.location_on_rounded, size: 40, color: AppColors.copper),
                          Container(
                            width: 14,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6),
                            ],
                          ),
                          child: Text(
                            'Address: ${_addressController.text}, ${_areaController.text}, ${_cityController.text}',
                            style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(fontSize: 11),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                text: 'Confirm Location Pin',
                backgroundColor: AppColors.copper,
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.copper,
                      content: Text('Salon pin coordinates confirmed.'),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onCreateSalon() {
    if (!_formKey.currentState!.validate()) return;

    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());

    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.burntOrange,
          content: Text('Please provide valid numerical coordinates for Latitude & Longitude.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final branch1 = BranchModel(
        branchId: 'branch_${DateTime.now().millisecondsSinceEpoch}',
        branchName: '${_nameController.text.trim()} - Main Branch',
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        latitude: lat,
        longitude: lng,
        openingHours: _openingHours,
        closingHours: _closingHours,
        operatingDays: _selectedOperatingDays,
        isHomeServiceEnabled: _enableHomeService,
        isActive: true,
      );

      final newSalon = SalonModel(
        salonId: 'salon_${DateTime.now().millisecondsSinceEpoch}',
        partnerId: PartnerState.instance.partner.id,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        category: _category,
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        latitude: lat,
        longitude: lng,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        openingHours: _openingHours,
        closingHours: _closingHours,
        operatingDays: _selectedOperatingDays,
        facilities: _selectedFacilities,
        photos: [_selectedSalonImage],
        verificationStatus: PartnerVerificationStatus.approved,
        salonStatus: true,
        isHomeServiceEnabled: _enableHomeService,
        branches: [branch1],
      );

      PartnerState.instance.createSalon(newSalon);

      if (_enableHomeService) {
        PartnerState.instance.updateHomeServiceSettings(
          HomeServiceSettingsModel(
            isEnabled: true,
            serviceRadiusKm: _homeServiceRadius,
            homeServiceFee: double.tryParse(_homeServiceFeeController.text) ?? 149.0,
            minimumNoticeHours: int.tryParse(_homeServiceNoticeController.text) ?? 2,
            serviceableAreas: _homeServiceAreas,
            availableDays: _selectedOperatingDays,
          ),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.copper,
          content: Text('Salon setup saved! Next: Assign a Branch Manager.'),
        ),
      );

      // Navigate to create branch manager
      Navigator.pushNamed(context, AppRoutes.partnerCreateManager);
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
          'Create Salon',
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
                        child: const Text('1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Salon Information & Setup',
                              style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                            ),
                            Text(
                              'Step 1 of 2: Create salon profile and operational settings',
                              style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Salon Showcase Photo Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Salon Showcase Photo',
                                style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 14),
                              ),
                              Text(
                                'Displayed on Customer Search & Branch Manager Panel',
                                style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.add_a_photo_outlined, size: 14),
                            label: const Text('Change', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.copper,
                              side: const BorderSide(color: AppColors.copper),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: const Size(0, 32),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: _showSalonImagePickerSheet,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _showSalonImagePickerSheet,
                        child: Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFEBE6DF)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  _selectedSalonImage,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.1),
                                        Colors.black.withValues(alpha: 0.65),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 10,
                                  left: 12,
                                  right: 12,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.copper,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          '✦ PRIMARY SALON FACADE',
                                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.edit, size: 14, color: AppColors.copper),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 1. Basic Information
                _buildSectionHeader('1. Basic Information', 'Salon brand and customer contact details'),
                const SizedBox(height: 12),

                _buildInputField(
                  controller: _nameController,
                  label: 'Salon Name',
                  hint: 'The Royal Velvet Luxury Salon',
                  validator: (v) => Validators.validateRequired(v, 'Salon name'),
                ),
                const SizedBox(height: 12),

                _buildInputField(
                  controller: _descController,
                  label: 'Salon Description',
                  hint: 'Tell customers about your salon experience and luxury offerings...',
                  maxLines: 3,
                  validator: (v) => Validators.validateRequired(v, 'Description'),
                ),
                const SizedBox(height: 12),

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
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: _phoneController,
                        label: 'Contact Number',
                        hint: '+91 512 2309871',
                        keyboardType: TextInputType.phone,
                        validator: Validators.validatePhone,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField(
                        controller: _emailController,
                        label: 'Business Email',
                        hint: 'contact@velvetsalon.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 2. Address & Physical Location
                _buildSectionHeader('2. Address & Physical Location', 'Accurate address helps customers discover your branch'),
                const SizedBox(height: 12),

                _buildInputField(
                  controller: _addressController,
                  label: 'Full Street Address',
                  hint: 'Plot 14/82, The Mall Avenue, Opp. Green Park',
                  validator: (v) => Validators.validateRequired(v, 'Address'),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: _areaController,
                        label: 'Area / Locality',
                        hint: 'Civil Lines',
                        validator: (v) => Validators.validateRequired(v, 'Area'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField(
                        controller: _cityController,
                        label: 'City',
                        hint: 'Kanpur',
                        validator: (v) => Validators.validateRequired(v, 'City'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: _stateController,
                        label: 'State',
                        hint: 'Uttar Pradesh',
                        validator: (v) => Validators.validateRequired(v, 'State'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField(
                        controller: _postalCodeController,
                        label: 'Postal Code',
                        hint: '208001',
                        keyboardType: TextInputType.number,
                        validator: (v) => Validators.validateRequired(v, 'Postal code'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Coordinates & Map Trigger
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.pin_drop_rounded, color: AppColors.copper, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Precise GPS Coordinates',
                            style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              controller: _latController,
                              label: 'Latitude',
                              hint: '26.4719',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInputField(
                              controller: _lngController,
                              label: 'Longitude',
                              hint: '80.3524',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.my_location_rounded, size: 15),
                              label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Use Current GPS')),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                minimumSize: const Size(0, 40),
                                foregroundColor: AppColors.copper,
                                side: const BorderSide(color: AppColors.copper),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: _useCurrentLocation,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.map_outlined, size: 15),
                              label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Pick on Map')),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                minimumSize: const Size(0, 40),
                                backgroundColor: AppColors.copper,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: _showMapPickerModal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Operating Hours & Facilities
                _buildSectionHeader('3. Salon Details & Hours', 'Opening times and luxury facilities'),
                const SizedBox(height: 12),

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
                const SizedBox(height: 14),

                Text(
                  'Operating Days',
                  style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _allDays.map((day) {
                    final isSelected = _selectedOperatingDays.contains(day);
                    return FilterChip(
                      label: Text(day),
                      selected: isSelected,
                      selectedColor: AppColors.copper.withValues(alpha: 0.15),
                      checkmarkColor: AppColors.copper,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.copper : AppColors.charcoal,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedOperatingDays.add(day);
                          } else {
                            if (_selectedOperatingDays.length > 1) {
                              _selectedOperatingDays.remove(day);
                            }
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                Text(
                  'Facilities Available',
                  style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _allFacilities.map((fac) {
                    final isSelected = _selectedFacilities.contains(fac);
                    return FilterChip(
                      label: Text(fac),
                      selected: isSelected,
                      selectedColor: AppColors.copper.withValues(alpha: 0.15),
                      checkmarkColor: AppColors.copper,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        color: isSelected ? AppColors.copper : AppColors.charcoal,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedFacilities.add(fac);
                          } else {
                            _selectedFacilities.remove(fac);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // 4. Home Service Setup Section
                _buildSectionHeader('4. Home Service Capability', 'Offer services directly at customer doorstep'),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Enable Home Service?',
                                  style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Send stylists and beauticians to customer addresses',
                                  style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _enableHomeService,
                            activeThumbColor: AppColors.copper,
                            onChanged: (val) => setState(() => _enableHomeService = val),
                          ),
                        ],
                      ),
                      if (_enableHomeService) ...[
                        const Divider(height: 20),
                        Text(
                          'Maximum Service Radius: ${_homeServiceRadius.toInt()} km',
                          style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                        ),
                        Slider(
                          value: _homeServiceRadius,
                          min: 3,
                          max: 30,
                          divisions: 27,
                          activeColor: AppColors.copper,
                          inactiveColor: AppColors.warmGray,
                          label: '${_homeServiceRadius.toInt()} km',
                          onChanged: (val) => setState(() => _homeServiceRadius = val),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                controller: _homeServiceFeeController,
                                label: 'Home Fee (₹)',
                                hint: '149',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInputField(
                                controller: _homeServiceNoticeController,
                                label: 'Min Notice (Hrs)',
                                hint: '2',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Capability Summary Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.warmGray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.storefront_rounded, size: 16, color: AppColors.copper),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Salon: ON',
                                style: AppTextStyles.caption(color: AppColors.warmBlack).copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 20, width: 1, color: const Color(0xFFD6D0C7)),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home_work_outlined,
                              size: 16,
                              color: _enableHomeService ? Colors.green.shade700 : AppColors.mutedTextGray,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Home: ${_enableHomeService ? "ON" : "OFF"}',
                                style: AppTextStyles.caption(
                                  color: _enableHomeService ? Colors.green.shade800 : AppColors.mutedTextGray,
                                ).copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                AppButton(
                  text: 'Save & Continue to Manager Setup',
                  isLoading: _isLoading,
                  backgroundColor: AppColors.copper,
                  onPressed: _onCreateSalon,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 16),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildInputField({
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
