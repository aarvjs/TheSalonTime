import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/branch_manager_state.dart';
import '../../models/branch_manager_models.dart';

class ManagerNotificationsScreen extends StatelessWidget {
  final VoidCallback? onOpenDrawer;

  const ManagerNotificationsScreen({super.key, this.onOpenDrawer});

  String _formatTimestamp(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BranchManagerState.instance,
      builder: (context, _) {
        final state = BranchManagerState.instance;
        final list = state.notifications;

        return Scaffold(
          backgroundColor: AppColors.warmIvory,
          appBar: AppBar(
            backgroundColor: AppColors.warmIvory,
            elevation: 0,
            centerTitle: true,
            leading: onOpenDrawer != null
                ? IconButton(
                    icon: const Icon(Icons.menu_rounded, color: AppColors.warmBlack),
                    onPressed: onOpenDrawer,
                  )
                : IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.warmBlack),
                    onPressed: () => Navigator.pop(context),
                  ),
            title: Text(
              'Branch Notifications',
              style: AppTextStyles.h2(color: AppColors.warmBlack).copyWith(fontSize: 18),
            ),
            actions: [
              if (state.unreadNotificationsCount > 0)
                TextButton(
                  onPressed: () {
                    state.markAllNotificationsAsRead();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppColors.managerEmerald,
                        duration: Duration(seconds: 1),
                        content: Text('All branch notifications marked as read.'),
                      ),
                    );
                  },
                  child: const Text('Mark all read', style: TextStyle(color: AppColors.managerEmerald, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
            ],
          ),
          body: SafeArea(
            child: list.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 52, color: AppColors.mutedTextGray.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Text(
                          'No notifications for this branch',
                          style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'New bookings and partner announcements will appear here',
                          style: AppTextStyles.caption(color: AppColors.mutedTextGray),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final notif = list[index];
                      return _buildNotificationCard(context, notif);
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard(BuildContext context, BranchManagerNotificationModel notif) {
    IconData icon = Icons.notifications_active_outlined;
    Color iconColor = AppColors.managerEmerald;

    if (notif.type == 'booking') {
      icon = Icons.event_available_rounded;
      iconColor = AppColors.managerEmerald;
    } else if (notif.type == 'confirmation') {
      icon = Icons.check_circle_outline_rounded;
      iconColor = Colors.green.shade700;
    } else if (notif.type == 'announcement') {
      icon = Icons.campaign_outlined;
      iconColor = AppColors.managerGold;
    } else if (notif.type == 'completion') {
      icon = Icons.task_alt_rounded;
      iconColor = AppColors.charcoal;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: notif.isRead ? Colors.white : AppColors.managerEmeraldBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notif.isRead ? const Color(0xFFDFE7E2) : AppColors.managerEmerald.withValues(alpha: 0.3),
          width: notif.isRead ? 1 : 1.3,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
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
                        style: AppTextStyles.bodyBold(color: AppColors.warmBlack).copyWith(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatTimestamp(notif.timestamp),
                      style: AppTextStyles.caption(color: AppColors.mutedTextGray).copyWith(fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  notif.description,
                  style: AppTextStyles.caption(color: AppColors.charcoal).copyWith(fontSize: 12),
                ),
                if (!notif.isRead) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => BranchManagerState.instance.markNotificationAsRead(notif.id),
                    child: Text(
                      'Mark as read',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.managerEmerald,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
