import 'package:GapHub/models/analyticsinfo.dart';

class ValidationHelper {
  final Analyticsinfo analyticsinfo;

  ValidationHelper(this.analyticsinfo);

  // Generic method to get value for any type
  dynamic getTypeValue(String type) {
    switch (type.toLowerCase()) {
      case 'credit':
        return analyticsinfo.credit;
      case 'grand':
        return analyticsinfo.grand;
      case 'freedom':
        return analyticsinfo.freedom;
      case 'education':
        return analyticsinfo.education;
      case 'debt':
        return analyticsinfo.dept;
      case 'beta':
        return analyticsinfo.beta;
      case 'alpha':
        return analyticsinfo.alpha;
      default:
        return null;
    }
  }

  // Check if a specific type is validated (has a valid main value)
  bool isValidated(String type) {
    final value = getTypeValue(type)?['main']?.toString() ?? '';
    return value.isNotEmpty && value != 'null';
  }

  // Check if it's a new user (not validated)
  bool isNewUser(String type) {
    final value = getTypeValue(type)?['main']?.toString() ?? '';
    return value.isEmpty || value == 'null';
  }

  // Get main value for any type
  String? getMainValue(String type) {
    return getTypeValue(type)?['main']?.toString();
  }

  // Specific getters for each type
  bool get isCreditValidated => isValidated('credit');
  bool get isGrandValidated => isValidated('grand');
  bool get isFreedomValidated => isValidated('freedom');
  bool get isEducationValidated => isValidated('education');
  bool get isDebtValidated => isValidated('debt');
  bool get isBetaValidated => isValidated('beta');
  bool get isAlphaValidated => isValidated('alpha');

  bool get isCreditNewUser => isNewUser('credit');
  bool get isGrandNewUser => isNewUser('grand');
  bool get isFreedomNewUser => isNewUser('freedom');
  bool get isEducationNewUser => isNewUser('education');
  bool get isDebtNewUser => isNewUser('debt');
  bool get isBetaNewUser => isNewUser('beta');
  bool get isAlphaNewUser => isNewUser('alpha');

  // Get validation status for all types
  Map<String, bool> getAllValidationStatus() {
    final types = [
      'credit',
      'grand',
      'freedom',
      'education',
      'debt',
      'beta',
      'alpha',
    ];
    return {for (var type in types) type: isValidated(type)};
  }
}
