import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../data/partner_state.dart';
import '../../models/partner_models.dart';

class VerificationStatusScreen extends StatefulWidget {
  const VerificationStatusScreen({super.key});

  @override
  State<VerificationStatusScreen> createState() => _VerificationStatusScreenState();
}

class _VerificationStatusScreenState extends State<VerificationStatusScreen> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PartnerState.instance,
      builder: (context, _) {
        final partner = PartnerState.instance.partner;
        final docs = PartnerState.instance.documents;
        final status = partner.verificationStatus;

        return Scaffold(
          backgroundColor: AppColors.warmIvory,
          appBar: AppBar(
            backgroundColor: AppColors.warmIvory,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'Verification Status',
              style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppColors.copper),
                tooltip: 'Refresh Status',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.copper,
                      content: Text('Status refreshed from verification server (Mock).'),
                    ),
                  );
                },
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
                  // Demo State Switcher Header Tool
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.warmGray,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEBE6DF)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.tune_rounded, size: 16, color: AppColors.copper),
                            const SizedBox(width: 8),
                            Text(
                              'Demo State Simulator (Switch Status):',
                              style: AppTextStyles.caption(color: AppColors.warmBlack).copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _buildDemoChip('Submitted', PartnerVerificationStatus.submitted, status),
                            _buildDemoChip('Under Review', PartnerVerificationStatus.underReview, status),
                            _buildDemoChip('Approved', PartnerVerificationStatus.approved, status),
                            _buildDemoChip('Rejected', PartnerVerificationStatus.rejected, status),
                            _buildDemoChip('Needs Info', PartnerVerificationStatus.needsInfo, status),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Main Status Banner Card
                  _buildMainStatusCard(status, partner),
                  const SizedBox(height: 20),

                  // Submitted Documents Section
                  Text(
                    'Submitted Business Documents',
                    style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Documents on file for ${partner.businessName}',
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
                      child: const Center(
                        child: Text('No documents uploaded yet.'),
                      ),
                    )
                  else
                    ...docs.map((doc) => _buildDocTile(doc, status)),

                  const SizedBox(height: 24),

                  // Bottom Action Buttons according to status
                  _buildBottomActions(status, context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDemoChip(String label, PartnerVerificationStatus chipStatus, PartnerVerificationStatus currentStatus) {
    final isSelected = chipStatus == currentStatus;
    return InkWell(
      onTap: () {
        PartnerState.instance.setVerificationStatusDemo(chipStatus);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.copper : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.copper : const Color(0xFFD6D0C7)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.charcoal,
          ),
        ),
      ),
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
        cardBorder = Colors.green.shade300;
        iconBg = Colors.green.shade50;
        iconColor = Colors.green.shade700;
        icon = Icons.verified_rounded;
        title = 'Business Verified & Approved';
        message = 'Your salon business credentials have been fully verified. You have full access to create salons, add branch managers, and start accepting bookings.';
        badgeText = 'APPROVED';
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
        cardBorder = Colors.red.shade300;
        iconBg = Colors.red.shade50;
        iconColor = Colors.red.shade700;
        icon = Icons.cancel_outlined;
        title = 'Verification Rejected';
        message = 'Document mismatch or illegible certificate. Please re-upload clear government registration proofs.';
        badgeText = 'REJECTED';
        break;
      case PartnerVerificationStatus.needsInfo:
        cardBorder = Colors.orange.shade300;
        iconBg = Colors.orange.shade50;
        iconColor = Colors.orange.shade800;
        icon = Icons.warning_amber_rounded;
        title = 'Additional Information Required';
        message = 'Please provide an updated lease agreement or electricity bill with matching business address.';
        badgeText = 'ACTION REQUIRED';
        break;
      case PartnerVerificationStatus.submitted:
        cardBorder = AppColors.copper;
        iconBg = AppColors.copper.withValues(alpha: 0.12);
        iconColor = AppColors.copper;
        icon = Icons.task_alt_rounded;
        title = 'Verification Submitted';
        message = 'Documents received successfully and queued for verification by The Salon Times Admin.';
        badgeText = 'SUBMITTED';
        break;
    }

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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: iconColor,
                          letterSpacing: 0.5,
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
                'Business Entity:',
                style: AppTextStyles.caption(color: AppColors.mutedTextGray),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  partner.businessName,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Primary Contact:',
                style: AppTextStyles.caption(color: AppColors.mutedTextGray),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  partner.phone,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocTile(PartnerDocumentModel doc, PartnerVerificationStatus overallStatus) {
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
              color: AppColors.warmGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.description_outlined, color: AppColors.copper, size: 20),
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

  Widget _buildBottomActions(PartnerVerificationStatus status, BuildContext context) {
    if (status == PartnerVerificationStatus.approved) {
      return Column(
        children: [
          AppButton(
            text: 'Continue to Create Salon',
            backgroundColor: AppColors.copper,
            icon: Icons.storefront_rounded,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.partnerCreateSalon);
            },
          ),
          const SizedBox(height: 10),
          AppButton(
            text: 'Go to Partner Dashboard',
            isOutlined: true,
            backgroundColor: AppColors.copper,
            textColor: AppColors.copper,
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.partnerMain, (r) => false);
            },
          ),
        ],
      );
    } else if (status == PartnerVerificationStatus.rejected ||
        status == PartnerVerificationStatus.needsInfo) {
      return AppButton(
        text: 'Re-upload Verification Documents',
        backgroundColor: AppColors.copper,
        icon: Icons.upload_file_rounded,
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.partnerVerification);
        },
      );
    } else {
      // Pending / Under review
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F6F0),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEBE6DF)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.mutedTextGray),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Salon creation is unlocked automatically once Admin completes document review.',
                    style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            text: 'Verify Account Now (Demo Instant Approval)',
            backgroundColor: Colors.green.shade700,
            icon: Icons.verified_user_rounded,
            onPressed: () {
              PartnerState.instance.setVerificationStatusDemo(PartnerVerificationStatus.approved);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.green,
                  content: Text('Account verified! You can now create and setup your salon.'),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          AppButton(
            text: 'Update Submitted Information',
            isOutlined: true,
            backgroundColor: AppColors.copper,
            textColor: AppColors.copper,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.partnerVerification);
            },
          ),
        ],
      );
    }
  }
}
