
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../models/notification_model.dart';

class NotificationCardItem extends StatelessWidget {
  final NotificationModel notification;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;
  final bool showDeleteButton;

  const NotificationCardItem({
    super.key,
    required this.notification,
    this.isSelected = false,
    required this.onTap,
    this.onLongPress,
    this.onDelete,
    this.showDeleteButton = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.1)
              : notification.seen 
                  ? const Color(0xffF6F6F6) 
                  : const Color(0xffF0F7FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : const Color(0xffEFEFEF),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selection checkbox or unread indicator
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(right: 8, top: 5),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.primaryColor,
                  size: 20.sp,
                ),
              )
            else
              !notification.seen
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8, top: 5),
                      child: CircleAvatar(
                        radius: 6.r,
                        backgroundColor: AppColors.primaryColor,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(right: 8, top: 5),
                      child: CircleAvatar(
                        radius: 6.r,
                        backgroundColor: Colors.transparent,
                      ),
                    ),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [ 
                      Expanded(
                        child: Text(
                          notification.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontSize: 15.sp,
                            fontWeight: notification.seen ? FontWeight.w600 : FontWeight.w700,
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.black,
                          ),
                        ),
                      ),
                      if (showDeleteButton && onDelete != null)
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: 18.sp, color: Colors.red),
                          onPressed: onDelete,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    notification.message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      color: isSelected ? Colors.grey[800] : Colors.grey.shade700,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatTime(notification.createdAt),
                        style: GoogleFonts.nunito(
                          fontSize: 13.sp,
                          color: isSelected ? AppColors.primaryColor : AppColors.grayColor,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: 50.h),
              child: Icon(
                Icons.chevron_right, 
                color: isSelected ? AppColors.primaryColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );

    if (onDelete != null) {
      return Dismissible(
        key: Key('notification_${notification.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20.w),
          child: Icon(
            Icons.delete,
            color: Colors.white,
            size: 24.sp,
          ),
        ),
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Notification'),
              content: const Text('Are you sure you want to delete this notification?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) {
          onDelete!();
        },
        child: card,
      );
    }

    return card;
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      final monthNames = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${monthNames[date.month - 1]}';
    }
  }
}