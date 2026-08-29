import 'dart:io';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart' as legacy;
import '../../../widget/formLabel.dart';
import '../../../widget/textInput.dart';
import '../../SuccessModal.dart';
import '../provider/protection_provider.dart';
import 'widget/bottomSheetPickerField.dart';
import 'widget/coverStartField.dart';
import 'widget/currencyInput.dart';
import 'widget/currencyPickerField.dart';
import 'widget/documentUploadField.dart';

class AddProtectionScreen extends ConsumerWidget {
  final String? title;
  final String? imagePath;

  const AddProtectionScreen({super.key, this.title, this.imagePath});

  static const Map<String, List<String>> _protectionTypesByProduct = {
    'Life Insurance': [
      'Whole of Life',
      'Term Assurance',
      'Endowment Policy',
      'Annuity Plan',
      'Others',
    ],
    'Home Insurance': [
      "Building and Content",
      "Building Only",
      "Content Only",
      "Emergency Cover",
      "Others",
    ],
    'Health Insurance': [
      'Comprehensive Health Insurance',
      'Temporary / Short-Term Health Insurance',
      'Health Savings & Protection Plans',
      'Long-Term Care / Critical Illness Cover',
      'Hospital Cash / Specialised Covers',
      'Medical Indemnity (for liability)',
      'Others',
    ],
    'Car Insurance': ['Comprehensive Cover', 'Third Party Cover', 'Others'],
    // 'Critical Illness Cover': [
    //   "Individual Critical Illness",
    //   "Joint Critical Illness",
    //   "Decreasing Critical Illness",
    //   "Others",
    // ],
    'Income Protection': ['Long Term', 'Short Term', 'Others'],
    // 'Gadget/Device Protection': ["Gadget/Device Protection", "Others"],
    'Others': [
      "Whole of Life",
      "Term Assurance",
      "Endowment Policy",
      "Annuity Plan",
      "Comprehensive Cover",
      "Third Party Cover",
      "Others",
    ],
  };

  static const List<String> _defaultProtectionTypes = [];
  static const _paymentFrequencies = ['Monthly', 'Annually'];
  static const _paymentTypes = [
    'Direct Debit',
    'Debit/Credit Card',
    'Standing Order',
  ];

  static const _titlesWithCoverEnd = [
    'Home Insurance',
    'Car Insurance',
    'Critical Illness',
    'Income Protection',
    'Gadget/Device Protection',
    'Health Insurance',
    'Others',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String currency = context.watch<Providers>().snapshotmodel.currency;
    final providers = legacy.Provider.of<Providers>(context, listen: false);

    final formState = ref.watch(lifeInsuranceFormProviderFamily(providers));
    final notifier = ref.read(
      lifeInsuranceFormProviderFamily(providers).notifier,
    );

    final activeCurrency =
        (formState.currency != null && formState.currency!.isNotEmpty)
        ? formState.currency!
        : currency;

    final protectionTypes =
        _protectionTypesByProduct[title] ?? _defaultProtectionTypes;
    final hasProtectionTypes = protectionTypes.isNotEmpty;
    final showCoverEnd = _titlesWithCoverEnd.contains(title);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: const Icon(Icons.chevron_left, size: 28, color: Colors.black),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title != null && title != 'Others'
                                ? title!
                                : 'Other Insurance Types',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Image.asset(
                            imagePath ?? 'assets/wheel_segments/default.png',
                            width: 24,
                            height: 24,
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Complete the form and attach your documents',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 28.h),

                      const FormLabel('Who is the provider of this policy'),
                      TextInput(
                        hint: 'E.g. Old Mutual, Aviva, etc.',
                        value: formState.provider,
                        onChanged: notifier.setProvider,
                      ),
                      SizedBox(height: 20.h),

                      const FormLabel("What is the provider's contact?"),
                      TextInput(
                        hint: 'Type their email, phone, or website',
                        value: formState.providerContact,
                        onChanged: notifier.setProviderContact,
                      ),
                      SizedBox(height: 20.h),

                      if (hasProtectionTypes) ...[
                        const FormLabel('What type of protection is this?'),
                        BottomSheetPickerField(
                          value: formState.protectionType,
                          hint: '-Select',
                          items: protectionTypes,
                          onChanged: notifier.setProtectionType,
                          title: 'What type of protection is this?',
                        ),
                        SizedBox(height: 20.h),
                      ],

                      const FormLabel('Details of the protection'),
                      TextInput(
                        hint: 'E.g. Life Cover for myself',
                        value: formState.protectionDetails,
                        onChanged: notifier.setProtectionDetails,
                        expandable: true,
                      ),
                      SizedBox(height: 20.h),

                      const FormLabel(
                        'Which bank are you using to make this payment?',
                      ),
                      TextInput(
                        hint: 'E.g. Natwest, Monzo, etc.',
                        value: formState.bank,
                        onChanged: notifier.setBank,
                      ),
                      SizedBox(height: 20.h),

                      const FormLabel(
                        'What is the currency this protection is held in?',
                      ),

                      CurrencyPickerField(
                        value: formState.currency,
                        displayValue: formState.currencyDisplay, // ← add this
                        onChanged: notifier.setCurrency,
                      ),
                      SizedBox(height: 20.h),

                      const FormLabel('What is the sum assured?'),
                      CurrencyInput(
                        currency: activeCurrency,
                        value: formState.sumAssured,
                        onChanged: notifier.setSumAssured,
                      ),
                      SizedBox(height: 20.h),
                      const FormLabel('What is the premium you pay?'),
                      CurrencyInput(
                        currency: activeCurrency,
                        value: formState.premium,
                        onChanged: notifier.setPremium,
                      ),
                      SizedBox(height: 20.h),

                      const FormLabel('What is your payment frequency?'),
                      BottomSheetPickerField(
                        value: formState.paymentFrequency,
                        hint: '-Select',
                        items: _paymentFrequencies,
                        onChanged: notifier.setPaymentFrequency,
                        title: 'What is your payment frequency?',
                      ),
                      SizedBox(height: 20.h),

                      const FormLabel('Payment Type'),
                      BottomSheetPickerField(
                        value: formState.paymentType,
                        hint: '-Select',
                        items: _paymentTypes,
                        onChanged: notifier.setPaymentType,
                        title: 'Payment Type',
                      ),
                      SizedBox(height: 20.h),

                      if (showCoverEnd) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const FormLabel('Cover Start'),
                                  CoverStartField(
                                    selectedDate: formState.coverStart,
                                    isExpanded: formState.isDateExpanded,
                                    onToggle: notifier.toggleDateExpanded,
                                    onDateSelected: notifier.setCoverStart,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const FormLabel('Cover End'),
                                  CoverStartField(
                                    selectedDate: formState.coverEnd,
                                    isExpanded: formState.isEndDateExpanded,
                                    onToggle: notifier.toggleEndDateExpanded,
                                    onDateSelected: notifier.setCoverEnd,
                                    allowFuture: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        const FormLabel('Cover Start'),
                        CoverStartField(
                          selectedDate: formState.coverStart,
                          isExpanded: formState.isDateExpanded,
                          onToggle: notifier.toggleDateExpanded,
                          onDateSelected: notifier.setCoverStart,
                        ),
                      ],
                      SizedBox(height: 20.h),

                      const FormLabel('Documents'),
                      DocumentUploadField(
                        documentPath: formState.documentPath,
                        onFileSelected: (filePath) {
                          notifier.setDocumentPath(filePath);
                          debugPrint(
                            '>>> Document path set in state: $filePath',
                          );
                        },
                      ),
                      SizedBox(height: 32.h),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: formState.isSubmitting
                              ? null
                              : () async {
                                  // ✅ FIX: Explicitly dismiss keyboard before any navigation/modal
                                  FocusScope.of(context).unfocus();

                                  final result = await notifier.submit(title);

                                  if (!context.mounted) return;

                                  if (result.success) {
                                    SuccessModal.show(
                                      context: context,
                                      message: 'Protection added successfully!',
                                      onClose: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          result.errorMessage ??
                                              'Failed to save. Please try again.',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
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
                                  'Add Insurance Account',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
