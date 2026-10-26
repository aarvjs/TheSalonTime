import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/partner_state.dart';
import '../../models/partner_models.dart';
import '../../services/partner_firestore_service.dart';

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

  String _selectedDocType = 'Business Registration / Trade License';
  final List<String> _docTypes = [
    'Business Registration / Trade License',
    'GST Registration Certificate',
    'Government Identity Proof (Aadhaar/PAN)',
    'Commercial Address Proof / Lease Agreement',
  ];

  final List<PartnerDocumentModel> _uploadedDocs = [];
  bool _isLoading = false;
  String _uploadStatusMessage = '';

  @override
  void initState() {
    super.initState();
    final partner = PartnerState.instance.partner;

    // Automatically populated from existing registration data
    _legalNameController = TextEditingController(
      text: (partner.legalName != null && partner.legalName!.isNotEmpty)
          ? partner.legalName
          : partner.fullName,
    );
    _businessNameController = TextEditingController(text: partner.businessName);
    _regNumberController = TextEditingController(text: partner.regNumber ?? '');
    _businessAddressController = TextEditingController(text: partner.businessAddress ?? '');
    _emailController = TextEditingController(text: partner.email);
    _phoneController = TextEditingController(text: partner.phone);

    if (partner.businessType != null && _businessTypes.contains(partner.businessType)) {
      _selectedBusinessType = partner.businessType!;
    }

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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showFileSourcePicker({String? replacingDocId}) {
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
                    replacingDocId != null ? 'Replace Document' : 'Attach Verification File',
                    style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Upload PDF or image under 10MB for $_selectedDocType',
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
                  'Browse PDF / Device Documents',
                  style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 14),
                ),
                subtitle: const Text('Pick PDF, PNG, or JPG from device storage'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickWithFilePicker(replacingDocId: replacingDocId);
                },
              ),
              const Divider(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.champagneGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.champagneGold),
                ),
                title: Text(
                  'Photo Gallery',
                  style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 14),
                ),
                subtitle: const Text('Select a high-resolution photo of official certificate'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickWithImagePicker(ImageSource.gallery, replacingDocId: replacingDocId);
                },
              ),
              const Divider(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.blue),
                ),
                title: Text(
                  'Take Photo with Camera',
                  style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 14),
                ),
                subtitle: const Text('Capture live physical document image'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickWithImagePicker(ImageSource.camera, replacingDocId: replacingDocId);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickWithFilePicker({String? replacingDocId}) async {
    try {
      final result = await FilePickerPlatform.instance.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result.isNotEmpty) {
        final platformFile = result.first;
        if (platformFile.path == null) {
          _showError('Unable to read selected file path.');
          return;
        }

        final file = File(platformFile.path!);
        final bytes = await file.length();

        if (bytes > 10 * 1024 * 1024) {
          _showError('Selected file exceeds the 10 MB limit (${_formatFileSize(bytes)}). Please choose a smaller file.');
          return;
        }

        _handleSelectedFile(
          fileName: platformFile.name,
          localPath: platformFile.path!,
          fileSize: bytes,
          replacingDocId: replacingDocId,
        );
      }
    } catch (e) {
      // In case native file picker had an issue on this device platform, fallback to image picker
      _showError('Could not open document picker: $e. Try selecting via Photo Gallery.');
    }
  }

  Future<void> _pickWithImagePicker(ImageSource source, {String? replacingDocId}) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (picked != null) {
        final file = File(picked.path);
        final bytes = await file.length();

        if (bytes > 10 * 1024 * 1024) {
          _showError('Selected photo exceeds the 10 MB limit (${_formatFileSize(bytes)}).');
          return;
        }

        _handleSelectedFile(
          fileName: picked.name.isNotEmpty ? picked.name : 'Document_${DateTime.now().millisecondsSinceEpoch}.jpg',
          localPath: picked.path,
          fileSize: bytes,
          replacingDocId: replacingDocId,
        );
      }
    } catch (e) {
      _showError('Error picking photo: $e');
    }
  }

  void _handleSelectedFile({
    required String fileName,
    required String localPath,
    required int fileSize,
    String? replacingDocId,
  }) {
    final docId = replacingDocId ?? 'doc_${DateTime.now().millisecondsSinceEpoch}';
    final newDoc = PartnerDocumentModel(
      id: docId,
      documentType: _selectedDocType,
      fileName: fileName,
      localPath: localPath,
      fileSize: fileSize,
      documentNumber: _regNumberController.text.trim().isNotEmpty ? _regNumberController.text.trim() : null,
      uploadDate: DateTime.now(),
      status: PartnerVerificationStatus.submitted,
    );

    setState(() {
      if (replacingDocId != null) {
        final idx = _uploadedDocs.indexWhere((d) => d.id == replacingDocId);
        if (idx != -1) {
          _uploadedDocs[idx] = newDoc;
        } else {
          _uploadedDocs.add(newDoc);
        }
      } else {
        // If doc of same type exists, replace it to avoid duplicate types
        final existingIdx = _uploadedDocs.indexWhere((d) => d.documentType == _selectedDocType);
        if (existingIdx != -1) {
          _uploadedDocs[existingIdx] = newDoc;
        } else {
          _uploadedDocs.add(newDoc);
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.copper,
        content: Text('Attached: $fileName (${_formatFileSize(fileSize)})'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _removeDoc(String docId) {
    setState(() {
      _uploadedDocs.removeWhere((d) => d.id == docId);
    });
    PartnerState.instance.removeDocument(docId);
  }

  void _previewDoc(PartnerDocumentModel doc) {
    final isPdf = doc.fileName.toLowerCase().endsWith('.pdf');
    final hasLocal = doc.localPath != null && File(doc.localPath!).existsSync();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
                color: AppColors.copper,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  doc.documentType,
                  style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'File: ${doc.fileName}',
                style: AppTextStyles.bodyBold(color: AppColors.charcoal).copyWith(fontSize: 13),
              ),
              if (doc.fileSize != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Size: ${_formatFileSize(doc.fileSize!)}',
                  style: AppTextStyles.caption(color: AppColors.mutedTextGray),
                ),
              ],
              const SizedBox(height: 12),
              if (!isPdf && hasLocal)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(doc.localPath!),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.warmGray,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPdf ? Icons.picture_as_pdf_outlined : Icons.file_present_rounded,
                          size: 40,
                          color: AppColors.copper,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isPdf ? 'PDF Document Ready' : 'Document File Attached',
                          style: AppTextStyles.caption(color: AppColors.charcoal),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showFileSourcePicker(replacingDocId: doc.id);
              },
              child: const Text('Replace File', style: TextStyle(color: AppColors.copper)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.copper,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _onSaveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.charcoal,
        content: Text('Verification details saved locally. You can submit when ready.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade700,
        content: Text(message, style: const TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onSubmit() async {
    // 1. Prevent duplicate submissions
    if (_isLoading) return;

    // 2. Validate form
    if (!_formKey.currentState!.validate()) {
      _showError('Please check required business details fields.');
      return;
    }

    // 3. Validate at least one document
    if (_uploadedDocs.isEmpty) {
      _showError('Please attach at least one verification document (e.g. GST, Trade License, or Govt ID).');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showError('You must be signed in to submit verification documents.');
      return;
    }

    setState(() {
      _isLoading = true;
      _uploadStatusMessage = 'Preparing documents for verification...';
    });

    try {
      final finalDocs = <PartnerDocumentModel>[];

      // 4. Upload attached document files to Firebase Storage
      for (int i = 0; i < _uploadedDocs.length; i++) {
        final doc = _uploadedDocs[i];

        if (doc.localPath != null && File(doc.localPath!).existsSync()) {
          setState(() {
            _uploadStatusMessage = 'Uploading ${doc.documentType} (${i + 1}/${_uploadedDocs.length})...';
          });

          final file = File(doc.localPath!);
          final downloadUrl = await PartnerFirestoreService.instance.uploadPartnerDocument(
            uid: user.uid,
            file: file,
            fileName: doc.fileName,
          );

          finalDocs.add(doc.copyWith(
            fileUrl: downloadUrl,
            status: PartnerVerificationStatus.submitted,
          ));
        } else {
          // Already uploaded or existing
          finalDocs.add(doc.copyWith(
            status: PartnerVerificationStatus.submitted,
          ));
        }
      }

      setState(() {
        _uploadStatusMessage = 'Saving verification details to database...';
      });

      // 5. Save verification details, registered name, and documents to Firestore
      final updatedPartner = await PartnerFirestoreService.instance.submitVerificationDocuments(
        uid: user.uid,
        legalName: _legalNameController.text.trim(),
        businessName: _businessNameController.text.trim(),
        businessType: _selectedBusinessType,
        regNumber: _regNumberController.text.trim(),
        businessAddress: _businessAddressController.text.trim(),
        documents: finalDocs,
      );

      // 6. Update local PartnerState
      PartnerState.instance.setPartner(updatedPartner);
      PartnerState.instance.setDocuments(finalDocs);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Documents and details submitted successfully for review!'),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // 7. Navigate to verification pending screen
        Navigator.pushReplacementNamed(context, AppRoutes.partnerVerificationStatus);
      }
    } catch (e) {
      if (mounted) {
        _showError('Submission failed: $e. Your entered details are safe; please tap submit again to retry.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _uploadStatusMessage = '';
        });
      }
    }
  }

  void _navigateToExploreHome() {
    if (_isLoading) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.partnerMain, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final registeredName = PartnerState.instance.partner.fullName;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _navigateToExploreHome();
      },
      child: Scaffold(
        backgroundColor: AppColors.warmIvory,
        appBar: AppBar(
          backgroundColor: AppColors.warmIvory,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Submit Verification Documents',
            style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.warmBlack),
            tooltip: 'Explore App',
            onPressed: _navigateToExploreHome,
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
                // Top Header Card with Registered Partner Name
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
                                  'Complete Your Partner Profile',
                                  style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 17),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Registered Partner: $registeredName',
                                  style: AppTextStyles.caption(color: AppColors.copper).copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
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
                                'Your registered name is automatically linked. Please submit business registration and identity documents to complete verification.',
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

                // Section 1: Business & Legal Details
                Text(
                  '1. Business & Legal Details',
                  style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 16),
                ),
                const SizedBox(height: 12),

                // Registered Owner / Legal Name (auto-populated)
                _buildField(
                  controller: _legalNameController,
                  label: 'Registered Owner / Legal Name',
                  hint: 'Full legal name as on ID card',
                  readOnly: false,
                  prefixIcon: Icons.badge_outlined,
                  helperText: 'Auto-populated from registration. Must match ID card.',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Owner name is required' : null,
                ),
                const SizedBox(height: 12),

                // Business Name
                _buildField(
                  controller: _businessNameController,
                  label: 'Official Salon / Trade Name',
                  hint: 'e.g. Royal Velvet Salon & Spa',
                  prefixIcon: Icons.storefront_outlined,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Salon trade name is required' : null,
                ),
                const SizedBox(height: 12),

                // Business Entity Type
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
                      onChanged: _isLoading
                          ? null
                          : (val) {
                              if (val != null) setState(() => _selectedBusinessType = val);
                            },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Registration / GST / PAN Number
                _buildField(
                  controller: _regNumberController,
                  label: 'GST / Business Reg. / PAN Number',
                  hint: 'e.g. 09AAACG1234F1Z5 or PAN / Trade Lic #',
                  prefixIcon: Icons.numbers_rounded,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Registration or Tax number is required' : null,
                ),
                const SizedBox(height: 12),

                // Registered Business Address
                _buildField(
                  controller: _businessAddressController,
                  label: 'Registered Salon Address',
                  hint: 'Complete street address, city, state & postal code',
                  maxLines: 2,
                  prefixIcon: Icons.location_on_outlined,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Business address is required' : null,
                ),
                const SizedBox(height: 24),

                // Section 2: Document Upload
                Text(
                  '2. Verification Documents',
                  style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select document type and upload a clear scanned copy (PDF, JPG, PNG up to 10MB).',
                  style: AppTextStyles.caption(color: AppColors.mutedTextGray),
                ),
                const SizedBox(height: 12),

                // Document Type Dropdown
                Text(
                  'Select Document Category to Attach',
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
                      onChanged: _isLoading
                          ? null
                          : (val) {
                              if (val != null) setState(() => _selectedDocType = val);
                            },
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Upload Box / File Picker Trigger
                InkWell(
                  onTap: _isLoading ? null : () => _showFileSourcePicker(),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.copper.withValues(alpha: 0.6),
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
                          'Tap to Select & Attach Document',
                          style: AppTextStyles.bodyBold(color: AppColors.copper).copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select PDF, JPG or PNG (Up to 10MB)',
                          style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // List of Selected Documents
                if (_uploadedDocs.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Attached Documents (${_uploadedDocs.length})',
                        style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                      ),
                      Text(
                        'Tap file to preview / replace',
                        style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(_uploadedDocs.length, (index) {
                    final doc = _uploadedDocs[index];
                    final isPdf = doc.fileName.toLowerCase().endsWith('.pdf');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEBE6DF)),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => _previewDoc(doc),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isPdf
                                    ? Colors.red.shade50
                                    : AppColors.copper.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isPdf ? Icons.picture_as_pdf_rounded : Icons.image_outlined,
                                color: isPdf ? Colors.red.shade700 : AppColors.copper,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => _previewDoc(doc),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doc.fileName,
                                    style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          doc.documentType,
                                          style: AppTextStyles.caption(color: AppColors.copper).copyWith(fontSize: 11),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (doc.fileSize != null)
                                        Text(
                                          ' • ${_formatFileSize(doc.fileSize!)}',
                                          style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.sync_rounded, color: AppColors.copper, size: 20),
                            tooltip: 'Replace Document',
                            onPressed: _isLoading ? null : () => _showFileSourcePicker(replacingDocId: doc.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                            tooltip: 'Remove',
                            onPressed: _isLoading ? null : () => _removeDoc(doc.id),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],

                // Upload Progress State Indicator
                if (_isLoading) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.copper.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.copper.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.copper),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _uploadStatusMessage.isNotEmpty
                                ? _uploadStatusMessage
                                : 'Uploading documents securely to server...',
                            style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                        onPressed: _isLoading ? null : _onSaveDraft,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        text: 'Submit for Verification',
                        isLoading: _isLoading,
                        backgroundColor: AppColors.copper,
                        icon: Icons.send_rounded,
                        onPressed: _isLoading ? null : _onSubmit,
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
    ),
  );
}

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    bool readOnly = false,
    IconData? prefixIcon,
    String? helperText,
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
          readOnly: readOnly,
          validator: validator,
          style: AppTextStyles.body(color: AppColors.warmBlack).copyWith(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.subtitle(color: AppColors.mutedTextGray).copyWith(fontSize: 13),
            helperText: helperText,
            helperStyle: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 10),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.copper, size: 20) : null,
            filled: true,
            fillColor: readOnly ? const Color(0xFFF7F5F0) : Colors.white,
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
