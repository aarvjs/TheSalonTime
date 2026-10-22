import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/partner_state.dart';
import '../../models/partner_models.dart';

class HomeServiceSettingsScreen extends StatefulWidget {
  const HomeServiceSettingsScreen({super.key});

  @override
  State<HomeServiceSettingsScreen> createState() => _HomeServiceSettingsScreenState();
}

class _HomeServiceSettingsScreenState extends State<HomeServiceSettingsScreen> {
  late bool _isEnabled;
  late double _radiusKm;
  late TextEditingController _feeController;
  late TextEditingController _noticeController;
  late List<String> _areas;
  final _newAreaController = TextEditingController();

  final List<String> _timeSlots = [
    '09:00 AM - 11:30 AM',
    '11:30 AM - 02:00 PM',
    '02:30 PM - 05:00 PM',
    '05:00 PM - 07:30 PM',
    '07:30 PM - 09:30 PM',
  ];

  @override
  void initState() {
    super.initState();
    final current = PartnerState.instance.homeService;
    _isEnabled = current.isEnabled;
    _radiusKm = current.serviceRadiusKm;
    _feeController = TextEditingController(text: current.homeServiceFee.toStringAsFixed(0));
    _noticeController = TextEditingController(text: current.minimumNoticeHours.toString());
    _areas = List.from(current.serviceableAreas);
  }

  @override
  void dispose() {
    _feeController.dispose();
    _noticeController.dispose();
    _newAreaController.dispose();
    super.dispose();
  }

  void _addArea() {
    final text = _newAreaController.text.trim();
    if (text.isNotEmpty && !_areas.contains(text)) {
      setState(() {
        _areas.add(text);
        _newAreaController.clear();
      });
    }
  }

  void _removeArea(String area) {
    setState(() {
      _areas.remove(area);
    });
  }

  void _saveSettings() {
    final fee = double.tryParse(_feeController.text.trim()) ?? 149.0;
    final notice = int.tryParse(_noticeController.text.trim()) ?? 2;

    final updated = HomeServiceSettingsModel(
      isEnabled: _isEnabled,
      serviceRadiusKm: _radiusKm,
      homeServiceFee: fee,
      serviceableAreas: _areas,
      availableDays: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      timeSlots: _timeSlots,
      minimumNoticeHours: notice,
    );

    PartnerState.instance.updateHomeServiceSettings(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.copper,
        content: Text(
          _isEnabled
              ? 'Home Service settings saved and operational!'
              : 'Home Service paused. Salon visits remain fully active.',
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final homeServices = PartnerState.instance.services.where((s) => s.availableAtHome).toList();

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: AppColors.warmIvory,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Home Service Settings',
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
              // Main Toggle Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isEnabled ? AppColors.copper.withValues(alpha: 0.6) : const Color(0xFFEBE6DF),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isEnabled ? AppColors.copper.withValues(alpha: 0.12) : AppColors.warmGray,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.home_work_rounded,
                        color: _isEnabled ? AppColors.copper : AppColors.mutedTextGray,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Doorstep Concierge Service',
                            style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isEnabled
                                ? 'Active: Customers can request salon experts at home'
                                : 'Paused: In-salon appointments only',
                            style: AppTextStyles.caption(
                              color: _isEnabled ? Colors.green.shade800 : AppColors.mutedTextGray,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isEnabled,
                      activeThumbColor: AppColors.copper,
                      onChanged: (val) {
                        setState(() => _isEnabled = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // When Disabled, show explanatory notice
              if (!_isEnabled)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.warmGray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.copper, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Home Service is currently disabled. Customers will only be able to book physical appointments at your salon branches.',
                          style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),

              if (_isEnabled) ...[
                // Radius Slider
                Text(
                  'Serviceable Radius: ${_radiusKm.toInt()} km',
                  style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Maximum dispatch distance from your salon location',
                  style: AppTextStyles.caption(color: AppColors.mutedTextGray),
                ),
                Slider(
                  value: _radiusKm,
                  min: 2,
                  max: 30,
                  divisions: 28,
                  activeColor: AppColors.copper,
                  inactiveColor: AppColors.warmGray,
                  label: '${_radiusKm.toInt()} km',
                  onChanged: (val) => setState(() => _radiusKm = val),
                ),
                const SizedBox(height: 14),

                // Pricing & Notice
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Home Visit Fee (₹)',
                            style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _feeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: '149',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
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
                          Text(
                            'Min Notice (Hours)',
                            style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _noticeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: '2',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Serviceable Localities
                Text(
                  'Serviceable Localities & Sectors',
                  style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newAreaController,
                        decoration: InputDecoration(
                          hintText: 'Add locality (e.g. Kakadeo)',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.copper,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _addArea,
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _areas.map((area) {
                    return Chip(
                      label: Text(area, style: const TextStyle(fontSize: 12)),
                      backgroundColor: Colors.white,
                      deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.copper),
                      onDeleted: () => _removeArea(area),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFFEBE6DF)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Services Enabled for Home Service
                Text(
                  'Services Available at Doorstep (${homeServices.length})',
                  style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'You can configure home availability for each service under the Services catalog',
                  style: AppTextStyles.caption(color: AppColors.mutedTextGray),
                ),
                const SizedBox(height: 8),
                ...homeServices.map((s) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFEBE6DF)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.name,
                          style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                        ),
                        Text(
                          '₹${s.offerPrice?.toStringAsFixed(0) ?? s.price.toStringAsFixed(0)}',
                          style: AppTextStyles.bodyBold(color: AppColors.copper).copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }),
              ],

              const SizedBox(height: 24),
              AppButton(
                text: 'Save Home Service Settings',
                backgroundColor: AppColors.copper,
                onPressed: _saveSettings,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
