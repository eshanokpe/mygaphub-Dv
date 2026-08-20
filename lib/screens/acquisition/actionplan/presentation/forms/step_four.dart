import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/investment_form_controller.dart';
import '../widgets/continue_strategising_popup.dart';

class StepFour extends ConsumerStatefulWidget {
  const StepFour({super.key});

  @override
  ConsumerState<StepFour> createState() => _StepFourState();
}

class _StepFourState extends ConsumerState<StepFour> {
  final List<Map<String, String>> _questions = const [
    {
      "sub": "opportunity_age",
      "label": "How old is this opportunity?",
      "hint": "Number of years since the venture started",
    },
    {
      "sub": "successful_investors",
      "label":
          "How many people have successfully invested in the last 5 years?",
      "hint": "Approximate number of investors or success stories",
    },
    {
      "sub": "team_experience",
      "label": "How experienced are the team behind the opportunity?",
      "hint": "Team background, years of experience",
    },
    {
      "sub": "customer_value",
      "label":
          "What customer value do they create and who are their customers?",
      "hint": "Benefits offered, target audience",
    },
    {
      "sub": "other_details",
      "label": "Any other details",
      "hint": "Additional notes, risks, or unique selling points",
    },
  ];

  List<TextEditingController> _controllers = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final state = ref.read(investmentFormControllerProvider);
    _controllers = List.generate(
      _questions.length,
      (i) => TextEditingController(
        text: i < state.step4Items.length ? state.step4Items[i]["note"] : "",
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = ref.read(investmentFormControllerProvider.notifier);
      for (int i = 0; i < _questions.length; i++) {
        controller.updateStep4Item(
          i,
          _questions[i]["sub"]!,
          _controllers[i].text,
        );
      }
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(investmentFormControllerProvider);
    final controller = ref.read(investmentFormControllerProvider.notifier);

    // ✅ Show messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.successMessage!),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
        controller.clearMessages();
      }
      if (state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
        controller.clearMessages();
      }
    });

    // ✅ Use controller state (not local bool) so back-navigation from
    // goToPreviousStep() correctly flips this back to the intro screen.
    return state.step4ShowInvestigateForm
        ? _buildInvestigateForm(context, state, controller)
        : _buildIntroUI(context, controller, state);
  }

  // ---------------- FIRST UI ----------------
  Widget _buildIntroUI(
    BuildContext context,
    InvestmentFormController controller,
    dynamic state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'When do you want to invest?',
          style: GoogleFonts.nunitoSans(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'We invest only after investigating identified ventures.',
          style: GoogleFonts.nunitoSans(
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.blackColor,
            height: 1.4,
          ),
        ),

        const Spacer(flex: 2),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.rotate(
                angle: 30 * 3.1415926535 / 180,
                alignment: Alignment.topLeft,
                child: Image.asset(
                  "assets/action_plan/thinking_out_of_box.png",
                  width: 56.w,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "You're already on the path to investing, Use the system-generated questions to learn more before you decide.",
                style: GoogleFonts.nunitoSans(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.blackColor,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        const Spacer(flex: 3),

        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.r),
              ),
              elevation: 0,
            ),
            onPressed: state.isNavigating
                ? null
                : () => controller.setStep4InvestigateForm(true),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continue',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 6.w),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  // ---------------- SECOND UI (Investigate) ----------------
  Widget _buildInvestigateForm(
    BuildContext context,
    dynamic state,
    InvestmentFormController controller,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Investigate',
              style: GoogleFonts.nunitoSans(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.blackColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Research and attempt answering the following questions',
              style: GoogleFonts.nunito(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.blackColor,
                height: 1.4,
              ),
            ),
            SizedBox(height: 24.h),

            for (int i = 0; i < _questions.length; i++) ...[
              Text(
                _questions[i]["label"]!,
                style: GoogleFonts.nunitoSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.blackColor,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _controllers[i],
                minLines: 1,
                maxLines: 3,
                onChanged: (val) =>
                    controller.updateStep4Item(i, _questions[i]["sub"]!, val),
                style: TextStyle(fontSize: 14.sp, color: AppColors.blackColor),
                validator: (value) {
                  final sub = _questions[i]["sub"];

                  // "other_details" is optional — skip validation for it
                  if (sub == "other_details") {
                    return null;
                  }
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  if (value.trim().length < 5) {
                    return 'The opportunity age must be at least 5 characters';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: _questions[i]["hint"],
                  hintStyle: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w300,
                    color: AppColors.grayColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: AppColors.grayColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: AppColors.grayColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(
                      color: AppColors.blackColor,
                      width: 1,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 14.h,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],

            SizedBox(height: 15.h),
            SizedBox(
              width: double.infinity,
              height: 60.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                onPressed: state.isNavigating
                    ? null
                    : () async {
                        print(
                          "🔵 Continue tapped. isNavigating: ${state.isNavigating}",
                        );
                        if (_formKey.currentState?.validate() ?? false) {
                          print("🟢 Form validated — advancing to StepFive");

                          // Fire the save in the background — don't block
                          // navigation on it. If it fails, the error banner
                          // still shows (via state.errorMessage), but the
                          // user isn't stuck on this screen waiting for the
                          // network. The final submit on StepFive is what
                          // actually needs to block on a successful save.
                          controller.saveAndContinueLater(context);

                          await controller.goToNextStep(context);
                          print(
                            "🟢 goToNextStep called, currentStep is now: "
                            "${ref.read(investmentFormControllerProvider).currentStep}",
                          );
                        } else {
                          print("🔴 Form validation FAILED");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fill all required fields"),
                            ),
                          );
                        }
                      },
                child: state.isNavigating
                    ? SizedBox(
                        height: 22.h,
                        width: 22.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4.w,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Icon(Icons.chevron_right, size: 20.w),
                        ],
                      ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0.w, 15.h, 0.w, 16.h),
              child: SizedBox(
                width: double.infinity,
                height: 60.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                      side: const BorderSide(color: Color(0xffC8CECC)),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24.0),
                            topRight: Radius.circular(24.0),
                          ),
                        ),
                        builder: (_) => const ContinueStrategisingPopup(
                          title:
                              "Do you want to save and continue strategising later?",
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill all required fields"),
                        ),
                      );
                    }
                  },
                  child: state.isNavigating
                      ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor,
                            ),
                          ),
                        )
                      : Text(
                          'Save and Continue Later',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackColor,
                          ),
                        ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
