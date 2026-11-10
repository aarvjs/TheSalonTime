import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/google_maps_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/osm_map_picker_widget.dart';
import '../../data/partner_state.dart';
import '../../models/partner_models.dart';
import '../../services/partner_firestore_service.dart';

class CreateSalonScreen extends StatefulWidget {
  const CreateSalonScreen({super.key});

  @override
  State<CreateSalonScreen> createState() => _CreateSalonScreenState();
}

class _CreateSalonScreenState extends State<CreateSalonScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // ----------------------------------------------------
  // STEP 1: SALON DETAILS
  // ----------------------------------------------------
  final _nameController = TextEditingController(text: 'The Royal Velvet Luxury Salon');
  final _descController = TextEditingController(
    text: 'Award-winning luxury grooming and beauty destination offering bespoke haircuts, Parisian hair spa treatments, organic skin therapies, and doorstep concierge services.',
  );
  String _category = 'Unisex Luxury Salon & Spa';
  final _phoneController = TextEditingController(text: '+91 98390 11223');
  final _emailController = TextEditingController(text: 'contact@velvetsalon.com');

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

  final List<String> _availableCategories = [
    'Unisex Luxury Salon & Spa',
    'Women Beauty & Bridal Lounge',
    'Men Grooming & Master Barber',
    'Holistic Wellness & Ayurvedic Spa',
  ];

  final List<String> _selectedFacilities = [
    'Private VIP Suites',
    'Air Conditioned',
    'Complimentary Beverages',
    'Free High-Speed Wi-Fi',
    'Valet Parking',
  ];

  final List<String> _allFacilities = [
    'Private VIP Suites',
    'Air Conditioned',
    'Complimentary Beverages',
    'Free High-Speed Wi-Fi',
    'Valet Parking',
    'Sterilized Tools',
    'Kids Play Zone',
    'Shower Facility',
  ];

  // ----------------------------------------------------
  // STEP 2: GOOGLE MAPS ADDRESS SELECTION
  // ----------------------------------------------------
  final _searchAddressController = TextEditingController();
  final _addressController = TextEditingController(text: 'Plot 14/82, The Mall Avenue, Opp. Green Park');
  final _cityController = TextEditingController(text: 'Kanpur');
  final _stateController = TextEditingController(text: 'Uttar Pradesh');
  final _postalCodeController = TextEditingController(text: '208001');

  double _latitude = 26.4719;
  double _longitude = 80.3524;
  String _placeId = '';

  Timer? _placesDebounce;
  bool _isSearchingPlaces = false;
  List<GooglePlacePrediction> _placePredictions = [];

  // ----------------------------------------------------
  // STEP 3: SERVICE AREA
  // ----------------------------------------------------
  bool _enableHomeService = true;
  double _serviceRadiusKm = 10.0;
  final _homeServiceFeeController = TextEditingController(text: '149');
  final _homeServiceNoticeController = TextEditingController(text: '2');

  // ----------------------------------------------------
  // STEP 4: BUSINESS CONFIGURATION
  // ----------------------------------------------------
  String _openingHours = '09:00 AM';
  String _closingHours = '08:30 PM';
  final List<String> _allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> _selectedOperatingDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final List<Map<String, dynamic>> _catalogServices = [
    {
      'id': 'srv_1',
      'name': 'Bespoke Haircut & Styling',
      'category': 'Hair Care',
      'price': 499.0,
      'duration': 45,
      'selected': true,
      'homeAvailable': true,
    },
    {
      'id': 'srv_2',
      'name': 'Parisian Royal Hair Spa',
      'category': 'Hair Care',
      'price': 1499.0,
      'duration': 60,
      'selected': true,
      'homeAvailable': true,
    },
    {
      'id': 'srv_3',
      'name': 'Radiant Gold Bridal Facial',
      'category': 'Skin & Facial',
      'price': 2999.0,
      'duration': 75,
      'selected': true,
      'homeAvailable': true,
    },
    {
      'id': 'srv_4',
      'name': 'Gentlemen Signature Beard Sculpting',
      'category': 'Men Grooming',
      'price': 399.0,
      'duration': 30,
      'selected': true,
      'homeAvailable': true,
    },
    {
      'id': 'srv_5',
      'name': 'Deep Tissue Aromatherapy Massage',
      'category': 'Spa & Wellness',
      'price': 1899.0,
      'duration': 60,
      'selected': true,
      'homeAvailable': false,
    },
  ];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _searchAddressController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _homeServiceFeeController.dispose();
    _homeServiceNoticeController.dispose();
    _placesDebounce?.cancel();
    super.dispose();
  }

  // ----------------------------------------------------
  // GOOGLE PLACES SEARCH & SELECTION LOGIC
  // ----------------------------------------------------
  void _onPlacesSearchChanged(String val) {
    _placesDebounce?.cancel();
    if (val.trim().length < 2) {
      setState(() {
        _placePredictions = [];
        _isSearchingPlaces = false;
      });
      return;
    }

    setState(() => _isSearchingPlaces = true);
    _placesDebounce = Timer(const Duration(milliseconds: 350), () async {
      final results = await GoogleMapsService.instance.searchPlaces(val);
      if (mounted) {
        setState(() {
          _placePredictions = results;
          _isSearchingPlaces = false;
        });
      }
    });
  }

  Future<void> _selectPlacePrediction(GooglePlacePrediction p) async {
    setState(() {
      _isSearchingPlaces = true;
      _placePredictions = [];
      _searchAddressController.text = p.mainText;
    });

    final details = await GoogleMapsService.instance.getPlaceDetails(
      p.placeId,
      fallbackDescription: p.description,
    );

    if (mounted && details != null) {
      setState(() {
        _isSearchingPlaces = false;
        _placeId = details.placeId;
        _latitude = details.latitude;
        _longitude = details.longitude;
        _addressController.text = details.formattedAddress;
        if (details.city.isNotEmpty) _cityController.text = details.city;
        if (details.state.isNotEmpty) _stateController.text = details.state;
        if (details.postalCode.isNotEmpty) _postalCodeController.text = details.postalCode;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.copper,
          duration: const Duration(seconds: 2),
          content: Text('Address confirmed via Google Maps: ${details.name}'),
        ),
      );
    } else if (mounted) {
      setState(() => _isSearchingPlaces = false);
    }
  }

  Future<void> _useCurrentGpsLocation() async {
    setState(() => _isSearchingPlaces = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission was denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied. Please enable in settings.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final place = await GoogleMapsService.instance.reverseGeocode(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          if (place != null) {
            _addressController.text = place.formattedAddress;
            _cityController.text = place.city.isNotEmpty ? place.city : 'Kanpur';
            _stateController.text = place.state.isNotEmpty ? place.state : 'Uttar Pradesh';
            _postalCodeController.text = place.postalCode.isNotEmpty ? place.postalCode : '208001';
            _searchAddressController.text = place.name;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.copper,
            content: Text('Current GPS coordinates applied successfully!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: AppColors.burntOrange, content: Text('GPS error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSearchingPlaces = false);
    }
  }

  void _openInteractiveMapPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OsmMapPickerWidget(
        initialLat: _latitude,
        initialLng: _longitude,
        initialAddress: _addressController.text,
        onLocationConfirmed: (loc) {
          setState(() {
            _latitude = loc.latitude;
            _longitude = loc.longitude;
            if (loc.displayName.isNotEmpty) {
              _addressController.text = loc.displayName;
            }
            if (loc.city != null && loc.city!.isNotEmpty) {
              _cityController.text = loc.city!;
            }
            if (loc.state != null && loc.state!.isNotEmpty) {
              _stateController.text = loc.state!;
            }
            if (loc.postalCode != null && loc.postalCode!.isNotEmpty) {
              _postalCodeController.text = loc.postalCode!;
            }
          });
        },
      ),
    );
  }

  Future<void> _selectTime(bool isOpening) async {
    final initial = isOpening
        ? const TimeOfDay(hour: 9, minute: 0)
        : const TimeOfDay(hour: 20, minute: 30);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      setState(() {
        if (isOpening) {
          _openingHours = '$hour:$minute $period';
        } else {
          _closingHours = '$hour:$minute $period';
        }
      });
    }
  }

  // ----------------------------------------------------
  // NAVIGATION BETWEEN STEPS
  // ----------------------------------------------------
  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      if (_nameController.text.trim().length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: AppColors.burntOrange, content: Text('Please enter a valid Salon Name (min 3 chars).')),
        );
        return false;
      }
      if (_phoneController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: AppColors.burntOrange, content: Text('Please enter a valid contact phone number.')),
        );
        return false;
      }
      return true;
    }

    if (_currentStep == 1) {
      if (_addressController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: AppColors.burntOrange, content: Text('Please confirm the street address using Google Maps.')),
        );
        return false;
      }
      if (_latitude == 0.0 || _longitude == 0.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: AppColors.burntOrange, content: Text('Valid real coordinates are required.')),
        );
        return false;
      }
      return true;
    }

    if (_currentStep == 2) {
      if (_enableHomeService && _serviceRadiusKm <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: AppColors.burntOrange, content: Text('Please select a valid service radius.')),
        );
        return false;
      }
      return true;
    }

    if (_currentStep == 3) {
      if (_selectedOperatingDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: AppColors.burntOrange, content: Text('Please select at least one operating day.')),
        );
        return false;
      }
      final selectedServices = _catalogServices.where((s) => s['selected'] == true);
      if (selectedServices.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: AppColors.burntOrange, content: Text('Please select at least one offered service.')),
        );
        return false;
      }
      return true;
    }

    return true;
  }

  void _nextStep() {
    if (!_validateCurrentStep()) return;
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      _onConfirmAndCreateSalon();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  // ----------------------------------------------------
  // STEP 5: SINGLE-SAVE ATOMIC PERSISTENCE
  // ----------------------------------------------------
  Future<void> _onConfirmAndCreateSalon() async {
    if (_isSubmitting) return;

    final partner = PartnerState.instance.partner;
    final isVerified = partner.verificationStatus == PartnerVerificationStatus.approved;
    if (!isVerified) {
      _showVerificationRequiredDialog();
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final salonId = 'salon_${DateTime.now().millisecondsSinceEpoch}';

      final selectedServices = _catalogServices
          .where((s) => s['selected'] == true)
          .map((s) => SalonServiceModel(
                id: s['id'] as String,
                name: s['name'] as String,
                category: s['category'] as String,
                description: '${s['name']} professional luxury service',
                durationMinutes: s['duration'] as int,
                price: (s['price'] as num).toDouble(),
                availableAtSalon: true,
                availableAtHome: s['homeAvailable'] as bool? ?? _enableHomeService,
                isActive: true,
              ))
          .toList();

      final currentAuthUid = FirebaseAuth.instance.currentUser?.uid;
      final effectivePartnerId = (currentAuthUid != null && currentAuthUid.isNotEmpty)
          ? currentAuthUid
          : (partner.id.isNotEmpty && partner.id != 'partner_001'
              ? partner.id
              : 'partner_${DateTime.now().millisecondsSinceEpoch}');

      if (currentAuthUid != null && partner.id != currentAuthUid) {
        PartnerState.instance.setPartner(partner.copyWith(id: currentAuthUid));
      }

      final newSalon = SalonModel(
        salonId: salonId,
        partnerId: effectivePartnerId,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        category: _category,
        address: _addressController.text.trim(),
        city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : 'Kanpur',
        state: _stateController.text.trim().isNotEmpty ? _stateController.text.trim() : 'Uttar Pradesh',
        postalCode: _postalCodeController.text.trim().isNotEmpty ? _postalCodeController.text.trim() : '208001',
        placeId: _placeId,
        latitude: _latitude,
        longitude: _longitude,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        openingHours: _openingHours,
        closingHours: _closingHours,
        operatingDays: _selectedOperatingDays,
        photos: [_selectedSalonImage],
        facilities: _selectedFacilities,
        serviceRadiusKm: _serviceRadiusKm,
        isHomeServiceEnabled: _enableHomeService,
        salonStatus: true,
        verificationStatus: PartnerVerificationStatus.approved,
        services: selectedServices,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool cloudSyncSuccess = false;
      String? syncErrorNote;

      try {
        // 1. Atomic Firestore save to `salons/{salonId}` and mirror to `branches/{salonId}`
        await PartnerFirestoreService.instance.saveSalonLocation(newSalon);
        cloudSyncSuccess = true;
      } catch (err) {
        syncErrorNote = err.toString();
      }

      // 2. Synchronize local state (guaranteed to be added so user flow never breaks)
      PartnerState.instance.addSalon(newSalon);

      if (!mounted) return;

      if (!cloudSyncSuccess && syncErrorNote != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.burntOrange,
            duration: const Duration(seconds: 4),
            content: Text(
              'Salon location saved locally! Cloud note: $syncErrorNote',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        );
      }

      // 3. Display success dialog with prompt to Assign Salon Manager
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 38),
              ),
              const SizedBox(height: 16),
              Text(
                'Salon Location Created!',
                style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '"${newSalon.name}" is now published under your partner account. You can assign a dedicated Salon Manager right away or manage it yourself.',
                style: AppTextStyles.body(color: AppColors.charcoal).copyWith(fontSize: 13, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              AppButton(
                text: 'Assign Salon Manager',
                icon: Icons.person_add_alt_1_rounded,
                backgroundColor: AppColors.copper,
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.partnerCreateManager,
                    arguments: {
                      'salonId': newSalon.salonId,
                      'salonName': newSalon.name,
                    },
                  );
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warmBlack,
                  side: const BorderSide(color: Color(0xFFD6D0C7)),
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacementNamed(context, AppRoutes.partnerBranches);
                },
                child: const Text('View in My Salons', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: AppColors.burntOrange, content: Text('Error saving salon location: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showVerificationRequiredDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.shield_outlined, color: AppColors.copper, size: 24),
            const SizedBox(width: 8),
            Text(
              'Verification Required',
              style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 16),
            ),
          ],
        ),
        content: Text(
          'Your account verification is currently pending review. Salon locations can only be published once your partner business verification is approved by Admin.',
          style: AppTextStyles.body(color: AppColors.charcoal).copyWith(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Back', style: TextStyle(color: AppColors.mutedTextGray)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.copper,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(context, AppRoutes.partnerVerificationStatus);
            },
            child: const Text('Check Status'),
          ),
        ],
      ),
    );
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
              const SizedBox(height: 16),
              Text(
                'Select Salon Showcase Image',
                style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 17),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose a premier studio visual to present your salon on customer search & maps:',
                style: AppTextStyles.caption(color: AppColors.mutedTextGray),
              ),
              const SizedBox(height: 14),
              ..._salonImagePresets.map((preset) {
                final isSelected = _selectedSalonImage == preset['asset'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.copper : const Color(0xFFEBE6DF),
                      width: isSelected ? 2 : 1,
                    ),
                    color: isSelected ? AppColors.copper.withValues(alpha: 0.05) : Colors.white,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(preset['asset']!, width: 56, height: 56, fit: BoxFit.cover),
                    ),
                    title: Text(preset['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(preset['tag']!, style: const TextStyle(fontSize: 11, color: AppColors.copper)),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.copper)
                        : const Icon(Icons.radio_button_off_rounded, color: Color(0xFFD6D0C7)),
                    onTap: () {
                      setState(() => _selectedSalonImage = preset['asset']!);
                      Navigator.pop(ctx);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // BUILD METHOD & STEPPER LAYOUT
  // ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: AppColors.warmIvory,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Add Salon Location',
          style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.warmBlack),
          onPressed: _prevStep,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Stepper Bar
            _buildStepperHeader(),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Form(
                  key: _formKey,
                  child: _buildCurrentStepView(),
                ),
              ),
            ),

            // Bottom Navigation Buttons
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperHeader() {
    final stepLabels = ['Details', 'Location', 'Radius', 'Hours', 'Review'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(5, (index) {
          final isPast = index < _currentStep;
          final isCurrent = index == _currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isPast
                              ? Colors.green
                              : isCurrent
                                  ? AppColors.copper
                                  : const Color(0xFFEBE6DF),
                        ),
                        child: Center(
                          child: isPast
                              ? const Icon(Icons.check, color: Colors.white, size: 16)
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: isCurrent ? Colors.white : AppColors.mutedTextGray,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stepLabels[index],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                          color: isCurrent ? AppColors.copper : AppColors.mutedTextGray,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < 4)
                  Container(
                    width: 14,
                    height: 2,
                    color: index < _currentStep ? Colors.green : const Color(0xFFEBE6DF),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Details();
      case 1:
        return _buildStep2GoogleMapsAddress();
      case 2:
        return _buildStep3ServiceRadius();
      case 3:
        return _buildStep4BusinessConfig();
      case 4:
        return _buildStep5Review();
      default:
        return _buildStep1Details();
    }
  }

  // ----------------------------------------------------
  // STEP 1 WIDGET: SALON DETAILS
  // ----------------------------------------------------
  Widget _buildStep1Details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Step 1: Salon Details', 'Enter the primary business identity and presentation visuals.'),
        const SizedBox(height: 14),

        // Showcase Photo Card
        Container(
          padding: const EdgeInsets.all(14),
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
                  const Text('Showcase Image / Logo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: AppColors.copper),
                    icon: const Icon(Icons.photo_library_outlined, size: 16),
                    label: const Text('Change Preset', style: TextStyle(fontSize: 12)),
                    onPressed: _showSalonImagePickerSheet,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: Image.asset(_selectedSalonImage, fit: BoxFit.cover),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _buildTextField(
          controller: _nameController,
          label: 'Salon Location Name',
          hint: 'e.g. The Royal Velvet — Mall Road',
          icon: Icons.storefront_rounded,
        ),
        const SizedBox(height: 14),

        _buildTextField(
          controller: _descController,
          label: 'Description',
          hint: 'Brief description of ambiance, signature styling, and specializations',
          maxLines: 3,
          icon: Icons.notes_rounded,
        ),
        const SizedBox(height: 14),

        // Category Dropdown
        const Text('Salon Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.warmBlack)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD6D0C7)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _category,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.copper),
              items: _availableCategories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _category = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _phoneController,
                label: 'Contact Phone',
                hint: '+91 98390...',
                keyboardType: TextInputType.phone,
                icon: Icons.phone_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'salon@domain.com',
                keyboardType: TextInputType.emailAddress,
                icon: Icons.email_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Facilities Chips
        const Text('Salon Amenities & Facilities', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.warmBlack)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allFacilities.map((f) {
            final isSelected = _selectedFacilities.contains(f);
            return FilterChip(
              label: Text(f, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.warmBlack)),
              selected: isSelected,
              selectedColor: AppColors.copper,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _selectedFacilities.add(f);
                  } else {
                    _selectedFacilities.remove(f);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ----------------------------------------------------
  // STEP 2 WIDGET: GOOGLE MAPS ADDRESS SELECTION
  // ----------------------------------------------------
  Widget _buildStep2GoogleMapsAddress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Step 2: Google Maps Address Selection',
          'Search with Google Places Autocomplete or pinpoint on the live map.',
        ),
        const SizedBox(height: 14),

        // Google Places Search Input
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.copper.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: _searchAddressController,
            onChanged: _onPlacesSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search salon location on Google Maps...',
              hintStyle: const TextStyle(fontSize: 13, color: AppColors.mutedTextGray),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.copper),
              suffixIcon: _isSearchingPlaces
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.copper)),
                    )
                  : IconButton(
                      icon: const Icon(Icons.my_location_rounded, color: AppColors.copper),
                      tooltip: 'Use Current GPS',
                      onPressed: _useCurrentGpsLocation,
                    ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),

        // Dropdown Google Places Predictions
        if (_placePredictions.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEBE6DF)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _placePredictions.length,
              separatorBuilder: (ctx, _) => const Divider(height: 1, color: Color(0xFFEBE6DF)),
              itemBuilder: (ctx, i) {
                final pred = _placePredictions[i];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_on_rounded, color: AppColors.copper, size: 20),
                  title: Text(pred.mainText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(pred.secondaryText, style: const TextStyle(fontSize: 11, color: AppColors.mutedTextGray)),
                  onTap: () => _selectPlacePrediction(pred),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 14),

        // Live Google Static Map Preview Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEBE6DF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        GoogleMapsService.instance.getStaticMapUrl(_latitude, _longitude, zoom: 16),
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) {
                          return Container(
                            color: const Color(0xFFF2EFE9),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.pin_drop_rounded, size: 38, color: AppColors.copper),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Google Maps Pin Marker',
                                    style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                                  ),
                                  Text(
                                    'Lat: ${_latitude.toStringAsFixed(4)}°, Lng: ${_longitude.toStringAsFixed(4)}°',
                                    style: const TextStyle(fontSize: 11, color: AppColors.mutedTextGray),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.warmBlack,
                            elevation: 3,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.tune_rounded, size: 14, color: AppColors.copper),
                          label: const Text('Fine-tune Pin', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          onPressed: _openInteractiveMapPicker,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.verified_outlined, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Verified Coordinates: ${_latitude.toStringAsFixed(4)}°, ${_longitude.toStringAsFixed(4)}°',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        _buildTextField(
          controller: _addressController,
          label: 'Confirmed Street Address',
          hint: 'Shop / Plot No, Street, Landmark',
          icon: Icons.business_outlined,
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: _cityController,
                label: 'City',
                hint: 'Kanpur',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: _stateController,
                label: 'State',
                hint: 'Uttar Pradesh',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: _postalCodeController,
                label: 'Postal Code',
                hint: '208001',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ----------------------------------------------------
  // STEP 3 WIDGET: SERVICE AREA & HOME SERVICE
  // ----------------------------------------------------
  Widget _buildStep3ServiceRadius() {
    final quickRadiusOptions = [3.0, 5.0, 10.0, 15.0, 25.0, 50.0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Step 3: Service Area', 'Configure physical walk-in operations and doorstep home services.'),
        const SizedBox(height: 14),

        // Information Callout Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F6F0),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.copper.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.copper, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('How Service Areas Work', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.warmBlack)),
                    const SizedBox(height: 4),
                    Text(
                      '• Physical Salon: Customers visit your salon address directly for in-store bookings.\n• Service Radius: If doorstep services are enabled, customers within this radius can book your stylists at home.',
                      style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(fontSize: 11, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Home Service Switch Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEBE6DF)),
          ),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Offer Doorstep Home Services', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: const Text('Allow clients to book salon stylists to their homes', style: TextStyle(fontSize: 11, color: AppColors.mutedTextGray)),
            value: _enableHomeService,
            activeThumbColor: AppColors.copper,
            onChanged: (val) => setState(() => _enableHomeService = val),
          ),
        ),
        const SizedBox(height: 16),

        if (_enableHomeService) ...[
          Text(
            'Doorstep Service Coverage Radius: ${_serviceRadiusKm.toStringAsFixed(0)} km',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.warmBlack),
          ),
          const SizedBox(height: 8),

          // Quick Radius Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: quickRadiusOptions.map((r) {
              final isSel = _serviceRadiusKm == r;
              return ChoiceChip(
                label: Text('${r.toStringAsFixed(0)} km'),
                selected: isSel,
                selectedColor: AppColors.copper,
                labelStyle: TextStyle(
                  color: isSel ? Colors.white : AppColors.warmBlack,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                onSelected: (_) => setState(() => _serviceRadiusKm = r),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Precise Slider
          Slider(
            value: _serviceRadiusKm,
            min: 1.0,
            max: 50.0,
            divisions: 49,
            activeColor: AppColors.copper,
            inactiveColor: const Color(0xFFEBE6DF),
            label: '${_serviceRadiusKm.toStringAsFixed(0)} km',
            onChanged: (val) => setState(() => _serviceRadiusKm = val),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _homeServiceFeeController,
                  label: 'Doorstep Travel Fee (₹)',
                  hint: '149',
                  keyboardType: TextInputType.number,
                  icon: Icons.payments_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  controller: _homeServiceNoticeController,
                  label: 'Min Notice (Hours)',
                  hint: '2',
                  keyboardType: TextInputType.number,
                  icon: Icons.timer_outlined,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  // ----------------------------------------------------
  // STEP 4 WIDGET: BUSINESS CONFIGURATION
  // ----------------------------------------------------
  Widget _buildStep4BusinessConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Step 4: Business Configuration', 'Set weekly working days, operating hours, and services.'),
        const SizedBox(height: 14),

        // Working Days Chips
        const Text('Working Days', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.warmBlack)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _allDays.map((day) {
            final isSel = _selectedOperatingDays.contains(day);
            return FilterChip(
              label: Text(day, style: TextStyle(fontSize: 12, color: isSel ? Colors.white : AppColors.warmBlack)),
              selected: isSel,
              selectedColor: AppColors.copper,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _selectedOperatingDays.add(day);
                  } else if (_selectedOperatingDays.length > 1) {
                    _selectedOperatingDays.remove(day);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Operating Hours
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Opening Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.warmBlack)),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () => _selectTime(true),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFD6D0C7)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_openingHours, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const Icon(Icons.access_time_rounded, size: 16, color: AppColors.copper),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Closing Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.warmBlack)),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () => _selectTime(false),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFD6D0C7)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_closingHours, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const Icon(Icons.access_time_rounded, size: 16, color: AppColors.copper),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Services & Pricing List
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Salon Services Catalog', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.warmBlack)),
            Text(
              '${_catalogServices.where((s) => s['selected'] == true).length} Selected',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.copper),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ..._catalogServices.map((srv) {
          final isSel = srv['selected'] as bool;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSel ? AppColors.copper : const Color(0xFFEBE6DF)),
            ),
            child: CheckboxListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              activeColor: AppColors.copper,
              value: isSel,
              title: Text(srv['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text(
                '${srv['category']} • ${srv['duration']} mins • ₹${(srv['price'] as num).toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 11, color: AppColors.mutedTextGray),
              ),
              onChanged: (val) {
                setState(() => srv['selected'] = val ?? false);
              },
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  // ----------------------------------------------------
  // STEP 5 WIDGET: REVIEW AND CREATE
  // ----------------------------------------------------
  Widget _buildStep5Review() {
    final selectedServicesCount = _catalogServices.where((s) => s['selected'] == true).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Step 5: Review & Confirm', 'Verify all location parameters before publishing to the platform.'),
        const SizedBox(height: 14),

        // Big Summary Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEBE6DF)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Header
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: Image.asset(_selectedSalonImage, fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _nameController.text.trim(),
                            style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 16),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Ready to Publish', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(_category, style: const TextStyle(fontSize: 12, color: AppColors.copper, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFFEBE6DF), height: 1),
                    const SizedBox(height: 12),

                    _buildReviewRow(Icons.location_on_rounded, 'Address:', '${_addressController.text.trim()}, ${_cityController.text.trim()}'),
                    _buildReviewRow(Icons.my_location_rounded, 'Coordinates:', '${_latitude.toStringAsFixed(4)}°, ${_longitude.toStringAsFixed(4)}°'),
                    _buildReviewRow(Icons.radar_rounded, 'Coverage Radius:', _enableHomeService ? '${_serviceRadiusKm.toStringAsFixed(0)} km (Home Service Enabled)' : 'In-Store Physical Only'),
                    _buildReviewRow(Icons.access_time_rounded, 'Hours:', '$_openingHours - $_closingHours'),
                    _buildReviewRow(Icons.calendar_today_rounded, 'Working Days:', _selectedOperatingDays.join(', ')),
                    _buildReviewRow(Icons.spa_rounded, 'Services:', '$selectedServicesCount Services configured'),
                    _buildReviewRow(Icons.phone_outlined, 'Contact:', '${_phoneController.text.trim()} • ${_emailController.text.trim()}'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildReviewRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.copper),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.warmBlack)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: AppColors.charcoal),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 17)),
        const SizedBox(height: 2),
        Text(subtitle, style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 12)),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.warmBlack)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD6D0C7)),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 13, color: AppColors.warmBlack),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 13, color: AppColors.mutedTextGray),
              prefixIcon: icon != null ? Icon(icon, color: AppColors.copper, size: 20) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            validator: (v) => Validators.validateRequired(v, label),
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // BOTTOM NAVIGATION BAR
  // ----------------------------------------------------
  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFEBE6DF))),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warmBlack,
                  side: const BorderSide(color: Color(0xFFD6D0C7)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _prevStep,
                child: const Text('Back', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: AppButton(
              text: _currentStep == 4 ? 'Confirm & Create Salon' : 'Next Step',
              icon: _currentStep == 4 ? Icons.check_circle_outline_rounded : Icons.arrow_forward_rounded,
              backgroundColor: AppColors.copper,
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _nextStep,
            ),
          ),
        ],
      ),
    );
  }
}
