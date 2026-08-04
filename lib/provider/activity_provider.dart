// lib/providers/activity_provider.dart
import 'package:GapHub/service/activity_service.dart';
import 'package:flutter/foundation.dart';

class ActivityProvider with ChangeNotifier {
  final ActivityService _activityService = ActivityService();
  bool _isTracking = false;

  Future<void> trackAppOpen() async {
    if (_isTracking) return;
    
    _isTracking = true;
    await _activityService.trackAppOpen();
    _isTracking = false;
    notifyListeners();
  }
}