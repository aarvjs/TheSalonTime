import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/partner_state.dart';
import '../../models/partner_models.dart';

class PartnerNotificationsScreen extends StatelessWidget {
  const PartnerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PartnerState.instance,
      builder: (context, _) {
        final notifications = PartnerState.instance.notifications;

        return Scaffold(
          backgroundColor: AppColors.warmIvory,
          appBar: AppBar(
            backgroundColor: AppColors.warmIvory,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'Partner Notifications',
              style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.warmBlack),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (notifications.any((n) => !n.isRead))
                TextButton(
                  onPressed: () {
                    PartnerState.instance.markAllNotificationsAsRead();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppColors.copper,
                        content: Text('All notifications marked as read.'),
                      ),
                    );
                  },
                  child: const Text(
                    'Mark all read',
                    style: TextStyle(color: AppColors.copper, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.notifications_off_outlined, size: 54, color: AppColors.mutedTextGray),
                        const SizedBox(height: 12),
                        Text(
                          'No new notifications',
                          style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'You are all caught up!',
                          style: AppTextStyles.caption(color: AppColors.mutedTextGray),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      return _buildNotificationTile(notif);
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationTile(PartnerNotificationModel notif) {
    IconData icon;
    Color iconColor;
    Color bg;

    switch (notif.type) {
      case 'booking':
        icon = Icons.calendar_today_rounded;
        iconColor = AppColors.copper;
        bg = AppColors.copper.withValues(alpha: 0.12);
        break;
      case 'verification':
        icon = Icons.verified_user_rounded;
        iconColor = Colors.green.shade700;
        bg = Colors.green.shade50;
        break;
      case 'manager':
        icon = Icons.badge_rounded;
        iconColor = AppColors.champagneGold;
        bg = AppColors.champagneGold.withValues(alpha: 0.15);
        break;
      case 'cancellation':
        icon = Icons.cancel_rounded;
        iconColor = Colors.red.shade700;
        bg = Colors.red.shade50;
        break;
      default:
        icon = Icons.notifications_rounded;
        iconColor = AppColors.copper;
        bg = AppColors.copper.withValues(alpha: 0.12);
    }

    return InkWell(
      onTap: () {
        if (!notif.isRead) {
          PartnerState.instance.markNotificationAsRead(notif.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.white : const Color(0xFFFDFBF7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notif.isRead ? const Color(0xFFEBE6DF) : AppColors.copper.withValues(alpha: 0.4),
            width: notif.isRead ? 1.0 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(
                            fontSize: 13,
                            fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.copper,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.description,
                    style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(fontSize: 12, height: 1.35),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(notif.timestamp),
                    style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }
}
