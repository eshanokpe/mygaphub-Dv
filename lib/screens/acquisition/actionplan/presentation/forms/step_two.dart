import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/investment_form_controller.dart';
import '../widgets/continue_strategising_popup.dart';
import '../widgets/investment_categories.dart';

class StepTwo extends ConsumerStatefulWidget {
  const StepTwo({super.key});

  @override
  ConsumerState<StepTwo> createState() => _StepTwoState();
}

class _StepTwoState extends ConsumerState<StepTwo> {
  // --------------------------
  // Data
  // --------------------------
  List<Map<String, dynamic>> get _options => investmentCategoryOptions
      .map((o) => {"id": o.id, "title": o.title, "imageAssets": o.imageAsset})
      .toList();

  Map<String, List<Map<String, String>>> get _categoryChecklists =>
      investmentCategoryChecklists.map(
        (categoryId, fields) => MapEntry(
          categoryId,
          fields
              .map(
                (f) => {
                  "sub_category": f.subCategory,
                  "label": f.label,
                  "hint": f.hint,
                },
              )
              .toList(),
        ),
      );

  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> _controllers = [];
  String? _activeCategory;

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  // --------------------------
  // Helpers
  // --------------------------
  void _initControllers(
    String? categoryId,
    List<Map<String, String>> savedItems,
  ) {
    if (categoryId == _activeCategory && _controllers.isNotEmpty) return;

    for (final c in _controllers) c.dispose();
    _controllers.clear();

    if (categoryId == null || !_categoryChecklists.containsKey(categoryId)) {
      _activeCategory = null;
      return;
    }

    final fields = _categoryChecklists[categoryId]!;
    _controllers = List.generate(fields.length, (index) {
      final saved = savedItems.firstWhere(
        (item) => item["sub_category"] == fields[index]["sub_category"],
        orElse: () => {"note": ""},
      );
      return TextEditingController(text: saved["note"] ?? "");
    });

    _activeCategory = categoryId;
  }

  void _saveFormData() {
    if (_activeCategory == null) return;
    final fields = _categoryChecklists[_activeCategory]!;
    final controller = ref.read(investmentFormControllerProvider.notifier);

    for (int i = 0; i < fields.length; i++) {
      controller.updateStep2Item(
        i,
        fields[i]["sub_category"]!,
        _controllers[i].text.trim(),
      );
    }
  }

  // ✅ Validator that accepts isRequired parameter
  String? _validateNote(String? value, {bool isRequired = true}) {
    if (!isRequired) return null; // Optional field, no validation

    final v = value?.trim() ?? '';
    if (v.isEmpty) return "This field is required";
    if (v.length < 3) return "Please enter at least 3 characters";
    return null;
  }

  // ✅ Check if a field is required based on category and index
  bool _isFieldRequired(int index) {
    if (_activeCategory == "retirement") {
      // For retirement: only first 3 fields are required (index 0, 1, 2)
      // "others_pension" at index 3 is optional
      return index < 3;
    }
    // For all other categories, all fields are required
    return true;
  }

  // ✅ Check if required fields are filled based on category
  bool _areRequiredFieldsFilled() {
    if (_activeCategory == null || _controllers.isEmpty) return false;

    if (_activeCategory == "retirement") {
      // For retirement: only first 3 fields (private_pension, state_pension, employer_pension) are required
      if (_controllers.length < 3) return false;
      return _controllers[0].text.trim().isNotEmpty &&
          _controllers[1].text.trim().isNotEmpty &&
          _controllers[2].text.trim().isNotEmpty;
    } else {
      // For investment, cash, equity: ALL fields are required
      return _controllers.every(
        (controller) => controller.text.trim().isNotEmpty,
      );
    }
  }

  // --------------------------
  // Build
  // --------------------------
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(investmentFormControllerProvider);
    final formController = ref.read(investmentFormControllerProvider.notifier);

    // ✅ KEY FIX: Show Form Session ONLY when items exist OR category was just selected in this session
    // If items is empty and it wasn't just selected, it forces SESSION 1 (Category Selection)
    final hasSelectedCategory =
        state.selectedCategory != null &&
        state.selectedCategory!.isNotEmpty &&
        (state.step2Items.isNotEmpty || state.step2CategoryJustSelected);

    // Only initialize controllers if we are actually showing the Form Session
    if (hasSelectedCategory) {
      _initControllers(state.selectedCategory, state.step2Items);
    } else {
      // Clear controllers if we are showing Session 1 to prevent memory leaks/stale data
      if (_activeCategory != null) {
        for (final c in _controllers) c.dispose();
        _controllers.clear();
        _activeCategory = null;
      }
    }

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
        formController.clearMessages();
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
        formController.clearMessages();
      }
    });

    debugPrint(
      "🔵 build() ran — selectedCategory: '${state.selectedCategory}', items: ${state.step2Items.length}, justSelected: ${state.step2CategoryJustSelected}, showForm: $hasSelectedCategory",
    );

    // ==============================================
    // SESSION 1: CHECKLIST / CATEGORY SELECTION
    // ==============================================
    if (!hasSelectedCategory) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where do you want to invest?',
            style: GoogleFonts.nunitoSans(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Select the best option that fits your current investment needs',
            style: GoogleFonts.nunitoSans(
              fontSize: 16.sp,
              color: AppColors.blackColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 32.h),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: _options.length,
              separatorBuilder: (_, __) => Divider(
                height: 1.h,
                thickness: 1.h,
                indent: 60.w,
                color: const Color(0xffefefef),
              ),
              itemBuilder: (context, index) {
                final item = _options[index];
                final isSelected = state.selectedCategory == item["id"];

                return InkWell(
                  // ✅ On select → update state, which automatically switches to Form Session
                  onTap: () => formController.updateSelectedCategory(
                    item["id"],
                    totalItems: _categoryChecklists[item["id"]]!.length,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 18.h,
                      horizontal: 12.w,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44.w,
                          height: 44.h,
                          decoration: BoxDecoration(
                            color: AppColors.grayColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 30.w,
                              height: 30.h,
                              child: Image.asset(
                                item["imageAssets"],
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Text(
                            item["title"],
                            style: GoogleFonts.nunitoSans(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    // ==============================================
    // SESSION 2: FORM SESSION
    // ==============================================
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: 20.h),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_options.firstWhere((o) => o["id"] == state.selectedCategory)["title"]} Checklist',
              style: GoogleFonts.nunitoSans(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.blackColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              // 'Document the actions you need to take to increase your ${state.selectedCategory} investment.',
              "Document the actions you need to take to increase your retirement investment.",
              style: GoogleFonts.nunitoSans(
                fontSize: 16.sp,
                color: AppColors.blackColor,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 32.h),

            ...List.generate(
              _categoryChecklists[state.selectedCategory]!.length,
              (index) {
                final field =
                    _categoryChecklists[state.selectedCategory]![index];
                final isRequired = _isFieldRequired(index);

                return Padding(
                  padding: EdgeInsets.only(bottom: 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            field["label"]!,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _controllers[index],
                        minLines: 1,
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        // ✅ Pass isRequired to validator
                        validator: (value) =>
                            _validateNote(value, isRequired: isRequired),
                        onChanged: (_) {
                          _saveFormData();
                          // ✅ Trigger rebuild to update button visibility
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: field["hint"],
                          hintStyle: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.grayColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.grayColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.grayColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.blackColor,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 14.h,
                          ),
                        ),
                        style: GoogleFonts.nunitoSans(fontSize: 16.sp),
                      ),
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: 50.h),

            // ✅ Only show buttons when required fields are filled
            if (_areRequiredFieldsFilled()) ...[
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
                      : () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _saveFormData();
                            formController.goToNextStep(context);
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
                    onPressed: state.isNavigating
                        ? null
                        : () {
                            // The notes are kept in local text controllers until
                            // this point. Sync them before opening the confirmation
                            // sheet so its Save for Later action enters case 1 in
                            // saveAndContinueLater with the complete Step 2 session.
                            if (!(_formKey.currentState?.validate() ?? false)) {
                              return;
                            }

                            _saveFormData();

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
                                  content: Text(
                                    "Please fill all required fields",
                                  ),
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
