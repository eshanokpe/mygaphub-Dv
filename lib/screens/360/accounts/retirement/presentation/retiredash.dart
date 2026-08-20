import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:GapHub/widgets/piechart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../protection/widget/retirement_dob_bottomsheet.dart';
import '../provider/pension_provider.dart';
import 'financialIndependence/financial_independence_tab.dart';
import 'financialIndependence/widget/EditPortfolioIncome.dart';
import 'retirementDetails.dart';
import 'widget/add_pension_popup.dart';
import 'widget/banner_retirement.dart';
import 'widget/build_pensionItem.dart';
import 'widget/noPension.dart';
import 'widget/slidingIconSwitcher.dart';

class Retiredash extends ConsumerStatefulWidget {
  const Retiredash({super.key});

  @override
  ConsumerState<Retiredash> createState() => _RetiredashState();
}

class _RetiredashState extends ConsumerState<Retiredash> {
  bool _showAllProtection = false;
  bool _isLoading = true;
  bool _apiSuccess = false;

  static const Map<String, String> _imagePathByType = {
    'Private Pension': 'assets/wheel_segments/private_pension.png',
    'State Pension': 'assets/wheel_segments/state_pension.png',
    'Employer Pension': 'assets/wheel_segments/employer_pension.png',
    'Others': 'assets/wheel_segments/others_pension.png',
  };

  static const Map<String, List<Color>> _gradientByCategory = {
    'State Pension': [Color(0XFFFB6E6E), Color(0XFFD84343)],
    'Employer Pension': [Color(0XFF34A853), Color(0XFF1E7D32)],
    'Others': [Color(0XFF4285F4), Color(0XFF2A56C6)],
    'Private Pension': [Color(0XFFF9B423), Color(0XFFF7A800)],
  };

  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRetirementData());
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tokenDB');
  }

  Future<void> _loadRetirementData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _apiSuccess = false;
    });

    try {
      final token = await _getToken();
      if (token == null) throw Exception('Authentication token not found');

      final headers = {'Authorization': 'Bearer $token'};

      final results = await Future.wait([
        _dio
            .get(
              '$baseUrl/app/360/retirement/roi',
              options: Options(headers: headers),
            )
            .catchError((e) {
              debugPrint(
                'ROI call failed: ${e is DioException ? e.response?.data : e}',
              );
              throw e;
            }),
        _dio
            .get(
              '$baseUrl/app/360/retirement?archive=0&header=&access=&account=',
              options: Options(headers: headers),
            )
            .catchError((e) {
              debugPrint(
                'Retirement call failed: ${e is DioException ? e.response?.data : e}',
              );
              throw e;
            }),
      ]);

      final roiResponse = results[0];
      final retirementResponse = results[1];

      if (!mounted) return;

      if (roiResponse.statusCode == 200 &&
          retirementResponse.statusCode == 200) {
        _apiSuccess = true;
        final roiData = roiResponse.data['data'] as Map? ?? {};
        final retirementData = retirementResponse.data['data'] as Map? ?? {};

        if (mounted) {
          context.read<Providers>()
            ..setretiredata(roiData)
            ..setpensions(retirementData);
        }
      } else {
        _apiSuccess = false;
      }
    } catch (e) {
      _apiSuccess = false;
      if (e is DioException) {
        debugPrint(
          'Retirement load error [${e.requestOptions.path}]: '
          'status=${e.response?.statusCode} body=${e.response?.data}',
        );
      } else {
        debugPrint('Retirement load error: $e');
      }
      if (!mounted) return;
      // Fluttertoast.showToast(
      //   msg: 'Failed to load data. Pull down to refresh.',
      //   backgroundColor: Colors.red,
      // );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  num _parseNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }

  bool _hasValidDOB(dynamic dobRaw) {
    return dobRaw != null && dobRaw.toString().trim().isNotEmpty;
  }

  void _openDOBSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(56.0),
          topRight: Radius.circular(56.0),
        ),
      ),
      builder: (_) => RetirementDOBBottomSheet(
        title: "Date of Birth",
        onDobUpdated: _loadRetirementData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ This watch ensures the widget rebuilds whenever providers.notifyListeners() is called
    final providers = context.watch<Providers>();
    final pensionsdata = providers.pensionsdata;
    final currency = providers.snapshotmodel.currency.toString();
    final pensionList = pensionsdata['retirement'] ?? [];
    final state = ref.watch(pensionControllerProvider);

    // ✅ This value will update instantly when provider.details[4] changes
    final dobRaw = providers.details[4];
    print("dobRaw:$dobRaw");
    final bool showDOBFlow = !_apiSuccess || !_hasValidDOB(dobRaw);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: const Icon(Icons.chevron_left, size: 28, color: Colors.black),
        ),
        actions: [
          SlidingActionIcon(
            selectedIndex: state.selectedTabIndex,
            onTapTab0: () {
              if (showDOBFlow) {
                _openDOBSheet();
              } else {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(56.0),
                      topRight: Radius.circular(56.0),
                    ),
                  ),
                  builder: (_) => AddPensionPopup(
                    title: "Pick your option",
                    onRefresh: _loadRetirementData,
                  ),
                );
              }
            },
            onTapTab1: () {
              if (showDOBFlow) {
                _openDOBSheet();
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditPortfolioIncome(),
                  ),
                );
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(4),
      body: RefreshIndicator(
        onRefresh: _loadRetirementData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Retirement',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Have a Complete View of your numbers',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: const Color(0xff393737),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildToggleButton(
                            text: 'Pension',
                            imagePath: 'assets/wheel_segments/pension.png',
                            isSelected: state.selectedTabIndex == 0,
                            onTap: () => ref
                                .read(pensionControllerProvider.notifier)
                                .selectTab(0),
                          ),
                          const SizedBox(width: 12),
                          _buildToggleButton(
                            text: 'Financial Independence',
                            imagePath: 'assets/wheel_segments/independent.png',
                            isSelected: state.selectedTabIndex == 1,
                            onTap: () => ref
                                .read(pensionControllerProvider.notifier)
                                .selectTab(1),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (state.selectedTabIndex == 0) ...[
                      RetirementBanner(
                        currency: currency,
                        pensionList: pensionList,
                        pensionAmount:
                            pensionsdata["retirement_detail"]?["sum"] ?? 0,
                      ),
                      SizedBox(height: 20.h),
                      if (pensionList.isNotEmpty)
                        Text(
                          'PENSION POT',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff808080),
                            letterSpacing: 0.5,
                          ),
                        ),
                      if (pensionList.isNotEmpty) SizedBox(height: 10.h),
                      if (pensionList.isEmpty)
                        NoPension(
                          showDOBFlow: showDOBFlow,
                          onOpenDOBSheet: _openDOBSheet,
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _showAllProtection
                                  ? pensionList.length
                                  : pensionList.length.clamp(0, 3),
                              itemBuilder: (context, index) {
                                final pension = pensionList[index] ?? {};
                                final type =
                                    pension['pension_type'] ?? 'Others';
                                final imagePath =
                                    _imagePathByType[type] ??
                                    _imagePathByType['Others']!;

                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 0.h,
                                    vertical: 8.h,
                                  ),
                                  child: BuildPensionItem(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => Retirementdetails(
                                            data: pension,
                                            imagePath: imagePath,
                                          ),
                                        ),
                                      );
                                    },
                                    imagePath: imagePath,
                                    title: pension['name'] ?? '',
                                    subtitle: type,
                                    amount: _parseNum(pension['current']),
                                    currency: currency,
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: 6.h),
                            if (pensionList.length > 3)
                              InkWell(
                                onTap: () => setState(
                                  () =>
                                      _showAllProtection = !_showAllProtection,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _showAllProtection
                                          ? ''
                                          : '+${pensionList.length - 3}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.counterColor,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          _showAllProtection
                                              ? 'Show less'
                                              : 'Show more',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        AnimatedRotation(
                                          turns: _showAllProtection ? 0.5 : 0,
                                          duration: const Duration(
                                            milliseconds: 250,
                                          ),
                                          child: Icon(
                                            Icons.keyboard_arrow_down,
                                            color: const Color(0xffB20049),
                                            size: 16.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                            SizedBox(height: 20.h),

                            Text(
                              'Pension Distribution'.toUpperCase(),
                              style: GoogleFonts.nunitoSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff808080),
                                letterSpacing: 0.5,
                              ),
                            ),

                            SizedBox(height: 12.h),

                            Builder(
                              builder: (context) {
                                final labels =
                                    pensionsdata["retirement_detail"]?["labels"]
                                        as List? ??
                                    [];
                                final values =
                                    (pensionsdata["retirement_detail"]?["values"]
                                                as List? ??
                                            [])
                                        .map(
                                          (v) =>
                                              double.tryParse(v.toString()) ??
                                              0.0,
                                        )
                                        .toList();
                                final percentages =
                                    (pensionsdata["retirement_detail"]?["percentages"]
                                                as List? ??
                                            [])
                                        .map(
                                          (p) =>
                                              double.tryParse(p.toString()) ??
                                              0.0,
                                        )
                                        .toList();

                                final pieGradients = labels.map((label) {
                                  return _gradientByCategory[label] ??
                                      _gradientByCategory['Others']!;
                                }).toList();

                                return Piechart(
                                  labels: labels.cast<String>(),
                                  values: values,
                                  percent: percentages,
                                  gradients: pieGradients,
                                );
                              },
                            ),
                            SizedBox(height: 40.h),

                            Center(
                              child: InkWell(
                                onTap: () {
                                  if (showDOBFlow) {
                                    _openDOBSheet();
                                  } else {
                                    showModalBottomSheet(
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(56.0),
                                          topRight: Radius.circular(56.0),
                                        ),
                                      ),
                                      builder: (_) => const AddPensionPopup(
                                        title: "Pick your option",
                                      ),
                                    );
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: AppColors.primaryColor,
                                      size: 22.sp,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      "Add Pension Account",
                                      style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 40.h),
                          ],
                        ),
                    ],
                    if (state.selectedTabIndex == 1)
                      const FinancialIndependenceTab(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildToggleButton({
    required String text,
    required String imagePath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: 1,
          ),
          image: isSelected
              ? const DecorationImage(
                  image: AssetImage('assets/wheel_segments/fi_toggle.png'),
                  fit: BoxFit.cover,
                )
              : null,
          color: isSelected ? null : Colors.white,
        ),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              color: isSelected ? Colors.white : Colors.black,
              width: 20.w,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
