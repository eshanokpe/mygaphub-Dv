import 'dart:math' as math;
import 'package:GapHub/screens/others/dashboards/dashboard.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../controller/investment_form_controller.dart';
import 'Investment_viewScreen.dart';
import 'StrategyEmptyScreen.dart';
import 'investment_form_screen.dart';
import 'strategy_intro_screen.dart';
import 'widgets/welcome_strategy_subwidgets.dart';

const int kTotalStrategySteps = 5;

bool _isFilled(dynamic value) {
  if (value == null) return false;

  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;

    final parsed = num.tryParse(trimmed);
    if (parsed != null) return parsed > 0;

    return true;
  }

  if (value is num) return value > 0;
  if (value is bool) return value;
  if (value is List) return value.any(_isFilled);
  if (value is Map) return value.values.any(_isFilled);

  return value.toString().trim().isNotEmpty;
}

bool _hasFilledItems(dynamic items) {
  if (items is! List || items.isEmpty) return false;

  return items.any((item) {
    if (item is Map) {
      return _isFilled(item['note']);
    }
    return _isFilled(item);
  });
}

int computeCompletedSteps(dynamic strategy) {
  if (strategy is! Map) return 0;

  int completed = 0;

  final name = strategy['name'];
  final reason = strategy['reason'];
  final category = strategy['category'];
  final items = strategy['items'];
  final savingsChoice = strategy['savings_choice'];
  final newMonthlySavings = strategy['new_monthly_savings'];
  final obtainPlan = strategy['obtain_plan'];
  final investigation = strategy['investigation'];
  final monthlyPercent = strategy['monthly_percent'];
  final lumpsumPercent = strategy['lumpsum_percent'];

  // Step 1: Name + Reason
  if (_isFilled(name) && _isFilled(reason)) completed++;

  // Step 2: Category + Items
  if (_isFilled(category) && _hasFilledItems(items)) completed++;

  // Step 3: Savings goal. An increase choice is complete only after both
  // additional fields have been saved; keeping the amount needs no extras.
  final hasSavingsGoal =
      savingsChoice == 'keep_amount' ||
      (savingsChoice == 'increase_amount' &&
          _isFilled(newMonthlySavings) &&
          _isFilled(obtainPlan));
  if (hasSavingsGoal) completed++;

  // Step 4: Investigation
  if (_isFilled(investigation)) completed++;

  // Step 5: Allocation completed
  if (_isFilled(monthlyPercent) && _isFilled(lumpsumPercent)) completed++;

  return completed > kTotalStrategySteps ? kTotalStrategySteps : completed;
}

class ActionPlanStrategy extends ConsumerStatefulWidget {
  const ActionPlanStrategy({super.key});

  @override
  ConsumerState<ActionPlanStrategy> createState() => _ActionPlanStrategyState();
}

class _ActionPlanStrategyState extends ConsumerState<ActionPlanStrategy> {
  bool _isLoading = false;
  String? _resumingStrategyId;
  List<dynamic> _strategies = [];

  bool get _isResuming => _resumingStrategyId != null;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStrategies();
    });
  }

  Future<void> _loadStrategies() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final controller = ref.read(investmentFormControllerProvider.notifier);

    final result = await controller.fetchAllStrategies();

    if (!mounted) return;

    setState(() {
      _strategies = result;
      _isLoading = false;
    });
  }

  Future<void> _resumeStrategy(dynamic strategy) async {
    if (_isResuming) return;

    final id = strategy['id']?.toString();
    if (id == null || id.isEmpty) return;

    setState(() => _resumingStrategyId = id);

    final controller = ref.read(investmentFormControllerProvider.notifier);

    try {
      // Clear old form data before loading another strategy
      controller.resetForm();

      // Load summary data immediately
      controller.loadFromStrategySummary(strategy);

      // Fetch full strategy data from server
      await controller.fetchStrategyData(id);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => InvestmentFormScreen(strategyId: id)),
      );
    } finally {
      if (mounted) {
        setState(() => _resumingStrategyId = null);
      }
    }
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
            child: InkWell(
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const Dashboard(index: 0),
                  settings: const RouteSettings(name: '/dashboard'),
                ),
                (route) => false,
              ),
              child: const BrandLogo(),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _strategies.isEmpty
                ? const StrategyEmptyScreen()
                : _buildStrategiesList(),
          ),

          if (_isResuming)
            Positioned.fill(
              child: Container(
                color: Colors.black12,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStrategiesList() {
    final incomplete = _strategies
        .where((s) => computeCompletedSteps(s) < kTotalStrategySteps)
        .toList();

    final complete = _strategies
        .where((s) => computeCompletedSteps(s) >= kTotalStrategySteps)
        .toList();

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
            _sectionLabel(' STRATEGIES'),
            SizedBox(height: 12.h),
            ...complete.map(
              (s) => Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: _buildStrategyCardCompleted(s, isComplete: true),
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

  Widget _buildStrategyCardCompleted(
    dynamic strategy, {
    required bool isComplete,
  }) {
    final completed = computeCompletedSteps(strategy);
    final id = strategy['id']?.toString();
    final isThisResuming = _resumingStrategyId == id;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => {
        print("strategy:${strategy['investigation']}"),
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => InvestmentViewScreen(strategy)),
        ),
      },
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
                  Image.asset(
                    'assets/action_plan/target22.png',
                    height: 44.h,
                    width: 44.w,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _capitalize(
                            strategy['name']?.toString() ?? 'Unnamed Strategy',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blackColor,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _capitalize(
                            strategy['category']?.toString() ??
                                'Unnamed Strategy',
                          ),
                          style: GoogleFonts.nunitoSans(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.grayColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        _formatDate(strategy['created_at']),
                        style: GoogleFonts.nunitoSans(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.grayColor,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 22.w,
                        color: AppColors.grayColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategyCard(dynamic strategy, {required bool isComplete}) {
    final completed = computeCompletedSteps(strategy);
    final id = strategy['id']?.toString();
    final isThisResuming = _resumingStrategyId == id;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _isResuming ? null : () => _resumeStrategy(strategy),
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
                          strategy['name']?.toString() ?? 'Unnamed Strategy',
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
        onTap: _isResuming
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StrategyIntroScreen(),
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

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  String _formatDate(dynamic rawDate) {
    if (rawDate == null) return '';
    final date = DateTime.tryParse(rawDate.toString());
    if (date == null) return rawDate.toString();
    return DateFormat('dd MMM yyyy').format(date);
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
