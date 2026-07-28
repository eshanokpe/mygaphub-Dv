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
    _scrollController.addListener(_loadMoreNotifications);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_loadMoreNotifications);
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

  void _loadMoreNotifications() {
    if (!_scrollController.hasClients) return;

    final provider = Provider.of<NotificationProvider>(context, listen: false);
    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 200 &&
        provider.hasMore &&
        !provider.isLoading) {
      provider.goToNextPage();
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
        surfaceTintColor: Colors.white,
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
