// protection_item_model.dart
import 'package:GapHub/utils/constants.dart';
import 'package:intl/intl.dart';

class ProtectionItemModel {
  final int id;
  final int userId;
  final String protectionCategory;
  final String protectionType;
  final String? details;
  final String? providerContact;
  final String? providerPolicy;
  final String? bank;
  final String? currency;
  final double sumAssured;
  final double premiumPay;
  final double currentBalance;
  final String payFrequency;
  final int paymentType;
  final DateTime? coverStart;
  final DateTime? coverEnd;
  final String? document;
  final String? documentUrl;
  final String? extra;
  final String? other;
  final bool isArchive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProtectionItemModel({
    required this.id,
    required this.userId,
    required this.protectionCategory,
    required this.protectionType,
    this.details,
    this.providerContact,
    this.providerPolicy,
    this.bank,
    this.currency,
    required this.sumAssured,
    required this.premiumPay,
    required this.currentBalance,
    required this.payFrequency,
    required this.paymentType,
    this.coverStart,
    this.coverEnd,
    this.document,
    this.documentUrl,
    this.extra,
    this.other,
    required this.isArchive,
    this.createdAt,
    this.updatedAt,
  });

  factory ProtectionItemModel.fromMap(Map<String, dynamic> map) {
    return ProtectionItemModel( 
      id: _toInt(map['id']),
      userId: _toInt(map['user_id']),
      protectionCategory: map['protection_category']?.toString() ?? '',
      protectionType: map['protection_type']?.toString() ?? '',
      details: map['details']?.toString(),
      providerContact: map['provider_contact']?.toString(),
      providerPolicy: map['provider_policy']?.toString(),
      bank: map['bank']?.toString(),
      currency: map['currency']?.toString(),
      sumAssured: _toDouble(map['sum_assured']),
      premiumPay: _toDouble(map['premium_pay']),
      currentBalance: _toDouble(map['current_balance']),
      payFrequency: map['pay_frequency']?.toString() ?? 'Monthly',
      paymentType: _toInt(map['payment_type']),
      coverStart: _parseDate(map['cover_start']),
      coverEnd: _parseDate(map['cover_end']),
      document: map['document']?.toString(),
      documentUrl: map['document_url']?.toString(),
      extra: map['extra']?.toString(),
      other: map['other']?.toString(),
      isArchive: _toInt(map['isArchive']) == 1,
      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
    );
  }

  // ── Derived helpers ──────────────────────────────────────────────────────

  /// "Direct Debit" | "Debit/Credit Card" | "Standing Order" based on paymentType flag.
  String get paymentTypeLabel {
    switch (paymentType) {
      case 0:
        return 'Direct Debit';
      case 1:
        return 'Debit/Credit Card';
      case 2:
        return 'Standing Order';
      default:
        return 'Direct Debit';
    }
  }

  /// Filename extracted from the document path.
  String get documentFileName {
    if (document == null || document!.isEmpty) return 'Document';
    return document!.split('/').last;
  }

  /// Formatted cover start date, e.g. "5 Jun 2026".
  String get formattedCoverStart => _fmt(coverStart);

  /// Formatted cover end date, e.g. "8 Jun 2026".
  String get formattedCoverEnd => _fmt(coverEnd);

  /// Whole-number part of sum assured, e.g. "150".
  String get sumAssuredWhole =>
      sumAssured.toStringAsFixed(2).split('.').first;

  /// Decimal part of sum assured, e.g. "00".
  String get sumAssuredDecimal =>
      sumAssured.toStringAsFixed(2).split('.').last;

  /// Whole-number part of premium, e.g. "180".
  String get premiumWhole => premiumPay.toStringAsFixed(2).split('.').first;

  /// Decimal part of premium, e.g. "00".
  String get premiumDecimal => premiumPay.toStringAsFixed(2).split('.').last;

  /// Raw sum assured as a plain string for form pre-population.
  String get rawSumAssured => sumAssured.toStringAsFixed(2);

  /// Raw premium as a plain string for form pre-population.
  String get rawPremium => premiumPay.toStringAsFixed(2);

  // ── Private utilities ────────────────────────────────────────────────────

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return null;
    }
  }

  static String _fmt(DateTime? dt) {
    if (dt == null) return '—';
    return DateFormat('d MMM yyyy').format(dt);
  }


}