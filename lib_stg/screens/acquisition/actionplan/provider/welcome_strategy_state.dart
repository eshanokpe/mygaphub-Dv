import 'package:flutter/material.dart';

/// Simple state describing this onboarding step.
class WelcomeStrategyState {
  final bool isNavigating;
 
  const WelcomeStrategyState({this.isNavigating = false});

  WelcomeStrategyState copyWith({bool? isNavigating}) {
    return WelcomeStrategyState(
      isNavigating: isNavigating ?? this.isNavigating,
    );
  }
}