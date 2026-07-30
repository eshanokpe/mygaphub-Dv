// screens/notifications_screen.dart
import 'dart:convert';
import 'dart:io';

import 'package:GapHub/provider/notification_provider.dart';
import 'package:GapHub/screens/SEED/seedash/historic_seed/historicdate.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/notification_model.dart';
import 'package:GapHub/utils/colors.dart';
import 'components/notificationCardItem.dart';
import 'components/sectionHeader.dart';
import 'notification_details.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;
  final List<int> _selectedNotifications = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotifications();
    });
    // Scroll listener removed - using button pagination only
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeNotifications() {
    if (!_isInitialized) {
      final provider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      provider.fetchNotifications(refresh: true);
      _isInitialized = true;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final notificationDate = DateTime(date.year, date.month, date.day);

    if (notificationDate == today) {
      return "Today";
    } else if (notificationDate == yesterday) {
      return "Yesterday";
    } else {
      final monthNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return "${date.day} ${monthNames[date.month - 1]}";
    }
  }

  // Toggle selection of a notification
  void _toggleSelection(int notificationId) {
    setState(() {
      if (_selectedNotifications.contains(notificationId)) {
        _selectedNotifications.remove(notificationId);
      } else {
        _selectedNotifications.add(notificationId);
      }
    });
  }

  // Clear all selections
  void _clearSelections() {
    setState(() {
      _selectedNotifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationProvider>(context);
    final hasSelections = _selectedNotifications.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: !hasSelections,
        title: hasSelections
            ? Text(
                "${_selectedNotifications.length} selected",
                style: GoogleFonts.nunito(
                  color: Colors.black,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              )
            : Text(
                "Notifications",
                style: GoogleFonts.nunito(
                  color: Colors.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (hasSelections)
            IconButton(
              icon: Icon(Icons.mark_email_read, size: 24.sp),
              onPressed: () async {
                await provider.markAllAsRead(
                  notificationIds: _selectedNotifications,
                );
                _clearSelections();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Marked ${_selectedNotifications.length} notification(s) as read',
                      style: GoogleFonts.nunito(),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              tooltip: 'Mark selected as read',
            )
          else if (provider.unreadCount > 0)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, size: 24.sp),
              onSelected: (value) async {
                if (value == 'mark_all_read') {
                  await provider.markAllAsRead();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'All notifications marked as read',
                        style: GoogleFonts.nunito(),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (value == 'mark_visible_read') {
                  final unreadIds = provider.getUnreadNotificationIds();
                  if (unreadIds.isNotEmpty) {
                    await provider.markAllAsRead(notificationIds: unreadIds);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Marked ${unreadIds.length} unread notification(s) as read',
                          style: GoogleFonts.nunito(),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      Icon(
                        Icons.done_all,
                        size: 20.sp,
                        color: Colors.grey[700],
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Mark all as read',
                        style: GoogleFonts.nunito(fontSize: 14.sp),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'mark_visible_read',
                  child: Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        size: 20.sp,
                        color: Colors.grey[700],
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Mark visible as read',
                        style: GoogleFonts.nunito(fontSize: 14.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.notifications.isEmpty && !provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80.sp,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "No notifications yet",
                    style: GoogleFonts.nunito(
                      fontSize: 18.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          // Group notifications by date
          final Map<String, List<NotificationModel>> groupedNotifications = {};

          for (var notification in provider.notifications) {
            final dateKey = _formatDate(notification.createdAt);
            if (!groupedNotifications.containsKey(dateKey)) {
              groupedNotifications[dateKey] = [];
            }
            groupedNotifications[dateKey]!.add(notification);
          }

          final dateKeys = groupedNotifications.keys.toList();

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchNotifications(refresh: true);
              _clearSelections();
            },
            child: Column(
              children: [
                // Items per page indicator
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.end,
                //     children: [
                //       Container(
                //         padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                //         decoration: BoxDecoration(
                //           color: Colors.grey[100],
                //           borderRadius: BorderRadius.circular(12.r),
                //         ),
                //         child: Text(
                //           '${provider.perPage} per page',
                //           style: GoogleFonts.nunito(
                //             fontSize: 11.sp,
                //             color: Colors.grey[600],
                //             fontWeight: FontWeight.w400,
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                // Notifications list
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    itemCount: dateKeys.length,
                    itemBuilder: (context, index) {
                      final dateKey = dateKeys[index];
                      final notifications = groupedNotifications[dateKey]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(title: dateKey),
                          ...notifications.map(
                            (notification) => NotificationCardItem(
                              notification: notification,
                              isSelected: _selectedNotifications.contains(
                                notification.id,
                              ),
                              onTap: () async {
                                // Mark as read immediately
                                Provider.of<NotificationProvider>(
                                  context,
                                  listen: false,
                                ).markAsRead(notification.id);

                                if (notification.category == 'seed_report') {
                                  try {
                                    // Show loading dialog
                                    dialogBox.waiting(context, 'Loading');

                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    final token = prefs.getString('tokenDB');

                                    // First API call: Get seed periods
                                    final seedUrl = Uri.parse(
                                      "$baseUrl/app/seed/",
                                    );
                                    final seedResponse = await http.get(
                                      seedUrl,
                                      headers: {
                                        "Authorization": 'Bearer $token',
                                        "Accept": "application/json",
                                      },
                                    );

                                    if (seedResponse.statusCode == 200) {
                                      final Map<String, dynamic> seedBody =
                                          jsonDecode(seedResponse.body);

                                      // Check if periods exists and handle both Map and List cases
                                      List<dynamic> periodsList = [];

                                      if (seedBody["data"] != null &&
                                          seedBody["data"]['periods'] != null) {
                                        final periodsData =
                                            seedBody["data"]['periods'];

                                        if (periodsData is Map) {
                                          periodsList = periodsData.values
                                              .toList();
                                        } else if (periodsData is List) {
                                          periodsList = periodsData;
                                        }
                                      }

                                      // Extract date from notification received_at field
                                      final dateTime = notification.receivedAt;
                                      final datePart =
                                          "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";

                                      // Second API call: Get seed history for specific date
                                      final historyUrl = Uri.parse(
                                        "$baseUrl/app/seed/history/$datePart",
                                      );
                                      final historyResponse = await http.get(
                                        historyUrl,
                                        headers: {
                                          "Authorization": 'Bearer $token',
                                          "Accept": "application/json",
                                        },
                                      );

                                      if (historyResponse.statusCode == 200) {
                                        // Close loading dialog
                                        Navigator.pop(context);

                                        final Map<String, dynamic> historyData =
                                            jsonDecode(historyResponse.body);

                                        // Navigate to HistoricDate screen
                                        if (mounted) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  HistoricDate(
                                                    historicdata: historyData,
                                                    date: datePart,
                                                    list: periodsList,
                                                  ),
                                            ),
                                          );
                                        }
                                      } else {
                                        if (mounted) Navigator.pop(context);
                                        Fluttertoast.showToast(
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          msg: 'Failed to load seed history',
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                        );
                                      }
                                    } else {
                                      if (mounted) Navigator.pop(context);
                                      Fluttertoast.showToast(
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        msg: 'Failed to load seed data',
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted && Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                    print('Error in notification tap: $e');
                                    Fluttertoast.showToast(
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      msg: 'An error occurred: ${e.toString()}',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                    );
                                  }
                                } else if (notification.action == null ||
                                    notification.action == 'portfolio' ||
                                    notification.action == 'new_feature' ||
                                    notification.action == 'special_offer' ||
                                    notification.action == 'settings' ||
                                    notification.action == 'support' ||
                                    notification.action == 'dashboard') {
                                  if (mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            NotificationDetailScreen(
                                              notification: notification,
                                            ),
                                      ),
                                    );
                                  }
                                } else {
                                  if (notification.action != null &&
                                      notification.action!.isNotEmpty) {
                                    if (mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              NotificationDetailScreen(
                                                notification: notification,
                                              ),
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              onLongPress: () {
                                _toggleSelection(notification.id);
                              },
                            ),
                          ),
                          SizedBox(height: 25.h),
                        ],
                      );
                    },
                  ),
                ),

                // Pagination Controls
                if (provider.total > 0)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Previous button
                        GestureDetector(
                          onTap: provider.currentPage > 1
                              ? () async {
                                  await provider.goToPreviousPage();
                                  _scrollController.animateTo(
                                    0,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                }
                              : null,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: provider.currentPage > 1
                                  ? AppColors.primaryColor
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.chevron_left,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'Previous',
                                  style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Page info
                        Column(
                          children: [
                            Text(
                              'Page ${provider.currentPage} of ${provider.lastPage}',
                              style: GoogleFonts.nunito(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${provider.from} - ${provider.to}',
                              style: GoogleFonts.nunito(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),

                        // Next button
                        GestureDetector(
                          onTap: provider.hasMore
                              ? () async {
                                  await provider.goToNextPage();
                                  _scrollController.animateTo(
                                    0,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                }
                              : null,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: provider.hasMore
                                  ? AppColors.primaryColor
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Next',
                                  style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Loading indicator
                if (provider.isLoading)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                        // color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
