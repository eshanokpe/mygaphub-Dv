import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/investment_form_controller.dart';
import '../widgets/continue_strategising_popup.dart';
import '../widgets/custom_text_field.dart';

class StepOne extends ConsumerStatefulWidget {
  const StepOne({super.key});

  @override
  ConsumerState<StepOne> createState() => _StepOneState();
}

class _StepOneState extends ConsumerState<StepOne> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initial value
    final state = ref.read(investmentFormControllerProvider);
    _nameController.text = state.investmentName;
    _reasonController.text = state.investmentReason;
  }

  // ✅ Auto-update controllers when state changes
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = ref.watch(investmentFormControllerProvider);
    if (_nameController.text != state.investmentName) {
      _nameController.text = state.investmentName;
    }
    if (_reasonController.text != state.investmentReason) {
      _reasonController.text = state.investmentReason;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  String? _validateName(String? value, int minLength) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Investment name is required';
    if (v.length < minLength)
      return 'Name must be at least $minLength characters';
    return null;
  }

  String? _validateReason(String? value, int minLength) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Reason is required';
    if (v.length < minLength)
      return 'Reason must be at least $minLength characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(investmentFormControllerProvider);
    final formController = ref.read(investmentFormControllerProvider.notifier);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: 20.h),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why do you want to invest?',
              style: GoogleFonts.nunitoSans(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.blackColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Write down what drives your investment decisions',
              style: GoogleFonts.nunitoSans(
                fontSize: 16.sp,
                color: AppColors.blackColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 32.h),

            CustomTextField(
              label: 'Investment Name',
              hintText: 'Give your strategy a name. E.g. Strategy 1',
              controller: _nameController,
              onChanged: (value) => formController.updateInvestmentName(value),
              validator: (value) =>
                  _validateName(value, formController.minNameLength),
            ),
            SizedBox(height: 24.h),

            CustomTextField(
              label: 'Reason for Investing?',
              hintText: 'E.g. To increase financial resources',
              controller: _reasonController,
              onChanged: (value) =>
                  formController.updateInvestmentReason(value),
              validator: (value) =>
                  _validateReason(value, formController.minReasonLength),
              minLines: 2,
              maxLines: 4,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
            ),

            SizedBox(height: 180.h),
            if (state.investmentName.trim().isNotEmpty &&
                state.investmentReason.trim().isNotEmpty) ...[
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      formController.moveToNextStepOnly();
                    }
                  },
                  child: Row(
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
                      // ✅ delegate validation to the controller, not a Form key
                      if (formController.canProceed(context)) {
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
            ],
          ],
        ),
      ),
    );
  }
}
