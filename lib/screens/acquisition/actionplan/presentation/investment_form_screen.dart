import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/investment_form_controller.dart';
import 'widgets/InvestmentInfoBottomSheet.dart';
import 'widgets/essential_video_showModalBottomSheet.dart';
import 'forms/step_one.dart';
import 'forms/step_two.dart';
import 'forms/step_three.dart';
import 'forms/step_four.dart';
import 'forms/step_five.dart';

class InvestmentFormScreen extends ConsumerStatefulWidget {
  final String? strategyId;

  const InvestmentFormScreen({super.key, this.strategyId});

  @override
  ConsumerState<InvestmentFormScreen> createState() =>
      _InvestmentFormScreenState();
}

class _InvestmentFormScreenState extends ConsumerState<InvestmentFormScreen> {
  // Guards against re-fetching on every rebuild. Screens opened via
  // ActionPlanStrategy._resumeStrategy() already have the data loaded
  // before this screen is pushed, so this fetch is only a fallback for
  // entry points that navigate here directly with just a strategyId
  // (e.g. a deep link) — and it should only ever fire once per screen
  // instance, not every time state changes.
  bool _hasRequestedFetch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeFetchStrategy());
  }

  void _maybeFetchStrategy() {
    if (_hasRequestedFetch || widget.strategyId == null) return;

    final state = ref.read(investmentFormControllerProvider);
    if (state.investmentName.isNotEmpty || state.isLoading) return;

    _hasRequestedFetch = true;
    ref
        .read(investmentFormControllerProvider.notifier)
        .fetchStrategyData(widget.strategyId!);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(investmentFormControllerProvider);
    final controller = ref.read(investmentFormControllerProvider.notifier);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.contentColorWhite,
        appBar: AppBar(
          backgroundColor: AppColors.contentColorWhite,
          surfaceTintColor: AppColors.contentColorWhite,
          leading: IconButton(
            onPressed: () => controller.goToPreviousStep(context),
            icon: Icon(
              Icons.arrow_back_ios,
              size: 24.w,
              color: AppColors.blackColor,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [Color(0xffFF7A00), Color(0xffFFD439)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled:
                              true, // Allows content to determine height
                          backgroundColor: Colors
                              .transparent, // Transparent to show rounded corners
                          builder: (context) =>
                              const InvestmentInfoBottomSheet(),
                        );
                      },
                      child: Icon(Icons.info, size: 24.w, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [Color(0xffFF0001), Color(0xffCE0001)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled:
                              true, // Allows the sheet to take up most of the screen
                          backgroundColor: Colors
                              .transparent, // Transparent so we can see rounded corners
                          builder: (context) => DraggableScrollableSheet(
                            initialChildSize: 0.65, // Starts at 75% height
                            minChildSize: 0.4, // Can be dragged down to 40%
                            maxChildSize: 0.85, // Max height 85%
                            expand: false,
                            builder: (context, scrollController) {
                              return Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(56),
                                    topRight: Radius.circular(56),
                                  ),
                                ),
                                child: const EssentialVideoShowModalBottomSheet(
                                  videoUrl:
                                      'https://youtu.be/a02tWufmsos', // Your specific video
                                  thumbnailAssetPath:
                                      'assets/action_plan/video_img.png',
                                ),
                              );
                            },
                          ),
                        );
                      },
                      child: Icon(
                        Icons.play_circle_fill,
                        size: 24.w,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------- Progress Bar ----------------
                Row(
                  children: List.generate(controller.totalSteps, (index) {
                    double progress = 0.0;

                    if (index == state.currentStep) {
                      if (index == 0) progress = state.step1Progress;
                      if (index == 1) progress = state.step2Progress;
                      if (index == 2) progress = state.step3Progress;
                      if (index == 3) progress = state.step4Progress;
                      if (index == 4) progress = state.step5Progress;
                    } else if (index < state.currentStep) {
                      progress = 1.0; // Completed
                    } else {
                      progress = 0.0; // Future
                    }

                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: const Color(0xffE5E5E5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Stack(
                          children: [
                            FractionallySizedBox(
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xff009933),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),

                SizedBox(height: 16.h),

                // ✅ Success Message Banner
                if (state.successMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffD4EDDA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xff28A745)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: const Color(0xff28A745),
                          size: 20.w,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            state.successMessage!,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 14.sp,
                              color: const Color(0xff155724),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.clearMessages,
                          child: Icon(
                            Icons.close,
                            color: const Color(0xff155724),
                            size: 18.w,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],

                // ✅ Error Message Banner
                if (state.errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffF8D7DA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xffDC3545)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error,
                          color: const Color(0xffDC3545),
                          size: 20.w,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            state.errorMessage!,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 14.sp,
                              color: const Color(0xff721C24),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.clearMessages,
                          child: Icon(
                            Icons.close,
                            color: const Color(0xff721C24),
                            size: 18.w,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],

                SizedBox(height: 16.h),

                // ---------------- Step Content ----------------
                Expanded(child: _buildCurrentStepContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    return Consumer(
      builder: (context, ref, child) {
        final currentStep = ref.watch(
          investmentFormControllerProvider.select((s) => s.currentStep),
        );
        final isLoading = ref.watch(
          investmentFormControllerProvider.select((s) => s.isLoading),
        );

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        switch (currentStep) {
          case 0:
            return const StepOne();
          case 1:
            debugPrint(
              "Rendering StepTwo, items: ${ref.read(investmentFormControllerProvider).step2Items}",
            );
            return const StepTwo();
          case 2:
            return const StepThree();
          case 3:
            return const StepFour();
          case 4:
            return const StepFive();
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
