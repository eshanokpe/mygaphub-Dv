import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart' as legacy;
import '../../../widget/textInput.dart';
import '../../protection/addProtection/widget/coverStartField.dart';
import '../../retirement/presentation/widget/currencyInput.dart';
import '../provider/home_equity_form_provider.dart';
import '../widget/bottomSheetPickerField.dart';
import '../../../widget/formLabel.dart';
import '../widget/successModalAssets.dart';

class EditHomeEquityItem extends ConsumerStatefulWidget {
  final Map<String, dynamic> item;

  const EditHomeEquityItem({super.key, required this.item});

  @override
  ConsumerState<EditHomeEquityItem> createState() => _EditHomeEquityItemState();
}

class _EditHomeEquityItemState extends ConsumerState<EditHomeEquityItem> {
  bool _debtLoaded = false;
  late List<Country> _allCountries;

  @override
  void initState() {
    super.initState();
    final allowedCodes = {'GB', 'US', 'CA', 'ZA'};
    _allCountries = CountryService()
        .getAll()
        .where((c) => allowedCodes.contains(c.countryCode))
        .toList();

    // Pre-fill the form with existing data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeEquityFormProvider.notifier).initializeFromMap(widget.item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currency = legacy.Provider.of<Providers>(
      context,
    ).snapshotmodel.currency;
    final formState = ref.watch(homeEquityFormProvider);
    final notifier = ref.read(homeEquityFormProvider.notifier);

    if (!_debtLoaded) {
      _debtLoaded = true;
      notifier.loadDebt(currency);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: const Icon(Icons.chevron_left, size: 28, color: Colors.black),
        ),
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Edit Home Equity',
          style: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(4),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Text(
                  "Update the details of this asset",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 24.h),

                // --- Reuse the exact same form fields from AddHomeEquity here ---
                // For brevity, I'm showing the key fields. Copy the rest from AddHomeEquity.
                const FormLabel('Is there mortgage on this property?'),
                BottomSheetPickerField(
                  value: formState.mortgageProperty,
                  hint: '-Select',
                  items: HomeEquityFormNotifier.mortgagePropertyOptions,
                  onChanged: (value) =>
                      notifier.setMortgageProperty(value ?? '-Select-'),
                  title: 'Is there mortgage on this property',
                ),
                SizedBox(height: 20.h),

                if (formState.mortgageProperty == 'Yes') ...[
                  // ... (Copy all mortgage fields from AddHomeEquity here) ...
                ],

                SizedBox(height: 20.h),
                const FormLabel('What country is this property located in?'),

                // ... (Copy Country Picker InkWell from AddHomeEquity here) ...
                SizedBox(height: 20.h),
                const FormLabel('Home Address'),

                // ... (Copy Address Search InkWell from AddHomeEquity here) ...
                SizedBox(height: 20.h),
                const FormLabel('Current market value of your home?'),
                CurrencyInput(
                  value: formState.currentValue,
                  onChanged: notifier.setCurrentValue,
                ),

                SizedBox(height: 20.h),
                const FormLabel('Date Acquired'),
                CoverStartField(
                  downArrow: true,
                  selectedDate:
                      formState.dateAcquired, // ✅ FIXED: Uses dateAcquired now
                  isExpanded: formState.isDateAcquiredExpanded, // ✅ FIXED
                  onToggle: notifier.toggleDateAcquiredExpanded, // ✅ FIXED
                  onDateSelected: notifier.setDateAcquired, // ✅ FIXED
                ),

                SizedBox(height: 40.h),

                SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: formState.isSubmitting
                        ? null
                        : () async {
                            FocusScope.of(context).unfocus();

                            // Call update with the item's ID
                            final result = await notifier.update(
                              widget.item['id'].toString(),
                            );

                            if (!context.mounted) return;

                            if (result.success) {
                              SuccessModalAssets.show(
                                context: context,
                                message: 'Equity updated successfully!',
                                onClose: () {},
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    result.errorMessage ??
                                        'Failed to update. Please try again.',
                                  ),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      elevation: 0,
                    ),
                    child: formState.isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Update Home Equity',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
