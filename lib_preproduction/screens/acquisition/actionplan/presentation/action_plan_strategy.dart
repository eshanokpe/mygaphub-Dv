import 'dart:math' as math;
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/investment_form_controller.dart';
import 'StrategyEmptyScreen.dart';
import 'investment_form_screen.dart';
import 'strategy_intro_screen.dart';
import 'widgets/welcome_strategy_subwidgets.dart';

const int kTotalStrategySteps = 5;

int computeCompletedSteps(dynamic strategy) {
  int completed = 0;
  bool _filled(dynamic v) => v != null && v.toString().trim().isNotEmpty;

  final hasBasicInfo =
      _filled(strategy['name']) &&
      _filled(strategy['reason']) &&
      _filled(strategy['category']);
  if (hasBasicInfo) completed++;

  final items = strategy['items'];
  final hasItems = items is List && items.isNotEmpty;
  if (hasItems) completed++;

  return completed;
} 

class ActionPlanStrategy extends ConsumerStatefulWidget {
  const ActionPlanStrategy({super.key});

  @override
  ConsumerState<ActionPlanStrategy> createState() => _ActionPlanStrategyState();
}

class _ActionPlanStrategyState extends ConsumerState<ActionPlanStrategy> {
  bool isLoading = false;
  List<dynamic> strategies = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStrategies();
    });
  }

  Future<void> _loadStrategies() async {
    setState(() => isLoading = true);
    final controller = ref.read(investmentFormControllerProvider.notifier);
    final result = await controller.fetchAllStrategies();
    setState(() {
      strategies = result;
      isLoading = false;
    });
  }

  // ✅ FIXED: Load data into state BEFORE navigating
  Future<void> _resumeStrategy(dynamic strategy) async {
    final controller = ref.read(investmentFormControllerProvider.notifier);

    // 1. Load the strategy data into the controller state first
    controller.loadFromStrategySummary(strategy);

    // 2. Optional: Also fetch fresh data from server if you want latest
    // await controller.fetchStrategyData(strategy['id'].toString());

    if (!mounted) return;

    // 3. Now open the form — it will have all data ready
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            InvestmentFormScreen(strategyId: strategy['id'].toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.contentColorWhite,
      appBar: AppBar(
        backgroundColor: AppColors.contentColorWhite,
        surfaceTintColor: AppColors.contentColorWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 22.sp),
          color: AppColors.blackColor,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: const BrandLogo(),
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : strategies.isEmpty
            ? const StrategyEmptyScreen()
            : _buildStrategiesList(),
      ),
    );
  }

  Widget _buildStrategiesList() {
    final incomplete = strategies.where((s) {
      return computeCompletedSteps(s) < kTotalStrategySteps;
    }).toList();

    final complete = strategies.where((s) {
      return computeCompletedSteps(s) >= kTotalStrategySteps;
    }).toList();

    return RefreshIndicator(
      onRefresh: _loadStrategies,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Row(
            children: [
              Text(
                'Strategy ',
                style: GoogleFonts.nunitoSans(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.blackColor,
                ),
              ),
              Image.asset("assets/action_plan/arrow_pin.png", width: 18.w),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            'Your action plan for smarter financial growth',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.grayColor,
            ),
          ),
          SizedBox(height: 28.h),

          if (incomplete.isNotEmpty) ...[
            _sectionLabel('INCOMPLETE STRATEGIES'),
            SizedBox(height: 12.h),
            ...incomplete.map(
              (s) => Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: _buildStrategyCard(s, isComplete: false),
              ),
            ),
            SizedBox(height: 12.h),
          ],

          if (complete.isNotEmpty) ...[
            _sectionLabel('COMPLETED STRATEGIES'),
            SizedBox(height: 12.h),
            ...complete.map(
              (s) => Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: _buildStrategyCard(s, isComplete: true),
              ),
            ),
            SizedBox(height: 12.h),
          ],

          SizedBox(height: 20.h),
          _buildCreateNewStrategyButton(),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.nunitoSans(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: AppColors.grayColor,
      ),
    );
  }

  Widget _buildStrategyCard(dynamic strategy, {required bool isComplete}) {
    final completed = computeCompletedSteps(strategy);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _resumeStrategy(strategy),
      child: Container(
        padding: EdgeInsets.only(left: 14.w, bottom: 6.h, right: 0.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffEAEAEA)),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10.h, bottom: 10.h, right: 0.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _StrategySpiralIcon(
                    completedSteps: completed,
                    totalSteps: kTotalStrategySteps,
                    size: 56.w,
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strategy['name'] ?? 'Unnamed Strategy',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blackColor,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          '$completed of $kTotalStrategySteps steps completed',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.grayColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 22.w,
                    color: AppColors.grayColor,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0.w,
              child: _buildStatusBadge(isComplete: isComplete),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge({required bool isComplete}) {
    final bg = isComplete ? const Color(0xFF1E8E3E) : const Color(0xFF931D1D);
    final label = isComplete ? 'Complete' : 'Incomplete';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(50),
          topRight: Radius.circular(80),
          bottomLeft: Radius.circular(50),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunitoSans(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCreateNewStrategyButton() {
    return Center(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StrategyIntroScreen()),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 18.w, color: AppColors.primaryColor),
              SizedBox(width: 6.w),
              Text(
                'Create New Strategy',
                style: GoogleFonts.nunitoSans(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StrategySpiralIcon extends StatelessWidget {
  final int completedSteps;
  final int totalSteps;
  final double size;
  final String centerImageAsset;

  const _StrategySpiralIcon({
    required this.completedSteps,
    required this.totalSteps,
    required this.size,
    this.centerImageAsset = 'assets/action_plan/target.png',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DashedRingPainter(
              completedSteps: completedSteps,
              totalSteps: totalSteps,
              trackColor: AppColors.grayColor.withOpacity(0.3),
              progressColor: const Color(0xFF3DCC5E),
            ),
          ),
          Image.asset(
            centerImageAsset,
            width: size * 0.56,
            height: size * 0.56,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.track_changes,
              size: size * 0.56,
              color: AppColors.grayColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedRingPainter extends CustomPainter {
  final int completedSteps;
  final int totalSteps;
  final Color trackColor;
  final Color progressColor;

  _DashedRingPainter({
    required this.completedSteps,
    required this.totalSteps,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;
    final segments = math.max(totalSteps, 1);

    const strokeWidth = 5.0;
    const gapFraction = 0.28;
    final slotAngle = (2 * math.pi) / segments;
    final dashAngle = slotAngle * (1 - gapFraction);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = trackColor;

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = progressColor;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final startOffset = -math.pi / 2;

    for (int i = 0; i < segments; i++) {
      final segmentStart = startOffset + (i * slotAngle);
      final isCompleted = i < completedSteps;
      canvas.drawArc(
        rect,
        segmentStart,
        dashAngle,
        false,
        isCompleted ? progressPaint : trackPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRingPainter oldDelegate) {
    return oldDelegate.completedSteps != completedSteps ||
        oldDelegate.totalSteps != totalSteps ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
