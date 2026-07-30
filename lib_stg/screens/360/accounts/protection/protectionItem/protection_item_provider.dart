import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'protection_item_model.dart';

// ── 1. ProtectionItemNotifier ────────────────────────────────────────────────
//
// Holds the selected protection item's parsed model.
// Initialised from the raw Map passed via the screen constructor, so no
// async fetch is required at this level.

class ProtectionItemNotifier
    extends StateNotifier<AsyncValue<ProtectionItemModel>> {
  ProtectionItemNotifier() : super(const AsyncValue.loading());

  /// Call this once from the screen's initState / build with the raw API map.
  void load(Map<String, dynamic> raw) {
    state = const AsyncValue.loading();
    try {
      final model = ProtectionItemModel.fromMap(raw);
      state = AsyncValue.data(model);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Convenience getter — non-null only when state is AsyncData.
  ProtectionItemModel? get item => state.whenOrNull(data: (v) => v);
}

// ── 2. Providers ─────────────────────────────────────────────────────────────

/// StateNotifierProvider for the currently viewed protection item.
final protectionItemProvider =
    StateNotifierProvider<ProtectionItemNotifier, AsyncValue<ProtectionItemModel>>(
  (ref) => ProtectionItemNotifier(),
);

// ── 3. Currency provider ─────────────────────────────────────────────────────
//
// Replace the body with a real source (e.g. watch your existing snapshotProvider)
// once you wire Riverpod into the rest of the app.
  // In protection_item_provider.dart — add this provider
final documentSizeProvider = FutureProvider.family<String, String>((ref, url) async {
  try {
    final response = await http.head(Uri.parse(url));
    final bytes = int.tryParse(response.headers['content-length'] ?? '');
    if (bytes == null) return 'PDF Document';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  } catch (_) {
    return 'PDF Document';
  }
});

final currencyProvider = Provider<String>((ref) => '£');