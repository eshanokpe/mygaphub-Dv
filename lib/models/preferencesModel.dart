import 'package:GapHub/service/preferencesService.dart';
import 'package:flutter/material.dart';

class PreferencesModel with ChangeNotifier {
  bool paymentReminders = true;
  bool acquisitionOpportunities = true;
  bool newsUpdates = true;
  bool personalStrategy = true;
  bool personalizedInsights = true;
  bool marketingPromotions = true;
  String marketingDeliveryMethod = 'all'; // default value from API

  final PreferencesService _settingsService = PreferencesService();

  PreferencesModel({
    required this.paymentReminders,
    required this.acquisitionOpportunities,
    required this.newsUpdates,
    required this.personalStrategy,
    required this.personalizedInsights,
    required this.marketingPromotions,
    required this.marketingDeliveryMethod,
  });

  // Method to fetch settings
  Future<void> fetchSettings() async {
    try {
      final data = await _settingsService.fetchSettings();
      paymentReminders = data['notifications']['payment_reminders'];
      acquisitionOpportunities =
          data['notifications']['acquisition_opportunities'];
      newsUpdates = data['notifications']['news_updates'];
      personalStrategy = data['notifications']['personal_strategy'];
      personalizedInsights = data['notifications']['personalized_insights'];
      marketingPromotions = data['notifications']['marketing_promotions'];
      marketingDeliveryMethod =
          data['notifications']['marketing_delivery_method'];

      notifyListeners(); // Notify listeners after updating state
    } catch (e) {
      print('Error fetching settings: $e');
    }
  }

  // Method to update a specific setting
  void updateSetting(String settingName, bool value) {
    switch (settingName) {
      case 'payment_reminders':
        paymentReminders = value;
        break;
      case 'acquisition_opportunities':
        acquisitionOpportunities = value;
        break;
      case 'news_updates':
        newsUpdates = value;
        break;
      case 'personal_strategy':
        personalStrategy = value;
        break;
      case 'personalized_insights':
        personalizedInsights = value;
        break;
      case 'marketing_promotions':
        marketingPromotions = value;
        break;
      default:
        break;
    }

    notifyListeners(); // Notify listeners after updating state
    saveSettings(); // Save immediately after updating
  }

  // Method to update marketing delivery method
  void updateMarketingDeliveryMethod(String method) {
    marketingDeliveryMethod = method;
    notifyListeners(); // Notify listeners after updating marketing method
    saveSettings(); // Save immediately after updating marketing delivery method
  }

  // Method to save settings (POST)
  Future<void> saveSettings() async {
    try {
      print(
        "marketingDeliveryMethod: ${marketingDeliveryMethod.toLowerCase()}",
      );
      final settingsData = {
        'payment_reminders': paymentReminders,
        'acquisition_opportunities': acquisitionOpportunities,
        'news_updates': newsUpdates,
        'personal_strategy': personalStrategy,
        'personalized_insights': personalizedInsights,
        'marketing_promotions': marketingPromotions,
        'marketing_delivery_method': marketingDeliveryMethod.toLowerCase(),
      };

      await _settingsService.postSettings(settingsData);
      print('Settings successfully updated'); // Post the updated settings
    } catch (e) {
      print('Error saving settings: $e');
    }
  }
}
