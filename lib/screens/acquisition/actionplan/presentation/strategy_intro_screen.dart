import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/investment_form_controller.dart';
import '../controller/strategy_intro_controller.dart';
import 'investment_form_screen.dart';
import 'widgets/welcome_strategy_subwidgets.dart';

class StrategyIntroScreen extends ConsumerWidget {
  const StrategyIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(strategyIntroControllerProvider);
    final controller = ref.read(strategyIntroControllerProvider.notifier);

    /// Navigate after logic completes
    Future<void> handleGetStarted() async {
      await controller.onGetStartedPressed();
      if (context.mounted) {
        // ✅ Clear any leftover state from a previously viewed/edited strategy
        ref.read(investmentFormControllerProvider.notifier).resetForm();

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const InvestmentFormScreen()),
        );
      }
    }

    return Scaffold(
      backgroundColor: AppColors.contentColorWhite,
      appBar: AppBar(
        backgroundColor: AppColors.contentColorWhite,
        surfaceTintColor: AppColors.contentColorWhite,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            size: 24.w,
            color: AppColors.blackColor,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: const BrandLogo(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),

              // ---------------- Title ----------------
              RichText(
                text: TextSpan(
                  style: GoogleFonts.nunitoSans(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackColor,
                    height: 1.3,
                  ),
                  children: const [
                    TextSpan(text: 'Ready to create your first\n'),
                    TextSpan(
                      text: 'Strategy?',
                      style: TextStyle(color: AppColors.primaryColor),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // ---------------- Description ----------------
              RichText(
                text: TextSpan(
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16.sp,
                    color: AppColors.blackColor,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text:
                          'To gain a better understanding of your goals, we\'ll ask you',
                    ),
                    TextSpan(
                      text: ' 5 ',
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'quick questions, which will assist you in developing a precise action plan.',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 60.h),

              // ---------------- Get Started Button ----------------
              SizedBox(
                width: double.infinity,
                child: InkWell(
                  onTap: state.isNavigating ? null : handleGetStarted,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Red vertical line
                      Container(
                        width: 6.w,
                        height: 42.h,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: 12.w),

                      // Text + Arrow
                      Row(
                        children: [
                          Text(
                            'Get Started',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blackColor,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          const _AnimatedChevron(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedChevron extends StatefulWidget {
  const _AnimatedChevron();

  @override
  State<_AnimatedChevron> createState() => _AnimatedChevronState();
}

class _AnimatedChevronState extends State<_AnimatedChevron>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _translateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800), // forward animation time
      reverseDuration: const Duration(
        milliseconds: 1800,
      ), // backward animation time
    );

    // Scale: 1.0 → 1.3 → 1.0
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Move: 0 → 6px right → 0
    _translateAnimation = Tween<double>(
      begin: 0,
      end: 6.w,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Repeat forward and backward forever
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_translateAnimation.value, 0), // horizontal movement
          child: Transform.scale(
            scale: _scaleAnimation.value, // scale up/down
            child: Icon(
              Icons.chevron_right,
              size: 25.w,
              color: AppColors.primaryColor,
            ),
          ),
        );
      },
    );
  }
}
