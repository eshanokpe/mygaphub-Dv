import 'dart:math' as math;
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/investment_form_controller.dart';
import 'investment_form_screen.dart'; // Import your form screen

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.contentColorWhite,
      appBar: AppBar(
        backgroundColor: AppColors.contentColorWhite,
        surfaceTintColor: AppColors.contentColorWhite,
        elevation: 0,
        title: Text(
          'My Strategies',
          style: GoogleFonts.nunitoSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.blackColor,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 22),
          color: AppColors.blackColor,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : strategies.isEmpty
                ? _buildEmptyState()
                : _buildStrategiesList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80.w,
            color: AppColors.grayColor.withOpacity(0.5),
          ),
          SizedBox(height: 20.h),
          Text(
            'No saved strategies yet',
            style: GoogleFonts.nunitoSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap + to create your first investment strategy',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              fontSize: 14.sp,
              color: AppColors.grayColor,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Main list — header, "INCOMPLETE STRATEGIES" section, cards, and the
  // "Create New Strategy" footer action, matching the reference design.
  // ---------------------------------------------------------------------
  Widget _buildStrategiesList() {
    final incomplete = strategies.where((s) {
      final total = (s['total_steps'] ?? 5) as int;
      final completed = (s['completed_steps'] ?? 0) as int;
      return completed < total;
    }).toList();

    final complete = strategies.where((s) {
      final total = (s['total_steps'] ?? 5) as int;
      final completed = (s['completed_steps'] ?? 0) as int;
      return completed >= total;
    }).toList();

    return RefreshIndicator(
      onRefresh: _loadStrategies,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // Header ------------------------------------------------------
          Row(
            children: [
              Text(
                'Strategy ',
                style: GoogleFonts.nunitoSans(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.blackColor,
                ),
              ),
              Text('🎯', style: TextStyle(fontSize: 22.sp)),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            'Your action plan for smarter financial growth',
            style: GoogleFonts.nunitoSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.grayColor,
            ),
          ),
          SizedBox(height: 28.h),

          if (incomplete.isNotEmpty) ...[
            _sectionLabel('INCOMPLETE STRATEGIES'),
            SizedBox(height: 12.h),
            ...incomplete.map((s) => Padding(
                  padding: EdgeInsets.only(bottom: 14.h),
                  child: _buildStrategyCard(s, isComplete: false),
                )),
            SizedBox(height: 12.h),
          ],

          if (complete.isNotEmpty) ...[
            _sectionLabel('COMPLETED STRATEGIES'),
            SizedBox(height: 12.h),
            ...complete.map((s) => Padding(
                  padding: EdgeInsets.only(bottom: 14.h),
                  child: _buildStrategyCard(s, isComplete: true),
                )),
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
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: AppColors.grayColor,
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Individual strategy card with spiral progress icon + status badge
  // ---------------------------------------------------------------------
  Widget _buildStrategyCard(dynamic strategy, {required bool isComplete}) {
    final total = (strategy['total_steps'] ?? 5) as int;
    final completed = (strategy['completed_steps'] ?? 0) as int;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InvestmentFormScreen(
              strategyId: strategy['id'].toString(),
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _StrategySpiralIcon(
                  completedSteps: completed,
                  totalSteps: total,
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
                        '$completed of $total steps completed',
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
            Positioned(
              top: -6.h,
              right: -6.w,
              child: _buildStatusBadge(isComplete: isComplete),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge({required bool isComplete}) {
    final bg = isComplete ? const Color(0xFF1E8E3E) : const Color(0xFF8E1E24);
    final label = isComplete ? 'Complete' : 'Incomplete';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunitoSans(
          fontSize: 11.sp,
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
            MaterialPageRoute(
              builder: (_) => const InvestmentFormScreen(),
            ),
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

// ---------------------------------------------------------------------
// Strategy progress icon: a single dashed ring made of `totalSteps`
// segments running clockwise from the top. Completed segments are
// colored (progress), the rest sit faded/gray as the track. A target
// image sits centered on top of the ring.
// ---------------------------------------------------------------------
class _StrategySpiralIcon extends StatelessWidget {
  final int completedSteps;
  final int totalSteps;
  final double size;
  final String centerImageAsset;

  const _StrategySpiralIcon({
    required this.completedSteps,
    required this.totalSteps,
    required this.size,
    this.centerImageAsset = 'assets/images/target.png',
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
          // Center image — swap centerImageAsset for your own asset path.
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
    const gapFraction = 0.28; // portion of each segment slot left as gap
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
    final startOffset = -math.pi / 2; // begin at the top, clockwise

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