// widgets/carousel_slider_widget.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/wheel_controller.dart';
import '../providers/carousel_provider.dart';
import 'active_card_widget.dart';
import 'side_card_widget.dart';

class CarouselSliderWidget extends ConsumerStatefulWidget {
  final void Function(int index)? onActiveTap;
  final WheelController controller;

  const CarouselSliderWidget({
    super.key,
    this.onActiveTap,
    required this.controller,
  });

  @override
  ConsumerState<CarouselSliderWidget> createState() =>
      _CarouselSliderWidgetState();
}

class _CarouselSliderWidgetState extends ConsumerState<CarouselSliderWidget> {
  static const int _midpoint = 50000;

  late PageController _pageController;
  late int _currentVirtualPage;
  bool _isProgrammaticScroll = false;
  bool _isUserScrolling = false;
  double _lastUserPage = 0;
  int _lastSyncedIndex = -1; // ← track what we last synced to
  int _scrollAnimationToken = 0;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(selectedIndexProvider);
    _lastSyncedIndex = initial;
    _currentVirtualPage = _midpoint + initial;
    _pageController = PageController(
      initialPage: _currentVirtualPage,
      viewportFraction: 0.52,
    );

    ref.listenManual<int>(selectedIndexProvider, (_, newIndex) {
      if (!mounted) return;
      final total = ref.read(carouselProvider).wheelItems.length;
      if (total == 0) return;

      final currentVirtualPage = _pageController.hasClients
          ? _pageController.page?.round() ?? _currentVirtualPage
          : _currentVirtualPage;
      final currentReal =
          ((currentVirtualPage - _midpoint) % total + total) % total;

      _syncScroll(
        newIndex,
        currentReal,
        total,
        animated: !ref.read(isDraggingProvider),
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final total = ref.read(carouselProvider).wheelItems.length;
      if (total == 0) return;

      _syncScroll(
        ref.read(selectedIndexProvider),
        _currentVirtualPage % total,
        total,
        animated: false,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Sync the PageView to a new real index ─────────────────────────────────
  // [animated] = false during wheel drag (instant), true for tap/arrow/snap
  void _syncScroll(
    int newRealIndex,
    int oldRealIndex,
    int total, {
    required bool animated,
  }) {
    if (!_pageController.hasClients) return;
    if (_isUserScrolling) return;
    if (_lastSyncedIndex == newRealIndex) return; // already there

    final currentPage =
        _pageController.page ?? (_midpoint + oldRealIndex).toDouble();
    final baseTarget = _midpoint + newRealIndex;
    final targetVirtual = [baseTarget - total, baseTarget, baseTarget + total]
        .reduce(
          (closest, candidate) =>
              (candidate - currentPage).abs() < (closest - currentPage).abs()
              ? candidate
              : closest,
        );

    _isProgrammaticScroll = true;
    _lastSyncedIndex = newRealIndex;
    final animationToken = ++_scrollAnimationToken;

    if (animated) {
      _pageController
          .animateToPage(
            targetVirtual,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
          )
          .then((_) {
            if (mounted && animationToken == _scrollAnimationToken) {
              _currentVirtualPage = _midpoint + newRealIndex;
              _pageController.jumpToPage(_currentVirtualPage);
              _isProgrammaticScroll = false;
            }
          });
    } else {
      // Instant jump — no animation during wheel drag
      _currentVirtualPage = _midpoint + newRealIndex;
      _pageController.jumpToPage(_currentVirtualPage);
      _isProgrammaticScroll = false;
    }
  }

  void _updateWheelFromCarouselDrag(int total) {
    if (!_pageController.hasClients || total == 0) return;

    final page = _pageController.page;
    if (page == null) return;

    final pageDelta = page - _lastUserPage;
    if (pageDelta.abs() < 0.0001) return;

    _lastUserPage = page;
    final sectionAngle = (2 * math.pi) / total;
    ref
        .read(carouselProvider.notifier)
        .updateRotation(-pageDelta * sectionAngle);
  }

  void _finishCarouselDrag(int total) {
    if (!_isUserScrolling || !_pageController.hasClients || total == 0) {
      return;
    }

    final page = _pageController.page ?? _currentVirtualPage.toDouble();
    final targetPage = page.round();
    final realIndex = ((targetPage - _midpoint) % total + total) % total;

    _isUserScrolling = false;
    ref.read(carouselProvider.notifier).selectIndex(realIndex);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final wheelItems = ref.watch(
      carouselProvider.select((state) => state.wheelItems),
    );
    final sideCardItems = ref.watch(
      carouselProvider.select((state) => state.sideCardItems),
    );
    final total = wheelItems.length;
    if (total == 0) return const SizedBox.shrink(); // ← guard

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification &&
            notification.dragDetails != null) {
          _isUserScrolling = true;
          _lastUserPage =
              _pageController.page ?? _currentVirtualPage.toDouble();
        } else if (notification is ScrollUpdateNotification &&
            _isUserScrolling) {
          _updateWheelFromCarouselDrag(total);
        } else if (notification is ScrollEndNotification) {
          _finishCarouselDrag(total);
        }
        return false;
      },
      child: PageView.builder(
        padEnds: true,
        pageSnapping: false,
        clipBehavior: Clip.none,
        controller: _pageController,
        onPageChanged: (virtualIndex) {
          if (_isProgrammaticScroll) return;
          final real = ((virtualIndex - _midpoint) % total + total) % total;
          _currentVirtualPage = _midpoint + real;
        },
        itemBuilder: (context, virtualIndex) {
          final real = ((virtualIndex - _midpoint) % total + total) % total;
          final bool isActive = real == selectedIndex;
          final int leftReal = (selectedIndex - 1 + total) % total;

          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double page =
                  _pageController.hasClients && _pageController.page != null
                  ? _pageController.page!
                  : _currentVirtualPage.toDouble();

              final double distance = (virtualIndex - page).abs();
              final double scale = (1.0 - (distance * 0.15)).clamp(0.85, 1.0);
              final double opacity = (1.0 - (distance * 0.40)).clamp(0.55, 1.0);

              return Transform.scale(
                scale: scale,
                child: Opacity(opacity: opacity, child: child),
              );
            },
            child: Center(
              child: isActive
                  ? ActiveCardWidget(
                      item: wheelItems[real],
                      index: real,
                      controller: widget.controller,
                    )
                  : SideCardWidget(
                      key: ValueKey('card_$real'),
                      item: sideCardItems[real],
                      index: real,
                      isLeft: real == leftReal,
                      controller: widget.controller,
                    ),
            ),
          );
        },
      ),
    );
  }
}
