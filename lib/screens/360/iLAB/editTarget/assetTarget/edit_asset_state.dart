import 'package:flutter/material.dart';

/// Immutable state owned by [EditAssetNotifier].
@immutable
class EditAssetState {
  const EditAssetState({
    this.investmentDisplay = '0.00',
    this.homeEquityDisplay = '0.00',
    this.cashDisplay = '0.00',
    this.isDirty = false,
    this.isLoading = false,
  });

  final String investmentDisplay;
  final String homeEquityDisplay;
  final String cashDisplay;
  final bool isDirty;
  final bool isLoading;

  EditAssetState copyWith({
    String? investmentDisplay,
    String? homeEquityDisplay,
    String? cashDisplay,
    bool? isDirty,
    bool? isLoading,
  }) {
    return EditAssetState(
      investmentDisplay: investmentDisplay ?? this.investmentDisplay,
      homeEquityDisplay: homeEquityDisplay ?? this.homeEquityDisplay,
      cashDisplay: cashDisplay ?? this.cashDisplay,
      isDirty: isDirty ?? this.isDirty,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}