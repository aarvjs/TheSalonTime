import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/partner_state.dart';
import '../../models/partner_models.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PartnerState.instance,
      builder: (context, _) {
        final state = PartnerState.instance;
        final transactions = state.transactions;

        return Scaffold(
          backgroundColor: AppColors.warmIvory,
          appBar: AppBar(
            backgroundColor: AppColors.warmIvory,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'Earnings & Financials',
              style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.warmBlack),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Top Demo Notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warmGray,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFEBE6DF)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.copper, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Simulated Business Revenue • Actual payouts will be settled via verified bank accounts on production launch.',
                          style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Primary Revenue Hero Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
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
                      Text(
                        'Total Monthly Revenue',
                        style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹${state.monthlyEarnings.toStringAsFixed(0)}',
                        style: AppTextStyles.h1(color: AppColors.warmBlack).copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1, color: Color(0xFFEBE6DF)),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Today's Earnings",
                                  style: AppTextStyles.caption(color: AppColors.mutedTextGray),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '₹${state.todayEarnings.toStringAsFixed(0)}',
                                  style: AppTextStyles.bodyBold(color: AppColors.copper).copyWith(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          Container(height: 30, width: 1, color: const Color(0xFFEBE6DF)),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "This Week's Earnings",
                                    style: AppTextStyles.caption(color: AppColors.mutedTextGray),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '₹${state.weeklyEarnings.toStringAsFixed(0)}',
                                    style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Transactions Section
                Text(
                  'Recent Transactions (${transactions.length})',
                  style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ledger entries generated upon completed customer appointments',
                  style: AppTextStyles.caption(color: AppColors.mutedTextGray),
                ),
                const SizedBox(height: 12),

                if (transactions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(child: Text('No transactions recorded yet.')),
                  )
                else
                  ...transactions.map((tx) => _buildTransactionCard(tx)),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionCard(EarningsTransactionModel tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEBE6DF)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_downward_rounded, color: Colors.green.shade800, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.serviceName,
                  style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${tx.customerName} • ${tx.paymentType}',
                  style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 11),
                ),
                Text(
                  'Ref: ${tx.bookingRef}',
                  style: AppTextStyles.caption(color: AppColors.copper).copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+₹${tx.amount.toStringAsFixed(0)}',
                style: AppTextStyles.bodyBold(color: Colors.green.shade800).copyWith(fontSize: 15),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tx.status,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
