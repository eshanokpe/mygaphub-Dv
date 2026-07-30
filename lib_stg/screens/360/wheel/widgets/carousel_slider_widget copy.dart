// widgets/carousel_slider_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  void initState() {
    super.initState();
    final initial = ref.read(selectedIndexProvider);
    _currentVirtualPage = _midpoint + initial;
    _pageController = PageController(
      initialPage: _currentVirtualPage,
      viewportFraction: 0.50,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _syncScroll(int newRealIndex, int oldRealIndex, int total) {
    if (!_pageController.hasClients) return;

    final int forwardSteps = (newRealIndex - oldRealIndex + total) % total;
    final int backwardSteps = total - forwardSteps;
    final int delta =
        forwardSteps <= backwardSteps ? forwardSteps : -backwardSteps;

    _currentVirtualPage = _midpoint + oldRealIndex;
    final int targetVirtual = _currentVirtualPage + delta;

    _isProgrammaticScroll = true;
    _pageController
        .animateToPage(
          targetVirtual,
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
        )
        .then((_) {
          if (mounted) {
            _currentVirtualPage = _midpoint + newRealIndex;
            _pageController.jumpToPage(_currentVirtualPage);
            _isProgrammaticScroll = false;
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final state = ref.watch(carouselProvider);
    final total = state.wheelItems.length;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final currentPage = _pageController.hasClients
          ? _pageController.page?.round() ?? _currentVirtualPage
          : _currentVirtualPage;
      final currentReal =
          ((currentPage - _midpoint) % total + total) % total;

      if (currentReal != selectedIndex && !_isProgrammaticScroll) {
        _syncScroll(selectedIndex, currentReal, total);
      }
    });

    return PageView.builder(
      padEnds: true,
      controller: _pageController,
      onPageChanged: (virtualIndex) {
        if (_isProgrammaticScroll) return;
        final real = ((virtualIndex - _midpoint) % total + total) % total;
        if (real != selectedIndex) {
          HapticFeedback.lightImpact();
          _currentVirtualPage = _midpoint + real;
          ref.read(carouselProvider.notifier).selectIndex(real);
        }
      },
      itemBuilder: (context, virtualIndex) {
        final real = ((virtualIndex - _midpoint) % total + total) % total;
        final bool isActive = real == selectedIndex;
        final int leftReal = (selectedIndex - 1 + total) % total;

        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            double page = _pageController.hasClients &&
                    _pageController.page != null
                ? _pageController.page!
                : _currentVirtualPage.toDouble();

            final double distance = (virtualIndex - page).abs();
            final double scale =
                (1.0 - (distance * 0.15)).clamp(0.85, 1.0);
            final double opacity =
                (1.0 - (distance * 0.40)).clamp(0.55, 1.0);

            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: child,
              ),
            );
          },
          child: Center(
            child: isActive
                ? ActiveCardWidget(
                    item: state.wheelItems[real],
                    index: real,
                    controller: widget.controller,
                  )
                : SideCardWidget(
                    key: ValueKey('card_$real'),
                    item: state.sideCardItems[real],
                    index: real,
                    isLeft: real == leftReal,
                    controller: widget.controller,
                  ),
          ),
        );
      },
    );
  }
}