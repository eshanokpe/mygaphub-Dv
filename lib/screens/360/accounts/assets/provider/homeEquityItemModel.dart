// home_equity_item_model.dart
import 'package:intl/intl.dart';

class HomeEquityItemModel {
  final String? propertyName; // e.g. "33 Lark Lane" — display title
  final String? city;
  final String? country;
  final String? addressLine1;
  final String? addressLine2;
  final String? townCity;
  final String? postcode;
  final String? currency;
  final String? marketValue;
  final String? ownershipPercentage;
  final bool? ismortgage;
  final DateTime? dateAcquired;
  final String? document;
  final String? documentUrl;

  // Mortgage-specific fields (from nested "mortgage" object)
  final String? creditorName;
  final String? mortgageDescription;
  final String? securedAgainst;
  final String? openBalance;
  final String? currentBalance;
  final String? interestRate;
  final String? monthlyPay;
  final String? repaymentPlan;
  final DateTime? targetDate;

  // Chart data (from "chart" object)
  final List<String>? chartLabels;
  final List<double>? chartValues;
  final List<double>? chartPercentages;

  const HomeEquityItemModel({
    this.propertyName,
    this.city,
    this.country,
    this.addressLine1,
    this.addressLine2,
    this.townCity,
    this.postcode,
    this.currency,
    this.marketValue,
    this.ownershipPercentage,
    this.ismortgage,
    this.dateAcquired,
    this.document,
    this.documentUrl,

    this.creditorName,
    this.mortgageDescription,
    this.securedAgainst,
    this.openBalance,
    this.currentBalance,
    this.interestRate,
    this.monthlyPay,
    this.repaymentPlan,
    this.targetDate,

    this.chartLabels,
    this.chartValues,
    this.chartPercentages,
  });

  factory HomeEquityItemModel.fromMap(Map<String, dynamic> map) {
    DateTime? parsedDate;
    final rawDate = map['date_acquired'] ?? map['target_date'];
    if (rawDate != null && rawDate.toString().isNotEmpty) {
      parsedDate = DateTime.tryParse(rawDate.toString());
    }

    // Address can come nested (address: {address_line_1: ...}) or flat.
    final addressMap = map['address'] is Map
        ? Map<String, dynamic>.from(map['address'])
        : map;
    // Mortgage is a separate nested object — pull it out safely.
    final mortgageMap = map['mortgage'] is Map
        ? Map<String, dynamic>.from(map['mortgage'])
        : <String, dynamic>{};

    DateTime? parsedTargetDate;
    final rawTargetDate = mortgageMap['target_date'];
    if (rawTargetDate != null && rawTargetDate.toString().isNotEmpty) {
      parsedTargetDate = DateTime.tryParse(rawTargetDate.toString());
    }

    // Chart is a separate nested object — pull it out safely.
    final chartMap = map['chart'] is Map
        ? Map<String, dynamic>.from(map['chart'])
        : <String, dynamic>{};

    List<String>? parsedLabels;
    if (chartMap['labels'] is List) {
      parsedLabels = (chartMap['labels'] as List)
          .map((e) => e.toString())
          .toList();
    }

    List<double>? parsedValues;
    if (chartMap['values'] is List) {
      parsedValues = (chartMap['values'] as List)
          .map((e) => (e as num).toDouble())
          .toList();
    }

    List<double>? parsedPercentages;
    if (chartMap['percentages'] is List) {
      parsedPercentages = (chartMap['percentages'] as List)
          .map((e) => (e as num).toDouble())
          .toList();
    }

    return HomeEquityItemModel(
      propertyName:
          (addressMap['address_line_1'] ??
                  map['address_line_1'] ??
                  map['location'])
              ?.toString(),
      city: (addressMap['town_city'] ?? map['town_city'])?.toString(),
      country: map['country']?.toString(),
      addressLine1: (addressMap['address_line_1'] ?? map['address_line_1'])
          ?.toString(),
      addressLine2: (addressMap['address_line_2'] ?? map['address_line_2'])
          ?.toString(),
      townCity: (addressMap['town_city'] ?? map['town_city'])?.toString(),
      postcode: (addressMap['postcode'] ?? map['postcode'])?.toString(),
      currency: map['currency']?.toString(),
      marketValue: map['market_value']?.toString(),
      ownershipPercentage:
          (map["ownership"] ?? map["mortgage"]['interest_rate'])?.toString(),
      ismortgage: map['ismortgage'] as bool?,
      dateAcquired: parsedDate,
      document: map['document']?.toString(),
      documentUrl: map['document_url']?.toString(),

      // Extracted from the nested "mortgage" object
      creditorName: mortgageMap['creditor_name']?.toString(),
      mortgageDescription: mortgageMap['description']?.toString(),
      securedAgainst: mortgageMap['secured_against']?.toString(),
      openBalance: mortgageMap['open_balance']?.toString(),
      currentBalance: mortgageMap['current_balance']?.toString(),
      interestRate: mortgageMap['interest_rate']?.toString(),
      monthlyPay: mortgageMap['monthly_pay']?.toString(),
      repaymentPlan: mortgageMap['repayment_plan']?.toString(),
      targetDate: parsedTargetDate,

      chartLabels: parsedLabels,
      chartValues: parsedValues,
      chartPercentages: parsedPercentages,
    );
  }

  String get formattedDateAcquired => dateAcquired != null
      ? DateFormat('dd MMMM yyyy').format(dateAcquired!)
      : '-';

  String get cityCountryLine {
    final parts = [
      city,
      country,
    ].where((e) => e != null && e.trim().isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(', ') : '-';
  }

  String get fullAddress {
    final parts = [
      addressLine1,
      addressLine2,
      townCity,
      postcode,
    ].where((e) => e != null && e!.trim().isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join('\n') : '-';
  }

  String get formattedMarketValue {
    final numValue = num.tryParse(marketValue ?? '') ?? 0;
    final parts = numValue.toStringAsFixed(2).split('.');
    final whole = NumberFormat('#,###').format(int.parse(parts[0]));
    return '$whole.${parts[1]}';
  }

  String get documentFileName =>
      (document != null && document!.isNotEmpty) ? document! : 'Document';
}
