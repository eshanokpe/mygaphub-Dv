import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart' as legacy;
import 'package:url_launcher/url_launcher.dart';
import '../../widget/formLabel.dart';
import '../../widget/textInput.dart';
import 'controller/protection_controller.dart';
import 'provider/protection_provider.dart';
import 'addProtection/widget/bottomSheetPickerField.dart';
import 'addProtection/widget/coverStartField.dart';
import 'addProtection/widget/currencyInput.dart';
import 'addProtection/widget/currencyPickerField.dart';
import 'addProtection/widget/documentUploadField.dart';
import 'protectionItem/protection_item_provider.dart';

class EditProtectionItem extends ConsumerStatefulWidget {
  const EditProtectionItem({super.key});

  @override
  ConsumerState<EditProtectionItem> createState() => _EditProtectionItemState();
}

class _EditProtectionItemState extends ConsumerState<EditProtectionItem> {
  bool _prefilled = false;
  bool _showExistingDocument = true;

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
    'Critical Illness Cover': [
      "Individual Critical Illness",
      "Joint Critical Illness",
      "Decreasing Critical Illness",
      "Others",
    ],
    'Income Protection': ['Long Term', 'Short Term', 'Others'],
    'Gadget/Device Protection': ["Gadget/Device Protection", "Others"],
    'Others': [
      "Comprehensive Health Insurance",
      "Temporary / Short-Term Health Insurance",
      "Health Savings & Protection Plans",
      "Long-Term Care / Critical Illness Cover",
      "Hospital Cash / Specialised Covers",
      "Medical Indemnity (for liability)",
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

  /// ✅ Helper: Extract only the symbol from full format like "$ USD", "₦ NGN"
  String _getCurrencySymbol(String fullCurrency) {
    final trimmed = fullCurrency.trim();
    final parts = trimmed.split(' ');
    return parts.isNotEmpty ? parts.first : '';
  }

  Future<void> _handleUpdate({
    required LifeInsuranceFormNotifier notifier,
    required String? title,
    required String protectionId,
  }) async {
    final result = await notifier.update(
      productTitle: title,
      protectionId: protectionId,
    );

    if (!mounted) return;

    if (result.success) {
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Protection updated successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      navigator.pop();
      navigator.pop();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorMessage ?? 'Failed to save. Please try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final providers = legacy.Provider.of<Providers>(context, listen: false);
    final asyncItem = ref.watch(protectionItemProvider);
    final formState = ref.watch(lifeInsuranceFormProviderFamily(providers));
    final notifier = ref.read(
      lifeInsuranceFormProviderFamily(providers).notifier,
    );

    final globalCurrency = providers.snapshotmodel.currency;

    asyncItem.whenData((item) {
      if (!_prefilled) {
        _prefilled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          notifier.loadForEdit(
            provider: item.providerPolicy ?? '',
            providerContact: item.providerContact ?? '',
            protectionType: item.protectionType ?? '',
            protectionDetails: item.details ?? '',
            bank: item.bank ?? '',
            currency: item.currency,
            sumAssured: item.sumAssured == item.sumAssured.toInt()
                ? item.sumAssured.toInt().toString()
                : item.rawSumAssured,
            premium: item.premiumPay == item.premiumPay.toInt()
                ? item.premiumPay.toInt().toString()
                : item.rawPremium,
            paymentFrequency: item.payFrequency ?? '',
            paymentType: item.paymentTypeLabel,
            coverStart: item.coverStart,
            coverEnd: item.coverEnd,
            existingDocumentUrl: item.documentUrl,
          );
        });
      }
    });

    return asyncItem.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (item) {
        final title = item.protectionCategory;
        final protectionTypes =
            _protectionTypesByProduct[title] ?? _defaultProtectionTypes;
        final hasProtectionTypes = protectionTypes.isNotEmpty;
        final showCoverEnd = _titlesWithCoverEnd.contains(title);

        final activeCurrencyFull =
            (formState.currency != null && formState.currency!.isNotEmpty)
            ? formState.currency!
            : globalCurrency;

        // ✅ Get only the symbol to display
        final activeCurrencySymbol = _getCurrencySymbol(activeCurrencyFull);

        final hasDocument =
            item.document != null &&
            item.document!.isNotEmpty &&
            _showExistingDocument;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: const Icon(
                            Icons.chevron_left,
                            size: 28,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),

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
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Edit your protection details',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 28),

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
                          onChanged: notifier.setCurrency,
                        ),
                        SizedBox(height: 20.h),

                        // const FormLabel('What is the sum assured?'),
                        // CurrencyInput(
                        //   currency: activeCurrencySymbol, // ✅ Pass only symbol
                        //   value: formState.sumAssured,
                        //   onChanged: notifier.setSumAssured,
                        // ),
                        // SizedBox(height: 20.h),
                        const FormLabel('What is the premium you pay?'),
                        CurrencyInput(
                          currency: activeCurrencySymbol, // ✅ Pass only symbol
                          value: formState.premium,
                          onChanged: notifier.setPremium,
                        ),
                        SizedBox(height: 20.h),

                        const FormLabel('What is your payment frequency?'),
                        BottomSheetPickerField(
                          value: _capitalizeFirstLetter(
                            formState.paymentFrequency ?? '',
                          ),
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

                        if (hasDocument) ...[
                          const _SectionLabel('Uploaded Document'),
                          _DocumentRow(
                            name: item.documentFileName ?? 'Document',
                            documentUrl: item.documentUrl,
                            onRemove: () {
                              setState(() {
                                _showExistingDocument = false;
                              });
                              notifier.setDocumentPath(null);
                            },
                          ),
                        ] else ...[
                          DocumentUploadField(
                            documentPath: formState.documentPath,
                            onFileSelected: (filePath) {
                              notifier.setDocumentPath(filePath);
                              debugPrint(
                                '>>> Document path set in state: $filePath',
                              );
                            },
                          ),
                        ],

                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: formState.isSubmitting
                                ? null
                                : () => _handleUpdate(
                                    notifier: notifier,
                                    title: title,
                                    protectionId: item.id?.toString() ?? '',
                                  ),
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
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 6.h),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: const Color(0xff888888),
        ),
      ),
    );
  }
}

class _DocumentRow extends ConsumerWidget {
  final String name;
  final String? documentUrl;
  final VoidCallback onRemove;

  const _DocumentRow({
    required this.name,
    this.documentUrl,
    required this.onRemove,
  });

  Future<void> _openDocument(BuildContext context) async {
    final url = documentUrl;
    if (url == null) return;

    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open document')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening document: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizeAsync = documentUrl != null
        ? ref.watch(documentSizeProvider(documentUrl!))
        : const AsyncValue.data('PDF Document');

    return InkWell(
      onTap: () => _openDocument(context),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xffF7F7F7),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xffEEEEEE)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 30.w,
              height: 30.w,
              child: Image.asset(
                'assets/images/pdf1.png',
                width: 30.w,
                height: 30.w,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  sizeAsync.when(
                    loading: () => Text(
                      'Calculating...',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12.sp,
                        color: const Color(0xff888888),
                      ),
                    ),
                    error: (_, __) => Text(
                      'PDF Document',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12.sp,
                        color: const Color(0xff888888),
                      ),
                    ),
                    data: (size) => Text(
                      size,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12.sp,
                        color: const Color(0xff888888),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
              icon: Icon(
                Icons.close,
                color: AppColors.primaryColor,
                size: 20.sp,
              ),
              onPressed: onRemove,
              tooltip: 'Remove document',
            ),
          ],
        ),
      ),
    );
  }
}
