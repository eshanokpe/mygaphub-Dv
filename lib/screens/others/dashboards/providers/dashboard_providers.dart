// providers/dashboard_providers.dart
//
// All Riverpod providers for the Dashboard shell.
// Keeping them here means dashboard.dart only imports what it needs,
// and each provider recomputes independently.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// ── Tab index ────────────────────────────────────────────────────────────
/// The ONLY thing that changes on a nav tap.
/// Updating this rerenders only widgets that watch it — nothing else.
final tabIndexProvider = StateProvider<int>((ref) => 0);
