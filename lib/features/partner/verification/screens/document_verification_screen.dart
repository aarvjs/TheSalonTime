import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/partner_state.dart';
import '../../models/partner_models.dart';

class DocumentVerificationScreen extends StatefulWidget {
  const DocumentVerificationScreen({super.key});

  @override
  State<DocumentVerificationScreen> createState() => _DocumentVerificationScreenState();
}

class _DocumentVerificationScreenState extends State<DocumentVerificationScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _legalNameController;
  late TextEditingController _businessNameController;
  late TextEditingController _regNumberController;
  late TextEditingController _businessAddressController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  String _selectedBusinessType = 'Proprietorship';
  final List<String> _businessTypes = [
    'Proprietorship',
    'Partnership Firm',
    'Private Limited Company',
    'Limited Liability Partnership (LLP)',
  ];

  String _selectedDocType = 'Business Registration Proof';
  final List<String> _docTypes = [
    'Business Registration Proof',
    'GST Registration Certificate',
    'Government Identity Proof (Aadhaar/PAN)',
    'Commercial Address Proof / Lease Agreement',
  ];

  final List<PartnerDocumentModel> _uploadedDocs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final partner = PartnerState.instance.partner;
    _legalNameController = TextEditingController(text: partner.fullName);
    _businessNameController = TextEditingController(text: partner.businessName);
    _regNumberController = TextEditingController(text: '09AAACG1234F1Z5');
    _businessAddressController = TextEditingController(text: 'Plot 14/82, The Mall Avenue, Opp. Green Park, Kanpur');
    _emailController = TextEditingController(text: partner.email);
    _phoneController = TextEditingController(text: partner.phone);

    // Populate with existing documents from state if available
    _uploadedDocs.addAll(PartnerState.instance.documents);
  }

  @override
  void dispose() {
    _legalNameController.dispose();
    _businessNameController.dispose();
    _regNumberController.dispose();
    _businessAddressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _mockUploadFile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Attach Verification File',
                    style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Upload PDF or image under 5MB for $_selectedDocType',
                style: AppTextStyles.caption(color: AppColors.mutedTextGray),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.copper.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.copper),
                ),
                title: Text(
                  'Select PDF Document',
                  style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 14),
                ),
                subtitle: const Text('Certificate or scanned government document'),
                onTap: () {
                  Navigator.pop(ctx);
                  _addMockDocument('.pdf');
                },
              ),
              const Divider(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.champagneGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.image_outlined, color: AppColors.champagneGold),
                ),
                title: Text(
                  'Take Photo / Gallery',
                  style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 14),
                ),
                subtitle: const Text('Clear high-resolution photo of official document'),
                onTap: () {
                  Navigator.pop(ctx);
                  _addMockDocument('.jpg');
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _addMockDocument(String ext) {
    final cleanType = _selectedDocType.replaceAll(' ', '_');
    final newDoc = PartnerDocumentModel(
      id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
      documentType: _selectedDocType,
      fileName: '${cleanType}_Uploaded$ext',
      documentNumber: _regNumberController.text.trim().isNotEmpty ? _regNumberController.text.trim() : null,
      uploadDate: DateTime.now(),
      status: PartnerVerificationStatus.submitted,
    );

    setState(() {
      _uploadedDocs.add(newDoc);
    });
    PartnerState.instance.addDocument(newDoc);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.copper,
        content: Text('Attached: ${newDoc.fileName} (Draft Uploaded)'),
      ),
    );
  }

  void _removeDoc(String docId) {
    setState(() {
      _uploadedDocs.removeWhere((d) => d.id == docId);
    });
    PartnerState.instance.removeDocument(docId);
  }

  void _onSaveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.charcoal,
        content: Text('Verification details saved locally as draft.'),
      ),
    );
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_uploadedDocs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.burntOrange,
          content: Text('Please attach at least one business or identity document to submit.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      PartnerState.instance.submitVerification();

      // Navigate to status screen
      Navigator.pushReplacementNamed(context, AppRoutes.partnerVerificationStatus);
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
          'Business Verification',
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
                // Top Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.copper.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.verified_outlined, color: AppColors.copper, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Verify Your Business',
                                  style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Submit required details to get your salon listed on The Salon Times.',
                                  style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(height: 1.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.warmGray,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.copper),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Note: Documents must be reviewed by Admin before salon publishing is unlocked.',
                                style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Section 1: Business Details
                Text(
                  '1. Business Details',
                  style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 16),
                ),
                const SizedBox(height: 12),

                // Legal Name
                _buildField(
                  controller: _legalNameController,
                  label: 'Legal / Owner Name',
                  hint: 'Full legal name as on ID card',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                // Business Name
                _buildField(
                  controller: _businessNameController,
                  label: 'Official Salon Name',
                  hint: 'Trade or business name',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                // Business Type Dropdown
                Text(
                  'Business Entity Type',
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
                      value: _selectedBusinessType,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.copper),
                      style: AppTextStyles.body(color: AppColors.warmBlack).copyWith(fontSize: 14),
                      items: _businessTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedBusinessType = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Registration / GST Number
                _buildField(
                  controller: _regNumberController,
                  label: 'GST / Business Registration / PAN',
                  hint: 'e.g. 09AAACG1234F1Z5',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                // Business Address
                _buildField(
                  controller: _businessAddressController,
                  label: 'Registered Business Address',
                  hint: 'Complete address with city & postal code',
                  maxLines: 2,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),

                // Section 2: Document Upload
                Text(
                  '2. Verification Documents',
                  style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select the document type and attach a clear scanned copy.',
                  style: AppTextStyles.caption(color: AppColors.mutedTextGray),
                ),
                const SizedBox(height: 12),

                // Document Type Selector
                Text(
                  'Select Document to Attach',
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
                      value: _selectedDocType,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.copper),
                      style: AppTextStyles.body(color: AppColors.warmBlack).copyWith(fontSize: 14),
                      items: _docTypes.map((doc) {
                        return DropdownMenuItem<String>(
                          value: doc,
                          child: Text(doc, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDocType = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Upload Box
                InkWell(
                  onTap: _mockUploadFile,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.copper.withValues(alpha: 0.6),
                        style: BorderStyle.solid,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.copper.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.cloud_upload_outlined, color: AppColors.copper, size: 28),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tap to Upload File',
                          style: AppTextStyles.bodyBold(color: AppColors.copper).copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'PDF, JPG or PNG (Max 5MB) • Local Demo File Selection',
                          style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // List of Uploaded Documents
                if (_uploadedDocs.isNotEmpty) ...[
                  Text(
                    'Attached Documents (${_uploadedDocs.length})',
                    style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(_uploadedDocs.length, (index) {
                    final doc = _uploadedDocs[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEBE6DF)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            doc.fileName.endsWith('.pdf')
                                ? Icons.picture_as_pdf_outlined
                                : Icons.image_outlined,
                            color: AppColors.copper,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc.fileName,
                                  style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  doc.documentType,
                                  style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                            onPressed: () => _removeDoc(doc.id),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],

                // Action Buttons: Save Draft & Submit
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: AppButton(
                        text: 'Save Draft',
                        isOutlined: true,
                        backgroundColor: AppColors.copper,
                        textColor: AppColors.copper,
                        onPressed: _onSaveDraft,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        text: 'Submit for Verification',
                        isLoading: _isLoading,
                        backgroundColor: AppColors.copper,
                        onPressed: _onSubmit,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
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
