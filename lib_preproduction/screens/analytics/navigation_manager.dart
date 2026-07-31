import 'package:GapHub/screens/analytics/edits/credit.dart';
import 'package:flutter/material.dart';
import 'package:GapHub/models/analyticsinfo.dart';

import 'edits/alpha.dart';
import 'edits/beta.dart';
import 'edits/debt.dart';
import 'edits/education.dart';
import 'edits/freedom.dart';
import 'edits/grand.dart';
import 'validation_helper.dart';

class NavigationManager {
  // Updated to accept 4 parameters: info, newUser, contains, fromSave
  static final Map<String, Widget Function(Analyticsinfo, bool, bool, bool)>
  _pageBuilder = {
    'credit': (info, newUser, contains, fromSave) => Credit(
      creditInfo: info,
      newUser: newUser,
      contains: contains,
      fromSave: fromSave,
    ),
    'grand': (info, newUser, contains, fromSave) => Grand(
      grandInfo: info,
      newUser: newUser,
      contains: contains,
      fromSave: fromSave,
    ),
    'freedom': (info, newUser, contains, fromSave) =>
        Freedom(freedomInfo: info, newUser: newUser, fromSave: fromSave),
    'education': (info, newUser, contains, fromSave) => Education(
      educationInfo: info,
      newUser: newUser,
      contains: contains,
      fromSave: fromSave,
    ),
    'debt': (info, newUser, contains, fromSave) => Debt(
      debtInfo: info,
      newUser: newUser,
      contains: contains,
      fromSave: fromSave,
    ),
    'beta': (info, newUser, contains, fromSave) => Beta(
      betaInfo: info,
      newUser: newUser,
      contains: contains,
      fromSave: fromSave,
    ),
    'alpha': (info, newUser, contains, fromSave) => Alpha(
      alphaInfo: info,
      newUser: newUser,
      contains: contains,
      fromSave: fromSave,
    ),
  };

  static void navigateToPage({
    required BuildContext context,
    required String pageType,
    required Analyticsinfo analyticsinfo,
    bool replace = false,
    bool fromSave = false,
  }) {
    final helper = ValidationHelper(analyticsinfo);
    final normalizedType = pageType.toLowerCase();

    final isValidType = _pageBuilder.containsKey(normalizedType);
    if (!isValidType) {
      debugPrint('Invalid page type: $pageType');
      return;
    }

    final mainValue = helper.getMainValue(normalizedType) ?? '';
    final hasMainValue = mainValue == '1';

    // Pass all 4 parameters to the page builder
    final page = _pageBuilder[normalizedType]!(
      analyticsinfo,
      hasMainValue,
      hasMainValue,
      fromSave, // Now this matches the 4-parameter signature
    );

    if (replace) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => page),
      );
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    }
  }

  static void navigateToNextUnvalidated({
    required BuildContext context,
    required Analyticsinfo analyticsinfo,
    required List<String> pageOrder,
  }) {
    final helper = ValidationHelper(analyticsinfo);

    for (final pageType in pageOrder) {
      if (helper.isNewUser(pageType)) {
        navigateToPage(
          context: context,
          pageType: pageType,
          analyticsinfo: analyticsinfo,
          replace: true,
          fromSave: true, // When auto-navigating, it's from save flow
        );
        return;
      }
    }
  }
}
