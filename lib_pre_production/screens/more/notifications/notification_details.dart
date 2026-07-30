import 'dart:io';
import 'package:GapHub/models/notification_model.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationDetailScreen extends StatelessWidget {
  final NotificationModel notification;
  
  const NotificationDetailScreen({
    super.key, 
    required this.notification
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title:  Text(
          'Notification',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding:  EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              _shouldShowNotification(notification) ? notification.title : notification.title ,
              style:  TextStyle(
               fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            
            SizedBox(height: 5.h),
            _buildMetadataRowTime(
              icon: Icons.access_time_outlined,
              time: _formatDateTime(notification.createdAt),
            ),
           
            SizedBox(height: 12.h),
            
            SizedBox(
              width: double.infinity,
              child: Text(
                notification.message,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF272727),
                  height: 1.5,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            // Text(
            //  notification.action.toString(),
            //   style: TextStyle(
            //     color: Colors.black,
            //     fontSize: 16.sp,
            //     fontWeight: FontWeight.w600,
            //   ),
            // ),
           ],
        ),
      ),
      
     bottomNavigationBar: notification.action != null && 
                    notification.action!.isNotEmpty &&
                    notification.data?['label'] != null
        ? Padding(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          bottom: 46.h,
          top: 8.h,
        ),
        child:  SizedBox(
          width: double.infinity,
          height: 60.h,
          child: ElevatedButton.icon(
            onPressed: () async{
               if (notification.action != null && notification.action!.isNotEmpty) {
                final url = notification.action!;
                try {
                  if (await canLaunch(url)) {
                    await launch(url);
                  }
                } catch (e) {
                  print('Error opening URL: $e');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(
                vertical: 16.h,
                horizontal: 32.w,
              ),
            ),
            label:  Text(
            notification.data?['label'] ?? 'No Label',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ) : null,
      
    );
  }

   Widget _buildMetadataRowTime({
    required IconData icon,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade600,
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.isNotEmpty
                  ? label[0].toUpperCase() + label.substring(1)
                  : label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                   value.isNotEmpty
                  ? value[0].toUpperCase() + value.substring(1)
                  : value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  String _formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('d MMMM yyyy, h:mma');
    return formatter.format(dateTime).toLowerCase();
  }
 
  bool _shouldShowNotification(NotificationModel notification) {
    final platform = notification.data?['platform'];
    
    if (platform == 'android' && Platform.isAndroid) {
      return true;
    }
     
    if (platform == 'ios' && Platform.isIOS) {
      return true;
    }
    
    // If no platform specified, show for all
    if (platform == null || platform.isEmpty) {
      return true;
    }
    
    return false;
  }

}