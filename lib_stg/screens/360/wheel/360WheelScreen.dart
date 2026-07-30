// three_sixty_wheel_screen.dart
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:shared_preferences/shared_preferences.dart';

// import '../controllers/wheel_controller.dart';
import '../iLAB/I360LabScreen.dart';
import 'controllers/wheel_controller.dart';
import 'providers/carousel_provider.dart';
import 'widgets/carousel_slider_widget.dart';
import 'widgets/rotating_wheel_painter.dart';

class ThreesSixtyWheelScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  const ThreesSixtyWheelScreen({super.key, this.initialCategory});

  @override
  ConsumerState<ThreesSixtyWheelScreen> createState() =>
      _ThreesSixtyWheelScreenState();
}

class _ThreesSixtyWheelScreenState
    extends ConsumerState<ThreesSixtyWheelScreen>
    with TickerProviderStateMixin {
  late WheelController _controller;

  // ── UI-only state (stays local — not needed by other widgets) ────────────
  bool _isDragging = false;
  bool _showArrows = true;
  Timer? _blinkTimer;

  // Arrow animation controllers
  late AnimationController _leftArrowController;
  late AnimationController _rightArrowController;
  late Animation<double> _leftArrowAnimation;
  late Animation<double> _rightArrowAnimation;

  // Idle carousel arrow pulse
  late AnimationController _idleCarouselArrowController;
  late Animation<double> _idleCarouselArrowAnimation;

  // iLab button tap feedback
  late AnimationController _ilabTapController;
  late Animation<double> _ilabScaleAnimation;
  late Animation<double> _ilabFadeAnimation;

  // Wheel animation on index change
  late AnimationController _wheelAnimationController;

  // Center icon images for the CustomPainter
  List<ui.Image> _centerIcons = [];

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _leftArrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _rightArrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _leftArrowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _leftArrowController, curve: Curves.elasticOut),
    );
    _rightArrowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rightArrowController, curve: Curves.elasticOut),
    );

    _idleCarouselArrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _idleCarouselArrowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _idleCarouselArrowController, curve: Curves.easeInOut),
    );

    _wheelAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _ilabTapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _ilabScaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _ilabTapController, curve: Curves.easeIn),
    );
    _ilabFadeAnimation = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(parent: _ilabTapController, curve: Curves.easeIn),
    );

    final carouselState = ref.read(carouselProvider);
    _controller = WheelController(
      wheelItems: carouselState.wheelItems,
      sideCardItems: carouselState.sideCardItems,
      setState: setState,
      context: context,
      providers: legacy_provider.Provider.of<Providers>(context, listen: false),
    );

    _startBlinking();
    _loadCenterIcons();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set initial category if provided via navigation argument.
      if (widget.initialCategory != null) {
        final items = ref.read(carouselProvider).wheelItems;
        final idx = items.indexWhere(
          (i) =>
              i.title.toLowerCase() ==
              widget.initialCategory!.toLowerCase(),
        );
        if (idx >= 0) ref.read(carouselProvider.notifier).selectIndex(idx);
      }
    
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _leftArrowController.dispose();
    _rightArrowController.dispose();
    _idleCarouselArrowController.dispose();
    _wheelAnimationController.dispose();
    _ilabTapController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _startBlinking() {
    _blinkTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) setState(() => _showArrows = !_showArrows);
    });
  }

  void _animateArrow(bool isLeft) {
    if (isLeft) {
      _leftArrowController.forward(from: 0).then((_) {
        _leftArrowController.reverse();
      });
    } else {
      _rightArrowController.forward(from: 0).then((_) {
        _rightArrowController.reverse();
      });
    }
  }

  Future<void> _loadCenterIcons() async {
    final items = ref.read(carouselProvider).wheelItems;
    final futures = items.map((item) async {
      final ByteData data = await rootBundle.load(item.centerIconPath);
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 64,
        targetHeight: 64,
      );
      final ui.FrameInfo frame = await codec.getNextFrame();
      return frame.image;
    }).toList();

    final images = await Future.wait(futures);
    if (mounted) setState(() => _centerIcons = images);
  }

  String _getDioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.badCertificate:
        return 'Invalid SSL certificate.';
      case DioExceptionType.badResponse:
        return 'Server error (${e.response?.statusCode}). Please try again.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      case DioExceptionType.unknown:
        if (e.message?.contains('SocketException') ?? false) {
          return 'No internet connection. Please check your network.';
        }
        return 'An unexpected error occurred. Please try again.';
    }
  }

  // ── iLab tap handler ──────────────────────────────────────────────────────

  Future<void> _onIlabTap() async {
    await _ilabTapController.reverse();
    if (!mounted) return;

    FocusScope.of(context).requestFocus(FocusNode());
    final dialogBox = DialogBox();
    final dio = Dio();

    dialogBox.waiting(context, 'Loading');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      if (token == null) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        Fluttertoast.showToast(
          backgroundColor: const Color(0xff00B050),
          msg: 'Authentication failed. Please log in again.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        return;
      }

      final response = await dio.get(
        '$baseUrl/app/360/ilab?period=current',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (Navigator.canPop(context)) Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map &&
            (data['status'] == true || data['status'] == null)) {
          legacy_provider.Provider.of<Providers>(context, listen: false)
              .setIlabdata(data['data']);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const I360LabScreen()),
          );
        } else {
          Fluttertoast.showToast(
            backgroundColor: Colors.red,
            msg: (data as Map?)?['message'] ?? 'Failed to load iLab data',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
      }
    } on DioException catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        msg: _getDioErrorMessage(e),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        msg: 'An error occurred: ${e.toString()}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Narrow watch — only rebuilds this widget when index changes.
    final selectedIndex = ref.watch(selectedIndexProvider);
    final carouselState = ref.watch(carouselProvider);

    return Container(
      color: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // ── "Scroll across" hint ──────────────────────────────────
                AnimatedOpacity(
                  opacity: _showArrows ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Text(
                        'Scroll across to view more',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xff393737),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Carousel navigation arrows ────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCarouselArrow(isLeft: true),
                      _buildCarouselArrow(isLeft: false),
                    ],
                  ),
                ),

                // ── Carousel slider ───────────────────────────────────────
                Transform.translate(
                  offset: Offset(0, -20.h),
                  child: SizedBox(
                    height: constraints.maxHeight * 0.5,
                    // No props needed — reads from Riverpod internally.
                    child: CarouselSliderWidget(controller: _controller),
                  ),
                ),

                // ── Wheel ─────────────────────────────────────────────────
                SizedBox(
                  height: constraints.maxHeight * 0.42,
                  child: Container(
                    color: Colors.white,
                    child: ClipRect(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(color: Colors.white),
                          ),

                          // Draggable wheel
                          Positioned(
                            bottom: -160.h,
                            left: -20.w,
                            right: -20.w,
                            child: GestureDetector(
                              onPanStart: (_) =>
                                  setState(() => _isDragging = true),
                              onPanUpdate: (details) {
                                // Delegate to Riverpod — no setState for state.
                                ref
                                    .read(carouselProvider.notifier)
                                    .updateRotation(details.delta.dx * 0.01);
                              },
                              onPanEnd: (_) {
                                setState(() => _isDragging = false);
                                ref
                                    .read(carouselProvider.notifier)
                                    .snapToNearest();
                              },
                              child: SizedBox(
                                height: 380.h,
                                width: double.infinity,
                                child: LayoutBuilder(
                                  builder: (context, c) {
                                    final size = min(c.maxWidth, 600.w);
                                    return CustomPaint(
                                      size: Size(size, size),
                                      painter: RotatingWheelPainter(
                                        carouselState.wheelItems,
                                        carouselState.wheelRotation,
                                        selectedIndex, 
                                        _centerIcons,
                                        carouselState.wheelItems
                                            .map((i) => i.gradienColor)
                                            .toList(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),

                          // iLab button
                          Positioned(
                            bottom: -40.h,
                            left: 0,
                            right: 0,
                            child: GestureDetector(
                              onTapDown: (_) => _ilabTapController.forward(),
                              onTapUp: (_) => _onIlabTap(),
                              onTapCancel: () => _ilabTapController.reverse(),
                              child: AnimatedBuilder(
                                animation: _ilabTapController,
                                builder: (_, child) => Transform.scale(
                                  scale: _ilabScaleAnimation.value,
                                  child: Opacity(
                                    opacity: _ilabFadeAnimation.value,
                                    child: child,
                                  ),
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/ILAB.png',
                                    width: 150.w,
                                    height: 160.h,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Pointer indicator
                          Positioned(
                            top: -5.h,
                            left: 0,
                            right: 0,
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Image.asset(
                                    'assets/images/pointer.png',
                                    width: 50.w,
                                    height: 50.h,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 12.h),
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: SizedBox(
                                      width: 8.w,
                                      height: 8.h,
                                      child: Image.asset(
                                        'assets/images/pointer_inside.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Wheel-level left/right arrows
                          Positioned(
                            top: 40.h,
                            left: 0,
                            right: 0,
                            height: 30.h,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildWheelArrow(isLeft: true),
                                  _buildWheelArrow(isLeft: false),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Arrow helpers (extracted to keep build() readable) ────────────────────

  Widget _buildCarouselArrow({required bool isLeft}) {
    return AnimatedOpacity(
      opacity: _showArrows ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: _showArrows
            ? () {
                _animateArrow(isLeft);
                if (isLeft) {
                  ref.read(carouselProvider.notifier).previous();
                } else {
                  ref.read(carouselProvider.notifier).next();
                }
              }
            : null,
        child: AnimatedBuilder(
          animation: _idleCarouselArrowController,
          builder: (_, child) {
            final t = _idleCarouselArrowAnimation.value;
            return Transform.translate(
              offset: Offset(isLeft ? t * 6 : -t * 6, -t * 3),
              child: child,
            );
          },
          child: SizedBox(
            width: 16.w,
            height: 16.h,
            child: Image.asset(
              isLeft
                  ? 'assets/wheel_segments/animate_left.png'
                  : 'assets/wheel_segments/animate_right.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWheelArrow({required bool isLeft}) {
    return AnimatedOpacity(
      opacity: _showArrows ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: () {
          _animateArrow(isLeft);
          if (isLeft) {
            ref.read(carouselProvider.notifier).previous();
          } else {
            ref.read(carouselProvider.notifier).next();
          }
        },
        child: AnimatedBuilder(
          animation: _idleCarouselArrowController,
          builder: (_, child) {
            final t = _idleCarouselArrowAnimation.value;
            return Transform.translate(
              offset: Offset(isLeft ? t * 6 : -t * 6, -t * 3),
              child: child,
            );
          },
          child: SizedBox(
            width: 20.w,
            height: 20.h,
            child: Image.asset(
              isLeft
                  ? 'assets/wheel_segments/animate_left_wheel.png'
                  : 'assets/wheel_segments/animate_right_wheel.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}