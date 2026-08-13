import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../provider/investment_form_state.dart';

class InvestmentFormController extends Notifier<InvestmentFormState> {
  final int totalSteps = 5;
  final int minReasonLength = 10;
  final int minNameLength = 3;
  final int step4TotalQuestions = 5;

  @override
  InvestmentFormState build() => const InvestmentFormState();

  void clearMessages() {
    state = state.copyWith(successMessage: null, errorMessage: null);
  }

  // ============ STEP 1 UPDATES & VALIDATION ============
  void updateInvestmentName(String value) {
    state = state.copyWith(
      investmentName: value,
      nameError: _validateName(value),
    );
    _updateStep1Progress();
  }

  void updateInvestmentReason(String value) {
    state = state.copyWith(
      investmentReason: value,
      reasonError: _validateReason(value),
    );
    _updateStep1Progress();
  }

  void updateSelectedCategory(String categoryId, {required int totalItems}) {
    state = state.copyWith(
      selectedCategory: categoryId,
      step2TotalItems: totalItems,
      step2CategoryJustSelected: true,
    );
    _updateStep2Progress();
  }

  String? _validateName(String value) {
    if (value.trim().isEmpty) return "Investment name is required";
    if (value.trim().length < minNameLength) {
      return "Name must be at least $minNameLength characters";
    }
    return null;
  }

  void resetForm() {
    state = const InvestmentFormState();
  }

  String? _validateReason(String value) {
    if (value.trim().isEmpty) return "Reason is required";
    if (value.trim().length < minReasonLength) {
      return "Reason must be at least $minReasonLength characters";
    }
    return null;
  }

  void _updateStep1Progress() {
    int filled = 0;
    if (state.investmentName.trim().isNotEmpty) filled++;
    if (state.investmentReason.trim().isNotEmpty) filled++;
    final progress = 0.1 + (filled * 0.45);
    state = state.copyWith(step1Progress: progress.clamp(0.1, 1.0));
  }

  // ============ STEP 2 UPDATES & PROGRESS ============
  void updateStep2Item(int index, String subCat, String note) {
    final items = List<Map<String, String>>.from(state.step2Items);
    if (index >= items.length) {
      items.add({"sub_category": subCat, "note": note});
    } else {
      items[index] = {"sub_category": subCat, "note": note};
    }
    state = state.copyWith(step2Items: items, step2CategoryJustSelected: false);
    _updateStep2Progress();
  }

  void _updateStep2Progress() {
    final hasCategory =
        state.selectedCategory != null && state.selectedCategory!.isNotEmpty;

    if (!hasCategory || state.step2TotalItems == 0) {
      state = state.copyWith(step2Progress: 0.1);
      return;
    }

    int filled = 0;
    final items = state.step2Items;

    if (state.selectedCategory == "retirement") {
      for (int i = 0; i < items.length && i < 3; i++) {
        if (items[i]["note"]!.trim().isNotEmpty) filled++;
      }
    } else {
      filled = items.where((i) => i["note"]!.trim().isNotEmpty).length;
    }

    final fieldProgress = (filled / state.step2TotalItems) * 0.8;
    final progress = 0.2 + fieldProgress;
    state = state.copyWith(step2Progress: progress.clamp(0.1, 1.0));
  }

  // ============ STEP 3 UPDATES & PROGRESS ============
  void updateSavingsFunds({
    required String assetGrowthFunds,
    required String personalFund,
    required String emergencyFund,
  }) {
    state = state.copyWith(
      assetGrowthFunds: assetGrowthFunds,
      personalFund: personalFund,
      emergencyFund: emergencyFund,
    );
  }

  void updateSavingsGoal({
    required String savingsChoice,
    String newMonthlySavings = '',
    String obtainPlan = '',
  }) {
    state = state.copyWith(
      savingsChoice: savingsChoice,
      newMonthlySavings: newMonthlySavings,
      obtainPlan: obtainPlan,
    );
  }

  void updateStep3Item(int index, String subCat, String note) {
    final items = List<Map<String, String>>.from(state.step3Items);
    if (index >= items.length) {
      items.add({"sub_category": subCat, "note": note});
    } else {
      items[index] = {"sub_category": subCat, "note": note};
    }
    state = state.copyWith(step3Items: items);
    _updateStep3Progress();
  }

  void _updateStep3Progress() {
    int filled = state.step3Items
        .where((i) => i["note"]!.trim().isNotEmpty)
        .length;
    final progress = 0.1 + (filled * 0.3);
    state = state.copyWith(step3Progress: progress.clamp(0.1, 1.0));
  }

  // ============ STEP 4 UPDATES & PROGRESS ============
  void updateStep4Item(int index, String subCat, String note) {
    final items = List<Map<String, String>>.from(state.step4Items);

    // Pad the list up to the required length before writing to `index`
    while (items.length < step4TotalQuestions) {
      items.add({"sub_category": "", "note": ""});
    }

    items[index] = {"sub_category": subCat, "note": note};

    state = state.copyWith(step4Items: items);
    _updateStep4Progress();
  }

  void _updateStep4Progress() {
    int filled = state.step4Items
        .where((i) => i["note"]!.trim().isNotEmpty)
        .length;

    final base = state.step4Progress >= 0.2 ? 0.2 : 0.1;
    final fieldProgress = (filled / step4TotalQuestions) * 0.8;
    final progress = base + fieldProgress;

    state = state.copyWith(step4Progress: progress.clamp(0.1, 1.0));
  }

  void setStep4InvestigateForm(bool value) {
    state = state.copyWith(
      step4ShowInvestigateForm: value,
      step4Progress: (value && state.step4Progress < 0.2)
          ? 0.2
          : state.step4Progress,
    );
  }

  // ============ STEP 5 UPDATES & PROGRESS ============
  void updateStep5Item(int index, String subCat, String note) {
    final items = List<Map<String, String>>.from(state.step5Items);
    if (index >= items.length) {
      items.add({"sub_category": subCat, "note": note});
    } else {
      items[index] = {"sub_category": subCat, "note": note};
    }
    state = state.copyWith(step5Items: items);
    _updateStep5Progress();
  }

  void updateAllocationPercentage(String value) {
    state = state.copyWith(allocationPercentage: value);
    _updateStep5Progress();
  }

  void _updateStep5Progress() {
    final percentageFilled = state.allocationPercentage.trim().isNotEmpty;
    final bothAllocationsPicked =
        state.monthlyAllocationPercent != null &&
        state.lumpsumAllocationPercent != null;

    double progress;
    if (bothAllocationsPicked) {
      progress = 1.0;
    } else if (percentageFilled) {
      progress = 0.5;
    } else {
      progress = 0.1;
    }

    state = state.copyWith(step5Progress: progress);
  }

  void setStep5ShowSecondScreen(bool value) {
    state = state.copyWith(step5ShowSecondScreen: value);
    if (!value) {
      state = state.copyWith(step5ShowSummaryScreen: false);
    }
  }

  void setStep5ShowSummaryScreen(bool value) {
    state = state.copyWith(step5ShowSummaryScreen: value);
  }

  void goToStep(int step) {
    state = state.copyWith(
      currentStep: step,
      step5ShowSecondScreen: false,
      step5ShowSummaryScreen: false,
    );
  }

  void updateMonthlyAllocationPercent(int percent) {
    if (state.monthlyAllocationPercent == percent) {
      state = state.copyWith(clearMonthlyAllocationPercent: true);
    } else {
      state = state.copyWith(monthlyAllocationPercent: percent);
    }
    _updateStep5Progress();
  }

  void updateLumpsumAllocationPercent(int percent) {
    if (state.lumpsumAllocationPercent == percent) {
      state = state.copyWith(clearLumpsumAllocationPercent: true);
    } else {
      state = state.copyWith(lumpsumAllocationPercent: percent);
    }
    _updateStep5Progress();
  }

  // ============ VALIDATION CHECK ============
  bool canProceed(BuildContext context) {
    switch (state.currentStep) {
      case 0:
        return state.investmentName.trim().isNotEmpty &&
            state.investmentReason.trim().isNotEmpty &&
            state.nameError == null &&
            state.reasonError == null;

      case 1:
        if (state.selectedCategory == null || state.selectedCategory!.isEmpty) {
          return false;
        }
        if (state.step2Items.isEmpty) return false;

        if (state.selectedCategory == "retirement") {
          if (state.step2Items.length < 3) return false;
          return state.step2Items[0]["note"]!.trim().isNotEmpty &&
              state.step2Items[1]["note"]!.trim().isNotEmpty &&
              state.step2Items[2]["note"]!.trim().isNotEmpty;
        } else {
          return state.step2Items.every((i) => i["note"]!.trim().isNotEmpty);
        }

      case 2:
        if (state.savingsChoice == 'keep_amount') return true;

        if (state.savingsChoice == 'increase_amount') {
          return num.tryParse(state.newMonthlySavings.replaceAll(',', '')) !=
                  null &&
              state.obtainPlan.trim().isNotEmpty;
        }

        return false;

      case 3:
        if (state.step4Items.length < 4) return false;
        for (int i = 0; i < 4; i++) {
          if (state.step4Items[i]["note"]!.trim().isEmpty) return false;
        }
        return true;

      case 4:
        return state.allocationPercentage.trim().isNotEmpty;

      default:
        return false;
    }
  }

  // ============ NAVIGATION ============
  void moveToNextStepOnly() {
    if (state.currentStep < totalSteps - 1) {
      final nextStep = state.currentStep + 1;
      state = state.copyWith(
        currentStep: nextStep,
        isNavigating: false,
        step4ShowInvestigateForm: nextStep == 3
            ? state.step4ShowInvestigateForm
            : false,
        step5ShowSecondScreen: nextStep == 4
            ? state.step5ShowSecondScreen
            : false,
        step5ShowSummaryScreen: false,
      );
    }
  }

  Future<void> goToNextStep(BuildContext context) async {
    if (!canProceed(context)) return;

    state = state.copyWith(isNavigating: true);
    await Future.delayed(const Duration(milliseconds: 200));

    if (state.currentStep < totalSteps - 1) {
      final nextStep = state.currentStep + 1;
      state = state.copyWith(
        currentStep: nextStep,
        isNavigating: false,
        strategyId: state.strategyId,
        step1Progress: nextStep == 0 && state.step1Progress == 0
            ? 0.1
            : state.step1Progress,
        step2Progress: nextStep == 1 && state.step2Progress == 0
            ? 0.1
            : state.step2Progress,
        step3Progress: nextStep == 2 && state.step3Progress == 0
            ? 0.1
            : state.step3Progress,
        step4Progress: nextStep == 3 && state.step4Progress == 0
            ? 0.1
            : state.step4Progress,
        step5Progress: nextStep == 4 && state.step5Progress == 0
            ? 0.1
            : state.step5Progress,
      );
    } else {
      state = state.copyWith(isNavigating: false);
    }
  }

  // ============ HELPERS FOR API PAYLOADS ============
  List<Map<String, String>> _getValidStep2Items() {
    final category = state.selectedCategory;
    if (category == null) return [];

    final Map<String, List<String>> validSubCats = {
      'retirement': [
        'private_pension',
        'company_pension',
        'state_pension',
        'other_pensions',
      ],
      'cash': ['isa', 'fixed_income', 'easy_asset'],
      'investment': ['business_asset', 'appreciating_asset', 'risk_asset'],
      'equity': ['wholly_owned_home', 'jointly_owned_home'],
    };

    final allowed = validSubCats[category] ?? [];

    return state.step2Items.where((item) {
      return allowed.contains(item['sub_category']);
    }).toList();
  }

  String _getStep4NoteBySubCat(String subCat) {
    final item = state.step4Items.firstWhere(
      (item) => item['sub_category'] == subCat,
      orElse: () => {'note': ''},
    );
    return item['note'] ?? '';
  }

  // ============ SAVE & CONTINUE ============
  Future<bool> saveAndContinueLater(BuildContext context) async {
    clearMessages();
    if (!canProceed(context)) {
      state = state.copyWith(errorMessage: "Please fill all required fields");
      return false;
    }
    if (state.isNavigating) return false;

    state = state.copyWith(isNavigating: true, isLoading: true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenDB');

    try {
      switch (state.currentStep) {
        case 0:
          print("🔵 STEP 0: Name/Reason captured locally, no API call yet");
          state = state.copyWith(successMessage: "Progress saved!");
          return true;

        case 1:
          print("🟡 STEP 1: Creating Strategy + Saving Step 2 Items");
          String? strategyId = state.strategyId;

          if (strategyId == null || strategyId.isEmpty) {
            final createPayload = jsonEncode({
              "name": state.investmentName,
              "reason": state.investmentReason,
              "category": state.selectedCategory,
            });

            final createRes = await http.post(
              Uri.parse('$baseUrl/app/action-strategies'),
              headers: {
                'Content-Type': 'application/json',
                "Authorization": 'Bearer $token',
              },
              body: createPayload,
            );

            if (createRes.statusCode == 200 || createRes.statusCode == 201) {
              final data = jsonDecode(createRes.body);
              if (data['data'] != null && data['data']['strategy'] != null) {
                strategyId = data['data']['strategy']['id'].toString();
              } else if (data['id'] != null) {
                strategyId = data['id'].toString();
              }

              if (strategyId != null) {
                state = state.copyWith(strategyId: strategyId);
              } else {
                _handleError(createRes);
                return false;
              }
            } else {
              _handleError(createRes);
              return false;
            }
          }

          final validItems = _getValidStep2Items();
          final itemsPayload = jsonEncode({"items": validItems});

          final res = await http.post(
            Uri.parse('$baseUrl/app/action-strategies/$strategyId/items'),
            headers: {
              'Content-Type': 'application/json',
              "Authorization": 'Bearer $token',
            },
            body: itemsPayload,
          );

          if (res.statusCode == 200 || res.statusCode == 201) {
            state = state.copyWith(
              successMessage: "Strategy and items saved successfully!",
            );
            return true;
          } else {
            _handleError(res);
            return false;
          }

        case 2:
          print("🟡 STEP 2: Saving Step 3 Savings Goal");
          if (state.strategyId == null || state.strategyId!.isEmpty) {
            state = state.copyWith(errorMessage: "Strategy ID missing");
            return false;
          }

          if (state.savingsChoice.isEmpty) {
            state = state.copyWith(errorMessage: "Savings choice is required");
            return false;
          }

          final savingsGoalPayload = <String, dynamic>{
            "savings_choice": state.savingsChoice,
          };
          if (state.savingsChoice == 'increase_amount') {
            final newMonthlySavings = num.tryParse(
              state.newMonthlySavings.replaceAll(',', ''),
            );

            if (newMonthlySavings == null || state.obtainPlan.trim().isEmpty) {
              state = state.copyWith(
                errorMessage: "New savings amount and plan are required",
              );
              return false;
            }

            savingsGoalPayload["new_monthly_savings"] = newMonthlySavings;
            savingsGoalPayload["obtain_plan"] = state.obtainPlan.trim();
          }

          final res3 = await http.post(
            Uri.parse(
              '$baseUrl/app/action-strategies/${state.strategyId}/savings-goal',
            ),
            headers: {
              'Content-Type': 'application/json',
              "Authorization": 'Bearer $token',
            },
            body: jsonEncode(savingsGoalPayload),
          );
          print("state.res333:${res3.body}");

          if (res3.statusCode != 200 && res3.statusCode != 201) {
            _handleError(res3);
            return false;
          }

          state = state.copyWith(successMessage: "Step saved successfully!");
          return true;

        case 3:
          print("🟡 STEP 3: Saving Step 4 Investigation Data");
          if (state.strategyId == null || state.strategyId!.isEmpty) {
            state = state.copyWith(errorMessage: "Strategy ID missing");
            return false;
          }

          final investigationPayload = {
            "opportunity_age": _getStep4NoteBySubCat("opportunity_age"),
            "investors_last_5yr": _getStep4NoteBySubCat("successful_investors"),
            "team_experience": _getStep4NoteBySubCat("team_experience"),
            "customer_value": _getStep4NoteBySubCat("customer_value"),
            "other_details": _getStep4NoteBySubCat("other_details"),
          };
          print('investment:');
          final invJson = jsonEncode(investigationPayload);
          final res4 = await http.post(
            Uri.parse(
              '$baseUrl/app/action-strategies/${state.strategyId}/investigation',
            ),
            headers: {
              'Content-Type': 'application/json',
              "Authorization": 'Bearer $token',
            },
            body: invJson,
          );
          print('investment:${res4.body}');

          if (res4.statusCode == 200 || res4.statusCode == 201) {
            state = state.copyWith(
              successMessage: "Investigation saved successfully!",
            );
            return true;
          } else {
            _handleError(res4);
            return false;
          }

        case 4:
          print("🟡 STEP 4: Saving Step 5 Allocation Data");
          if (state.strategyId == null || state.strategyId!.isEmpty) {
            state = state.copyWith(errorMessage: "Strategy ID missing");
            return false;
          }
          print('monthlyAllocationPercent:${state.monthlyAllocationPercent}');
          print('lumpsumAllocationPercent:${state.lumpsumAllocationPercent}');
          if (state.monthlyAllocationPercent != null &&
              state.lumpsumAllocationPercent != null) {
            final allocationPayload = {
              "monthly_percent": state.monthlyAllocationPercent,
              "lumpsum_percent": state.lumpsumAllocationPercent,
              "asset_percentage": state.allocationPercentage,
            };

            final allocJson = jsonEncode(allocationPayload);
            final res5 = await http.post(
              Uri.parse(
                '$baseUrl/app/action-strategies/${state.strategyId}/allocation',
              ),
              headers: {
                'Content-Type': 'application/json',
                "Authorization": 'Bearer $token',
              },
              body: allocJson,
            );
            print('investment:${res5.body}');
            if (res5.statusCode == 200 || res5.statusCode == 201) {
              state = state.copyWith(
                successMessage: "Allocation saved successfully!",
              );
              return true;
            } else {
              _handleError(res5);
              return false;
            }
          }
          return true;

        default:
          return false;
      }
    } catch (e) {
      print("❌ Exception: $e");
      state = state.copyWith(errorMessage: "Network error: $e");
      return false;
    } finally {
      state = state.copyWith(isNavigating: false, isLoading: false);
    }
  }

  // ============ SUBMIT (StepFive only) ============
  // ============ SUBMIT (StepFive only) ============
  Future<bool> submitAllItems(
    BuildContext context, {
    required bool isFinal,
  }) async {
    clearMessages();
    if (state.isNavigating) return false;

    // ✅ NEW: guard against a false-positive "success" on final submit.
    if (isFinal &&
        (state.monthlyAllocationPercent == null ||
            state.lumpsumAllocationPercent == null)) {
      state = state.copyWith(
        errorMessage:
            "Please select a monthly and lumpsum allocation percentage before saving",
      );
      return false;
    }

    state = state.copyWith(isNavigating: true, isLoading: true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenDB');

    try {
      String? strategyId = state.strategyId;

      if (strategyId == null || strategyId.isEmpty) {
        final createPayload = jsonEncode({
          "name": state.investmentName,
          "reason": state.investmentReason,
          "category": state.selectedCategory,
        });
        print("📤 SUBMIT: CREATE PAYLOAD: $createPayload");
        final createRes = await http.post(
          Uri.parse('$baseUrl/app/action-strategies'),
          headers: {
            'Content-Type': 'application/json',
            "Authorization": 'Bearer $token',
          },
          body: createPayload,
        );

        if (createRes.statusCode == 200 || createRes.statusCode == 201) {
          final data = jsonDecode(createRes.body);
          if (data['data'] != null && data['data']['strategy'] != null) {
            strategyId = data['data']['strategy']['id'].toString();
          } else if (data['id'] != null) {
            strategyId = data['id'].toString();
          }

          if (strategyId != null) {
            state = state.copyWith(strategyId: strategyId);
          } else {
            _handleError(createRes);
            return false;
          }
        } else {
          _handleError(createRes);
          return false;
        }
      }

      final validStep2Items = _getValidStep2Items();

      final validStep3Items = state.step3Items
          .where(
            (item) =>
                item['sub_category'] != 'keep_savings' &&
                item['sub_category'] != 'increase_savings' &&
                item['sub_category'] != 'alpha_balance',
          )
          .toList();

      final combinedItems = [...validStep2Items, ...validStep3Items];

      if (combinedItems.isNotEmpty) {
        final itemsPayload = jsonEncode({"items": combinedItems});

        print("strategyId:$strategyId");
        print("📤 SUBMIT: ITEMS PAYLOAD: $itemsPayload");

        final res = await http.post(
          Uri.parse('$baseUrl/app/action-strategies/$strategyId/items'),
          headers: {
            'Content-Type': 'application/json',
            "Authorization": 'Bearer $token',
          },
          body: itemsPayload,
        );

        print("📥 SUBMIT: ITEMS STATUS: ${res.statusCode}, BODY: ${res.body}");

        if (res.statusCode != 200 && res.statusCode != 201) {
          _handleError(res);
          return false;
        }
      }

      final savingsGoalPayload = <String, dynamic>{
        "savings_choice": state.savingsChoice,
      };

      if (state.savingsChoice == 'increase_amount') {
        final newMonthlySavings = num.tryParse(
          state.newMonthlySavings.replaceAll(',', ''),
        );

        if (newMonthlySavings == null || state.obtainPlan.trim().isEmpty) {
          state = state.copyWith(
            errorMessage: "New savings amount and plan are required",
          );
          return false;
        }

        savingsGoalPayload["new_monthly_savings"] = newMonthlySavings;
        savingsGoalPayload["obtain_plan"] = state.obtainPlan.trim();
      }

      final savingsGoalRes = await http.post(
        Uri.parse('$baseUrl/app/action-strategies/$strategyId/savings-goal'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": 'Bearer $token',
        },
        body: jsonEncode(savingsGoalPayload),
      );
      print("state.res333:${savingsGoalRes.body}");

      if (savingsGoalRes.statusCode != 200 &&
          savingsGoalRes.statusCode != 201) {
        _handleError(savingsGoalRes);
        return false;
      }

      if (state.step4Items.isNotEmpty) {
        final investigationPayload = {
          "opportunity_age": _getStep4NoteBySubCat("opportunity_age"),
          "investors_last_5yr": _getStep4NoteBySubCat("successful_investors"),
          "team_experience": _getStep4NoteBySubCat("team_experience"),
          "customer_value": _getStep4NoteBySubCat("customer_value"),
          "other_details": _getStep4NoteBySubCat("other_details"),
        };

        final invJson = jsonEncode(investigationPayload);
        final invRes = await http.post(
          Uri.parse('$baseUrl/app/action-strategies/$strategyId/investigation'),
          headers: {
            'Content-Type': 'application/json',
            "Authorization": 'Bearer $token',
          },
          body: invJson,
        );

        if (invRes.statusCode != 200 && invRes.statusCode != 201) {
          _handleError(invRes);
          return false;
        }
      }

      // ✅ CHANGED: on final submit this is now guaranteed to run (guard
      // clause above already bailed out early if either percent was
      // null), so there's no longer a silent "skip + return true" path.
      if (state.monthlyAllocationPercent != null &&
          state.lumpsumAllocationPercent != null) {
        final allocationPayload = {
          "monthly_percent": state.monthlyAllocationPercent,
          "lumpsum_percent": state.lumpsumAllocationPercent,
          "asset_percentage": state.allocationPercentage,
        };

        final allocJson = jsonEncode(allocationPayload);
        final allocRes = await http.post(
          Uri.parse('$baseUrl/app/action-strategies/$strategyId/allocation'),
          headers: {
            'Content-Type': 'application/json',
            "Authorization": 'Bearer $token',
          },
          body: allocJson,
        );

        if (allocRes.statusCode != 200 && allocRes.statusCode != 201) {
          _handleError(allocRes);
          return false;
        }
      } else if (isFinal) {
        // ✅ NEW: defensive fallback — should be unreachable because of
        // the guard clause at the top, but avoids ever silently
        // reporting success on a final submit with no allocation saved.
        state = state.copyWith(
          errorMessage: "Allocation percentages are required to finish",
        );
        return false;
      }

      state = state.copyWith(
        successMessage: isFinal
            ? "Strategy submitted successfully!"
            : "Progress saved!",
      );
      return true;
    } catch (e) {
      print("❌ Submit Exception: $e");
      state = state.copyWith(errorMessage: "Network error: $e");
      return false;
    } finally {
      state = state.copyWith(isNavigating: false, isLoading: false);
    }
  }

  Future<List<dynamic>> fetchAllStrategies() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenDB');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/app/action-strategies'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          return data['data']['strategies'] ?? [];
        }
      }
      return [];
    } catch (e) {
      print("❌ Fetch strategies error: $e");
      return [];
    }
  }

  void _handleError(http.Response res) {
    try {
      final data = jsonDecode(res.body);
      String errorText = "Failed to save";

      if (data is Map) {
        if (data.containsKey("reason") && data["reason"] is List) {
          errorText = "Reason: ${data["reason"].first}";
        } else if (data.containsKey("name") && data["name"] is List) {
          errorText = "Name: ${data["name"].first}";
        } else if (data.containsKey("message")) {
          errorText = data["message"];
        } else {
          errorText = data.toString();
        }
      }

      state = state.copyWith(errorMessage: errorText);
    } catch (e) {
      state = state.copyWith(errorMessage: "Failed: ${res.statusCode}");
    }
  }

  Future<void> fetchStrategyData(String strategyId) async {
    clearMessages();
    state = state.copyWith(isLoading: true, strategyId: strategyId);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenDB');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/app/action-strategies/$strategyId'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": 'Bearer $token',
        },
      );
      debugPrint(
        "📥 STRATEGY BY ID (${response.statusCode}): ${response.body}",
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = _extractStrategyMap(decoded);
        _applyStrategyData(data, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: "Failed to load strategy: ${response.statusCode}",
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Network error: $e",
      );
    }
  }

  Map _extractStrategyMap(dynamic decoded) {
    if (decoded is! Map) return {};
    final inner = decoded['data'];
    if (inner is Map) {
      final nested = inner['strategy'];
      if (nested is Map) return nested;
      return inner;
    }
    return decoded;
  }

  void loadFromStrategySummary(dynamic strategy) {
    clearMessages();
    _applyStrategyData(strategy, isLoading: false);
  }

  void _applyStrategyData(dynamic data, {required bool isLoading}) {
    // Load all fields from strategy data
    final name = (data['name'] ?? '').toString();
    final reason = (data['reason'] ?? '').toString();
    final category = (data['category'] ?? '').toString();
    final investigation = (data['investigation'] ?? '').toString();
    final monthlyPercent = (data['monthly_percent'] ?? '').toString();
    final lumpsumPercent = (data['lumpsum_percent'] ?? '').toString();
    final savingsChoice = (data['savings_choice'] ?? '').toString();

    final rawItems = (data['items'] as List?) ?? [];
    final items = rawItems
        .whereType<Map>()
        .map<Map<String, String>>(
          (it) => {
            "sub_category": (it['sub_category'] ?? '').toString(),
            "note": (it['note'] ?? '').toString(),
          },
        )
        .toList();

    // Parse allocation percentages to int? for chip selection UI
    int? parsedMonthly;
    // int? parsedLumpsum;
    // if (monthlyPercent.isNotEmpty) {
    //   parsedMonthly = int.tryParse(monthlyPercent);
    // }
    // if (lumpsumPercent.isNotEmpty) {
    //   parsedLumpsum = int.tryParse(lumpsumPercent);
    // }

    bool filled(String v) => v.trim().isNotEmpty;

    int completedSteps = 0;

    if (filled(name)) completedSteps++;
    if (filled(reason)) completedSteps++;
    if (filled(category)) completedSteps++;
    if (filled(investigation)) completedSteps++;
    if (items.isNotEmpty) completedSteps++;
    int startStep = items.isEmpty
        ? 1
        : !filled(savingsChoice)
        ? 2
        : completedSteps >= 5
        ? 4
        : (completedSteps > 0 ? completedSteps - 1 : 0);
    startStep = startStep.clamp(0, 4);

    state = state.copyWith(
      investmentName: name,
      investmentReason: reason,
      selectedCategory: category.isNotEmpty ? category : null,
      savingsChoice: savingsChoice,
      newMonthlySavings: (data['new_monthly_savings'] ?? '').toString(),
      obtainPlan: (data['obtain_plan'] ?? '').toString(),
      investigation: investigation,
      monthlyPercent: monthlyPercent,
      lumpsumPercent: lumpsumPercent,
      monthlyAllocationPercent: parsedMonthly,
      // lumpsumAllocationPercent: parsedLumpsum,
      strategyId: data['id']?.toString() ?? state.strategyId,
      step2Items: items,
      step2CategoryJustSelected: false,
      currentStep: startStep,
      isLoading: isLoading,
      nameError: _validateName(name),
      reasonError: _validateReason(reason),
      successMessage: "Strategy loaded",
    );

    state = state.copyWith(
      step1Progress: filled(name) && filled(reason) ? 1.0 : 0.1,
      step2Progress: filled(category) && items.isNotEmpty
          ? 1.0
          : (filled(category) ? 0.5 : 0.0),
      step3Progress: filled(investigation) ? 1.0 : 0.0,
      step4Progress: (filled(monthlyPercent) || filled(lumpsumPercent))
          ? 1.0
          : 0.0,
      step5Progress: 0.0,
    );
  }

  void goToPreviousStep(BuildContext context) {
    clearMessages();

    if (state.currentStep == 3 && state.step4ShowInvestigateForm) {
      state = state.copyWith(step4ShowInvestigateForm: false);
      return;
    }

    if (state.currentStep == 4 && state.step5ShowSummaryScreen) {
      state = state.copyWith(step5ShowSummaryScreen: false);
      return;
    }

    if (state.currentStep == 4 && state.step5ShowSecondScreen) {
      state = state.copyWith(step5ShowSecondScreen: false);
      return;
    }

    if (state.currentStep == 1 &&
        state.selectedCategory != null &&
        state.selectedCategory!.isNotEmpty) {
      state = state.copyWith(
        selectedCategory: '',
        step2TotalItems: 0,
        step2Progress: 0.1,
        step2CategoryJustSelected: false,
      );
      return;
    }

    if (state.currentStep > 0) {
      final prevStep = state.currentStep - 1;
      state = state.copyWith(
        currentStep: prevStep,
        strategyId: state.strategyId,
        isNavigating: false,
        step1Progress: prevStep == 0 && state.step1Progress == 0
            ? 0.1
            : state.step1Progress,
        step2Progress: prevStep == 1 && state.step2Progress == 0
            ? 0.1
            : state.step2Progress,
        step3Progress: prevStep == 2 && state.step3Progress == 0
            ? 0.1
            : state.step3Progress,
        step4Progress: prevStep == 3 && state.step4Progress == 0
            ? 0.1
            : state.step4Progress,
        step5Progress: prevStep == 4 && state.step5Progress == 0
            ? 0.1
            : state.step5Progress,
      );
    } else {
      if (context.mounted) Navigator.pop(context);
    }
  }
}

final investmentFormControllerProvider =
    NotifierProvider<InvestmentFormController, InvestmentFormState>(
      InvestmentFormController.new,
    );
