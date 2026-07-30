// providers/carousel_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wheel_item.dart';
import 'carousel_notifier.dart';

final carouselProvider =
    NotifierProvider<CarouselNotifier, CarouselState>(CarouselNotifier.new);

final selectedIndexProvider = Provider<int>((ref) {
  return ref.watch(carouselProvider.select((s) => s.selectedIndex));
});

final wheelRotationProvider = Provider<double>((ref) {
  return ref.watch(carouselProvider.select((s) => s.wheelRotation));
});

// ← NEW: lets CarouselSliderWidget know when to skip its sync animation
final isDraggingProvider = Provider<bool>((ref) {
  return ref.watch(carouselProvider.select((s) => s.isDragging));
});

final activeWheelItemProvider = Provider<WheelItem>((ref) {
  final state = ref.watch(carouselProvider);
  return state.wheelItems[state.selectedIndex];
});

final leftIndexProvider = Provider<int>((ref) {
  final state = ref.watch(carouselProvider);
  return (state.selectedIndex - 1 + state.wheelItems.length) %
      state.wheelItems.length;
});

final rightIndexProvider = Provider<int>((ref) {
  final state = ref.watch(carouselProvider);
  return (state.selectedIndex + 1) % state.wheelItems.length;
});