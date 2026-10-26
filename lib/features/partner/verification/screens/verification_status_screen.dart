import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/partner_state.dart';
import '../../models/partner_models.dart';
import '../../services/partner_firestore_service.dart';

class VerificationStatusScreen extends StatefulWidget {
  const VerificationStatusScreen({super.key});

  @override
  State<VerificationStatusScreen> createState() => _VerificationStatusScreenState();
}

class _VerificationStatusScreenState extends State<VerificationStatusScreen> {
  bool _isRefreshing = false;

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Recently Submitted';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final year = dt.year;

    final hourNum = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');

    return '$day $month $year, $hourNum:$min $ampm';
  }

  Future<void> _refreshStatus() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final fresh = await PartnerFirestoreService.instance.getPartnerProfile(user.uid);
        if (fresh != null && mounted) {
          PartnerState.instance.setPartner(fresh);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.copper,
              content: Text('Verification status: ${fresh.verificationStatus.name}'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );

          if (fresh.verificationStatus == PartnerVerificationStatus.approved) {
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.partnerMain, (r) => false);
            return;
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.copper,
              content: Text('Status refreshed.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            content: Text('Error refreshing status: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  void _showSubmittedDetailsModal(PartnerModel partner, List<PartnerDocumentModel> docs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Submitted Verification Details',
                        style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  _buildDetailRow('Registered Owner Name', partner.fullName),
                  if (partner.legalName != null && partner.legalName!.isNotEmpty)
                    _buildDetailRow('Legal Name', partner.legalName!),
                  _buildDetailRow('Official Salon Name', partner.businessName),
                  if (partner.businessType != null && partner.businessType!.isNotEmpty)
                    _buildDetailRow('Entity Type', partner.businessType!),
                  if (partner.regNumber != null && partner.regNumber!.isNotEmpty)
                    _buildDetailRow('GST / Registration #', partner.regNumber!),
                  if (partner.businessAddress != null && partner.businessAddress!.isNotEmpty)
                    _buildDetailRow('Registered Address', partner.businessAddress!),
                  _buildDetailRow('Mobile Number', partner.phone),
                  _buildDetailRow('Email ID', partner.email),
                  _buildDetailRow('Submission Time', _formatDate(partner.submittedAt ?? DateTime.now())),
                  const SizedBox(height: 16),
                  Text(
                    'Uploaded Documents (${docs.length})',
                    style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  if (docs.isEmpty)
                    const Text('No documents attached yet.')
                  else
                    ...docs.map((d) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.warmGray,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.description_outlined, color: AppColors.copper, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      d.documentType,
                                      style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 12),
                                    ),
                                    Text(
                                      d.fileName,
                                      style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTextStyles.caption(color: AppColors.mutedTextGray),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PartnerState.instance,
      builder: (context, _) {
        final partner = PartnerState.instance.partner;
        final docs = PartnerState.instance.documents;
        final status = partner.verificationStatus;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.partnerMain, (r) => false);
          },
          child: Scaffold(
            backgroundColor: AppColors.warmIvory,
            appBar: AppBar(
              backgroundColor: AppColors.warmIvory,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.warmBlack),
                tooltip: 'Explore App',
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.partnerMain, (r) => false);
                },
              ),
              title: Text(
                'Verification Status',
                style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
              ),
            actions: [
              IconButton(
                icon: _isRefreshing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.copper),
                      )
                    : const Icon(Icons.refresh_rounded, color: AppColors.copper),
                tooltip: 'Refresh from Admin',
                onPressed: _isRefreshing ? null : _refreshStatus,
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Registered Partner Identity Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEBE6DF)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.copper.withValues(alpha: 0.12),
                          child: const Icon(Icons.person, color: AppColors.copper, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                partner.fullName,
                                style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 15),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                partner.businessName.isNotEmpty ? partner.businessName : 'Registered Partner Account',
                                style: AppTextStyles.caption(color: AppColors.mutedTextGray),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Main Status Card
                  _buildMainStatusCard(status, partner),
                  const SizedBox(height: 20),

                  // Submitted Documents Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Submitted Documents (${docs.length})',
                        style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 16),
                      ),
                      if (status == PartnerVerificationStatus.submitted ||
                          status == PartnerVerificationStatus.underReview)
                        TextButton(
                          onPressed: () => _showSubmittedDetailsModal(partner, docs),
                          child: const Text('View Full Details', style: TextStyle(color: AppColors.copper, fontSize: 12)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Documents on file for verification review',
                    style: AppTextStyles.caption(color: AppColors.mutedTextGray),
                  ),
                  const SizedBox(height: 12),

                  if (docs.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEBE6DF)),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.folder_open_outlined, color: AppColors.mutedTextGray, size: 36),
                            const SizedBox(height: 8),
                            const Text('No documents submitted yet.'),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.copper,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => Navigator.pushNamed(context, AppRoutes.partnerVerification),
                              child: const Text('Submit Documents Now'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...docs.map((doc) => _buildDocTile(doc, status)),

                  const SizedBox(height: 24),

                  // Bottom Action Buttons
                  _buildBottomActions(status, partner, docs, context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
  }

  Widget _buildMainStatusCard(PartnerVerificationStatus status, PartnerModel partner) {
    Color cardBorder;
    Color iconBg;
    Color iconColor;
    IconData icon;
    String title;
    String message;
    String badgeText;

    switch (status) {
      case PartnerVerificationStatus.approved:
        cardBorder = Colors.green.shade400;
        iconBg = Colors.green.shade50;
        iconColor = Colors.green.shade700;
        icon = Icons.verified_rounded;
        title = 'Business Verified & Approved';
        message = 'Your salon business credentials have been fully verified. You have full access to create salons, assign branch managers, and publish services on The Salon Times.';
        badgeText = 'VERIFIED';
        break;

      case PartnerVerificationStatus.underReview:
        cardBorder = AppColors.champagneGold;
        iconBg = AppColors.champagneGold.withValues(alpha: 0.15);
        iconColor = const Color(0xFF9E7D1A);
        icon = Icons.hourglass_top_rounded;
        title = 'Application Under Review';
        message = 'Our compliance team is currently reviewing your registration proofs. Typical review time is 24 to 48 hours.';
        badgeText = 'UNDER REVIEW';
        break;

      case PartnerVerificationStatus.rejected:
        cardBorder = Colors.red.shade400;
        iconBg = Colors.red.shade50;
        iconColor = Colors.red.shade700;
        icon = Icons.cancel_outlined;
        title = 'Verification Rejected';
        message = partner.rejectionReason != null && partner.rejectionReason!.isNotEmpty
            ? partner.rejectionReason!
            : 'Document mismatch or illegible certificate. Please re-upload clear government registration proofs.';
        badgeText = 'REJECTED';
        break;

      case PartnerVerificationStatus.needsInfo:
        cardBorder = Colors.orange.shade400;
        iconBg = Colors.orange.shade50;
        iconColor = Colors.orange.shade800;
        icon = Icons.warning_amber_rounded;
        title = 'Additional Information Required';
        message = partner.rejectionReason ?? 'Please provide an updated lease agreement or electricity bill with matching business address.';
        badgeText = 'ACTION REQUIRED';
        break;

      case PartnerVerificationStatus.notSubmitted:
        cardBorder = Colors.grey.shade400;
        iconBg = AppColors.warmGray;
        iconColor = AppColors.charcoal;
        icon = Icons.assignment_late_outlined;
        title = 'Documents Not Submitted';
        message = 'Submit your business registration and identity documents to complete partner verification.';
        badgeText = 'NOT SUBMITTED';
        break;

      case PartnerVerificationStatus.submitted:
        cardBorder = AppColors.copper;
        iconBg = AppColors.copper.withValues(alpha: 0.12);
        iconColor = AppColors.copper;
        icon = Icons.task_alt_rounded;
        title = 'Verification Pending';
        message = 'Your details and documents have been submitted successfully. Our team will review them and update your verification status.';
        badgeText = 'VERIFICATION PENDING';
        break;
    }

    final submissionDateStr = _formatDate(partner.submittedAt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: iconColor,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 17),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: AppTextStyles.body(color: AppColors.charcoal).copyWith(
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFEBE6DF)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Submission Date:',
                style: AppTextStyles.caption(color: AppColors.mutedTextGray),
              ),
              Text(
                submissionDateStr,
                style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Registered Owner:',
                style: AppTextStyles.caption(color: AppColors.mutedTextGray),
              ),
              Text(
                partner.fullName,
                style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocTile(PartnerDocumentModel doc, PartnerVerificationStatus overallStatus) {
    final isPdf = doc.fileName.toLowerCase().endsWith('.pdf');

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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPdf ? Colors.red.shade50 : AppColors.warmGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isPdf ? Icons.picture_as_pdf_outlined : Icons.description_outlined,
              color: isPdf ? Colors.red.shade700 : AppColors.copper,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.documentType,
                  style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  doc.fileName,
                  style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: overallStatus == PartnerVerificationStatus.approved
                  ? Colors.green.shade50
                  : AppColors.warmGray,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              overallStatus == PartnerVerificationStatus.approved ? 'Verified' : 'Submitted',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: overallStatus == PartnerVerificationStatus.approved
                    ? Colors.green.shade800
                    : AppColors.charcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(
    PartnerVerificationStatus status,
    PartnerModel partner,
    List<PartnerDocumentModel> docs,
    BuildContext context,
  ) {
    if (status == PartnerVerificationStatus.approved) {
      return Column(
        children: [
          AppButton(
            text: 'Go to Partner Dashboard',
            backgroundColor: AppColors.copper,
            icon: Icons.dashboard_rounded,
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.partnerMain, (r) => false);
            },
          ),
          const SizedBox(height: 10),
          AppButton(
            text: 'Create & Setup Salon',
            isOutlined: true,
            backgroundColor: AppColors.copper,
            textColor: AppColors.copper,
            icon: Icons.storefront_rounded,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.partnerCreateSalon);
            },
          ),
        ],
      );
    } else if (status == PartnerVerificationStatus.rejected ||
        status == PartnerVerificationStatus.needsInfo) {
      return Column(
        children: [
          AppButton(
            text: 'Resubmit Verification Documents',
            backgroundColor: AppColors.copper,
            icon: Icons.upload_file_rounded,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.partnerVerification);
            },
          ),
          const SizedBox(height: 10),
          AppButton(
            text: 'Explore App (Restricted Mode)',
            isOutlined: true,
            backgroundColor: AppColors.copper,
            textColor: AppColors.copper,
            icon: Icons.explore_outlined,
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.partnerMain, (r) => false);
            },
          ),
        ],
      );
    } else {
      // Pending / Submitted / Under Review
      return Column(
        children: [
          // Prominent Explore App Button
          AppButton(
            text: 'Explore App',
            backgroundColor: AppColors.copper,
            icon: Icons.explore_rounded,
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.partnerMain, (r) => false);
            },
          ),
          const SizedBox(height: 10),

          // View Submitted Details Button
          AppButton(
            text: 'View Submitted Details',
            isOutlined: true,
            backgroundColor: AppColors.copper,
            textColor: AppColors.copper,
            icon: Icons.visibility_outlined,
            onPressed: () => _showSubmittedDetailsModal(partner, docs),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F6F0),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEBE6DF)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, size: 16, color: AppColors.mutedTextGray),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'In Explorer Mode, you can browse screens & setup previews. Salon publishing and live bookings unlock upon admin approval.',
                    style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}
