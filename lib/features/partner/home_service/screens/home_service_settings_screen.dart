import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/osm_map_picker_widget.dart';
import '../../data/partner_state.dart';
import '../../models/partner_models.dart';

class HomeServiceSettingsScreen extends StatefulWidget {
  const HomeServiceSettingsScreen({super.key});

  @override
  State<HomeServiceSettingsScreen> createState() => _HomeServiceSettingsScreenState();
}

class _HomeServiceSettingsScreenState extends State<HomeServiceSettingsScreen> {
  late bool _isAvailable;
  late double _radiusKm;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _feeController;
  late TextEditingController _baseAddressController;
  late TextEditingController _baseCityController;
  late int _experienceYears;
  double _baseLat = 26.4719;
  double _baseLng = 80.3524;

  late List<String> _skills;
  late List<SalonServiceModel> _homeServices;

  final List<String> _availableSkillOptions = [
    'Haircut & Styling',
    'Beard Grooming',
    'Facial Care & Clean-up',
    'Head Massage',
    'Hair Color & Highlights',
    'Bridal Makeup',
    'Manicure & Pedicure',
    'Skin Whitening Treatment',
  ];

  @override
  void initState() {
    super.initState();
    final current = PartnerState.instance.homeProfile;
    _isAvailable = current.isAvailable;
    _radiusKm = current.serviceRadiusKm;
    _nameController = TextEditingController(text: current.professionalName);
    _phoneController = TextEditingController(text: current.phone);
    _feeController = TextEditingController(
      text: PartnerState.instance.homeService.homeServiceFee.toStringAsFixed(0),
    );
    _baseAddressController = TextEditingController(text: current.baseAddress);
    _baseCityController = TextEditingController(text: current.baseCity);
    _experienceYears = current.experienceYears;
    _baseLat = current.latitude;
    _baseLng = current.longitude;
    _skills = List.from(current.skills);
    _homeServices = List.from(
      PartnerState.instance.services.where((s) => s.availableAtHome).toList(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _feeController.dispose();
    _baseAddressController.dispose();
    _baseCityController.dispose();
    super.dispose();
  }

  void _showAddServiceSheet() {
    final srvNameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '45');
    String srvCategory = 'Hair Styling';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Doorstep Service',
                style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 17),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: srvNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Service Name',
                  hintText: 'e.g. Signature Grooming at Home',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price (₹)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: durationCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Duration (Mins)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppButton(
                text: 'Add Service',
                backgroundColor: AppColors.copper,
                onPressed: () {
                  final name = srvNameCtrl.text.trim();
                  final p = double.tryParse(priceCtrl.text.trim()) ?? 299.0;
                  final d = int.tryParse(durationCtrl.text.trim()) ?? 30;
                  if (name.isEmpty) return;

                  final newSrv = SalonServiceModel(
                    id: 'srv_home_${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    category: srvCategory,
                    description: 'Professional service at customer location',
                    durationMinutes: d,
                    price: p,
                    availableAtSalon: false,
                    availableAtHome: true,
                    isActive: true,
                  );

                  setState(() {
                    _homeServices.add(newSrv);
                  });
                  PartnerState.instance.addService(newSrv);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveAllSettings() {
    final fee = double.tryParse(_feeController.text.trim()) ?? 149.0;

    final updatedProfile = HomeServiceProfileModel(
      partnerId: PartnerState.instance.partner.id,
      isAvailable: _isAvailable,
      professionalName: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : PartnerState.instance.partner.fullName,
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : PartnerState.instance.partner.phone,
      email: PartnerState.instance.partner.email,
      skills: _skills,
      experienceYears: _experienceYears,
      serviceRadiusKm: _radiusKm,
      baseAddress: _baseAddressController.text.trim(),
      baseCity: _baseCityController.text.trim(),
      latitude: _baseLat,
      longitude: _baseLng,
      services: _homeServices,
    );

    PartnerState.instance.updateHomeServiceProfile(updatedProfile);

    PartnerState.instance.updateHomeServiceSettings(
      PartnerState.instance.homeService.copyWith(
        isEnabled: _isAvailable,
        serviceRadiusKm: _radiusKm,
        homeServiceFee: fee,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.copper,
        content: Text(
          _isAvailable
              ? 'Home Service Professional profile & radius updated!'
              : 'Home Service paused.',
        ),
      ),
    );

    Navigator.pop(context);
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
          'Home Service Professional',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Online / Offline Availability Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isAvailable ? Colors.green.shade400 : const Color(0xFFEBE6DF),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isAvailable ? Colors.green.shade50 : AppColors.warmGray,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.home_repair_service_rounded,
                        color: _isAvailable ? Colors.green.shade700 : AppColors.mutedTextGray,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isAvailable ? 'Taking Home Bookings (Online)' : 'Paused (Offline)',
                            style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isAvailable
                                ? 'Nearby customers can discover & book doorstep services'
                                : 'You are currently not appearing in home search',
                            style: AppTextStyles.caption(
                              color: _isAvailable ? Colors.green.shade800 : AppColors.mutedTextGray,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isAvailable,
                      activeThumbColor: Colors.green,
                      activeTrackColor: Colors.green.shade100,
                      onChanged: (val) {
                        setState(() => _isAvailable = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Professional Bio & Experience
              Text(
                'Professional Stylist Details',
                style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 15),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEBE6DF)),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Stylist / Expert Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Direct Contact Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Experience (Years of Practice):',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.warmBlack),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [1, 2, 3, 5, 8, 10, 12, 15].map((yrs) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text('$yrs yrs'),
                                    selected: _experienceYears == yrs,
                                    selectedColor: AppColors.copper,
                                    labelStyle: TextStyle(
                                      color: _experienceYears == yrs ? Colors.white : AppColors.warmBlack,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    onSelected: (sel) {
                                      if (sel) setState(() => _experienceYears = yrs);
                                    },
                                  ),
                                )).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Skills & Specializations
              Text(
                'Skills & Specializations',
                style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 15),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableSkillOptions.map((skill) {
                  final has = _skills.contains(skill);
                  return FilterChip(
                    label: Text(skill),
                    selected: has,
                    selectedColor: AppColors.copper.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.copper,
                    labelStyle: TextStyle(
                      color: has ? AppColors.copper : AppColors.charcoal,
                      fontWeight: has ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (sel) {
                      setState(() {
                        if (sel) {
                          _skills.add(skill);
                        } else {
                          _skills.remove(skill);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Base Dispatch Coordinates & Travel Radius
              Text(
                'Base Location & Travel Radius',
                style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 15),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => OsmMapPickerWidget(
                      initialLat: _baseLat,
                      initialLng: _baseLng,
                      initialAddress: '${_baseAddressController.text}, ${_baseCityController.text}',
                      onLocationConfirmed: (loc) {
                        setState(() {
                          _baseLat = loc.latitude;
                          _baseLng = loc.longitude;
                          if (loc.displayName.isNotEmpty) {
                            _baseAddressController.text = loc.shortTitle;
                          }
                          if (loc.city != null && loc.city!.isNotEmpty) {
                            _baseCityController.text = loc.city!;
                          }
                        });
                      },
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.copper.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.pin_drop_rounded, color: AppColors.copper, size: 26),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _baseAddressController.text.isNotEmpty
                                  ? _baseAddressController.text
                                  : 'Pin Base Location (OpenStreetMap)',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.warmBlack),
                            ),
                            Text(
                              'City: ${_baseCityController.text} • Lat: ${_baseLat.toStringAsFixed(4)}°, Long: ${_baseLng.toStringAsFixed(4)}°',
                              style: const TextStyle(fontSize: 11, color: AppColors.mutedTextGray),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.copper),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Service Radius Options (5, 10, 15, 20 km)
              Text(
                'Service Radius: ${_radiusKm.toInt()} km',
                style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [5, 10, 15, 20, 25, 30].map((r) {
                    final isSel = _radiusKm.toInt() == r;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('$r km'),
                        selected: isSel,
                        selectedColor: AppColors.copper,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : AppColors.warmBlack,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (sel) {
                          if (sel) setState(() => _radiusKm = r.toDouble());
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Home Visit Fee
              TextField(
                controller: _feeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Home Visit Travel Fee (₹)',
                  hintText: '149',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Dynamic Home Services Catalog
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Doorstep Services & Pricing (${_homeServices.length})',
                      style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 16, color: AppColors.copper),
                    label: const Text('+ Add Service', style: TextStyle(color: AppColors.copper, fontWeight: FontWeight.bold, fontSize: 12)),
                    onPressed: _showAddServiceSheet,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ..._homeServices.map((s) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.name,
                              style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                            ),
                            Text(
                              'Duration: ${s.durationMinutes} mins • Category: ${s.category}',
                              style: const TextStyle(fontSize: 11, color: AppColors.mutedTextGray),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${s.price.toStringAsFixed(0)}',
                        style: AppTextStyles.bodyBold(color: AppColors.copper).copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),
              AppButton(
                text: 'Save Home Service Profile',
                backgroundColor: AppColors.copper,
                onPressed: _saveAllSettings,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
