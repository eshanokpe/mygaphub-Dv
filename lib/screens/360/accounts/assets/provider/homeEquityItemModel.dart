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
  final DateTime? dateAcquired;
  final String? document;
  final String? documentUrl;

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
    this.dateAcquired,
    this.document,
    this.documentUrl,
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
          (map['ownership_percentage'] ?? map['percentage_owned'])?.toString(),
      dateAcquired: parsedDate,
      document: map['document']?.toString(),
      documentUrl: map['document_url']?.toString(),
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
