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
    state = state.copyWith(step2Items: items);
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
  // ✅ FIXED: always keeps a fixed-length list (step4TotalQuestions long),
  // so filling field index 3 before index 0/1 can never shift positions
  // or leave gaps. Missing slots are padded with empty notes.
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

    // Base progress once the Investigate form has been opened is 0.2;
    // remaining 0.8 is distributed evenly across the 5 fields.
    final base = state.step4Progress >= 0.2 ? 0.2 : 0.1;
    final fieldProgress = (filled / step4TotalQuestions) * 0.8;
    final progress = base + fieldProgress;

    state = state.copyWith(step4Progress: progress.clamp(0.1, 1.0));
  }

  // ✅ Toggle between Step 4's intro screen and its Investigate form.
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

  // ✅ NEW: StepFive is now a percentage-allocation question rather than
  // a note field, so progress is driven by allocationPercentage instead
  // of step5Items.
  void updateAllocationPercentage(String value) {
    state = state.copyWith(allocationPercentage: value);
    _updateStep5Progress();
  }

  // ✅ CHANGED: step5Progress now spans both Step 5 screens —
  // 0.1 nothing entered, 0.5 once the percentage screen is answered,
  // 1.0 once both allocation chips are picked on the Allocation screen.
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

  // ✅ NEW: Toggle between Step 5's percentage screen and its Allocation
  // (second) screen.
  void setStep5ShowSecondScreen(bool value) {
    state = state.copyWith(step5ShowSecondScreen: value);
  }

  // ✅ NEW: Single-select chip for monthly allocation. Tapping the
  // currently-selected percent again deselects it.
  void updateMonthlyAllocationPercent(int percent) {
    if (state.monthlyAllocationPercent == percent) {
      state = state.copyWith(clearMonthlyAllocationPercent: true);
    } else {
      state = state.copyWith(monthlyAllocationPercent: percent);
    }
    _updateStep5Progress();
  }

  // ✅ NEW: Single-select chip for lumpsum allocation. Tapping the
  // currently-selected percent again deselects it.
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
        return state.step3Items.isNotEmpty &&
            state.step3Items.every((i) => i["note"]!.trim().isNotEmpty);

      case 3:
        // Requires the first 4 questions filled; "other_details" (index 4) is optional.
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
            debugPrint("📤 CREATE STRATEGY PAYLOAD: $createPayload");

            final createRes = await http.post(
              Uri.parse('$baseUrl/app/action-strategies'),
              headers: {
                'Content-Type': 'application/json',
                "Authorization": 'Bearer $token',
              },
              body: createPayload,
            );

            print("Create Status: ${createRes.statusCode}");
            print("📥 CREATE RESPONSE BODY: ${createRes.body}");

            if (createRes.statusCode == 200 || createRes.statusCode == 201) {
              final data = jsonDecode(createRes.body);
              strategyId = data["id"].toString();
              state = state.copyWith(strategyId: strategyId);
              print(
                "✅ Strategy created with ID: $strategyId, category: ${state.selectedCategory}",
              );
            } else {
              _handleError(createRes);
              return false;
            }
          }

          final itemsPayload = jsonEncode({"items": state.step2Items});
          debugPrint("📤 STEP 2 ITEMS PAYLOAD: $itemsPayload");

          final res = await http.post(
            Uri.parse('$baseUrl/app/action-strategies/$strategyId/items'),
            headers: {
              'Content-Type': 'application/json',
              "Authorization": 'Bearer $token',
            },
            body: itemsPayload,
          );

          print("Items Status: ${res.statusCode}");
          print("📥 ITEMS RESPONSE BODY: ${res.body}");

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
          print("🟡 STEP 2: Saving Step 3 Items");
          if (state.strategyId == null || state.strategyId!.isEmpty) {
            state = state.copyWith(errorMessage: "Strategy ID missing");
            return false;
          }

          final res3 = await http.post(
            Uri.parse(
              '$baseUrl/app/action-strategies/${state.strategyId}/items',
            ),
            headers: {
              'Content-Type': 'application/json',
              "Authorization": 'Bearer $token',
            },
            body: jsonEncode({"items": state.step3Items}),
          );

          if (res3.statusCode == 200 || res3.statusCode == 201) {
            state = state.copyWith(successMessage: "Step saved successfully!");
            return true;
          } else {
            _handleError(res3);
            return false;
          }

        case 3:
          print("🟡 STEP 3: Saving Step 4 Items");
          if (state.strategyId == null || state.strategyId!.isEmpty) {
            state = state.copyWith(errorMessage: "Strategy ID missing");
            return false;
          }

          // 📤 Log the outgoing payload too — if the server rejects it,
          // we need to see exactly what was sent, not just the response.
          final step4Payload = jsonEncode({"items": state.step4Items});
          print("📤 STEP4 SAVE PAYLOAD: $step4Payload");

          final res4 = await http.post(
            Uri.parse(
              '$baseUrl/app/action-strategies/${state.strategyId}/items',
            ),
            headers: {
              'Content-Type': 'application/json',
              "Authorization": 'Bearer $token',
            },
            body: step4Payload,
          );

          print("📥 STEP4 SAVE STATUS: ${res4.statusCode}, BODY: ${res4.body}");

          if (res4.statusCode == 200 || res4.statusCode == 201) {
            state = state.copyWith(successMessage: "Step saved successfully!");
            return true;
          } else {
            _handleError(res4);
            return false;
          }

        case 4:
          print("🟡 STEP 4: Saving Step 5 Items");
          if (state.strategyId == null || state.strategyId!.isEmpty) {
            state = state.copyWith(errorMessage: "Strategy ID missing");
            return false;
          }

          final res5 = await http.post(
            Uri.parse(
              '$baseUrl/app/action-strategies/${state.strategyId}/items',
            ),
            headers: {
              'Content-Type': 'application/json',
              "Authorization": 'Bearer $token',
            },
            body: jsonEncode({"items": state.step5Items}),
          );

          if (res5.statusCode == 200 || res5.statusCode == 201) {
            state = state.copyWith(successMessage: "All progress saved!");
            return true;
          } else {
            _handleError(res5);
            return false;
          }

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
  // ✅ NEW: nothing is saved to the API while navigating through Steps
  // 1-4 anymore — goToNextStep() just advances currentStep locally.
  // This is the single point where everything actually gets persisted:
  // it creates the strategy (if not already created) and sends the
  // combined items from Steps 2-5 in one request.
  //
  // isFinal distinguishes the two StepFive buttons only for messaging —
  // both paths save the same combined data.
  Future<bool> submitAllItems(
    BuildContext context, {
    required bool isFinal,
  }) async {
    clearMessages();
    if (state.isNavigating) return false;

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
        print("📤 SUBMIT: CREATE STRATEGY PAYLOAD: $createPayload");

        final createRes = await http.post(
          Uri.parse('$baseUrl/app/action-strategies'),
          headers: {
            'Content-Type': 'application/json',
            "Authorization": 'Bearer $token',
          },
          body: createPayload,
        );

        print(
          "📥 SUBMIT: CREATE STATUS: ${createRes.statusCode}, BODY: ${createRes.body}",
        );

        if (createRes.statusCode == 200 || createRes.statusCode == 201) {
          final data = jsonDecode(createRes.body);
          strategyId = data["id"].toString();
          state = state.copyWith(strategyId: strategyId);
        } else {
          _handleError(createRes);
          return false;
        }
      }

      final combinedItems = [
        ...state.step2Items,
        ...state.step3Items,
        ...state.step4Items,
        ...state.step5Items,
        if (state.allocationPercentage.trim().isNotEmpty)
          {
            "sub_category": "allocation_percentage",
            "note": state.allocationPercentage,
          },
        if (state.monthlyAllocationPercent != null) // ✅ NEW
          {
            "sub_category": "monthly_allocation_percentage",
            "note": state.monthlyAllocationPercent.toString(),
          },
        if (state.lumpsumAllocationPercent != null) // ✅ NEW
          {
            "sub_category": "lumpsum_allocation_percentage",
            "note": state.lumpsumAllocationPercent.toString(),
          },
      ];
      final itemsPayload = jsonEncode({"items": combinedItems});
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

      if (res.statusCode == 200 || res.statusCode == 201) {
        state = state.copyWith(
          successMessage: isFinal
              ? "Strategy submitted successfully!"
              : "Progress saved!",
        );
        return true;
      } else {
        _handleError(res);
        return false;
      }
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
        final data = (decoded is Map && decoded['data'] is Map)
            ? decoded['data'] as Map
            : decoded;
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

  void loadFromStrategySummary(dynamic strategy) {
    clearMessages();
    _applyStrategyData(strategy, isLoading: false);
  }

  void _applyStrategyData(dynamic data, {required bool isLoading}) {
    final name = (data['name'] ?? '').toString();
    final reason = (data['reason'] ?? '').toString();
    final category = (data['category'] ?? '').toString();
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

    final stepOneComplete = name.trim().isNotEmpty && reason.trim().isNotEmpty;
    final hasCategory = category.trim().isNotEmpty;
    final hasItems = items.isNotEmpty;

    int startStep;
    if (!stepOneComplete) {
      startStep = 0;
    } else if (!hasCategory || !hasItems) {
      startStep = 0;
    } else {
      startStep = 1;
    }

    state = state.copyWith(
      investmentName: name,
      investmentReason: reason,
      selectedCategory: hasCategory ? category : null,
      strategyId: data['id']?.toString() ?? state.strategyId,
      step2Items: hasItems ? items : state.step2Items,
      currentStep: startStep,
      isLoading: isLoading,
      nameError: _validateName(name),
      reasonError: _validateReason(reason),
      successMessage: "Strategy loaded",
    );

    state = state.copyWith(
      step1Progress: stepOneComplete
          ? 1.0
          : (state.step1Progress == 0 ? 0.1 : state.step1Progress),
      step2Progress: hasItems ? 1.0 : (hasCategory ? 0.1 : state.step2Progress),
    );
  }

  void goToPreviousStep(BuildContext context) {
    clearMessages();

    // If on Step 4's Investigate screen, go back to Step 4's intro screen
    // instead of leaving Step 4 entirely.
    if (state.currentStep == 3 && state.step4ShowInvestigateForm) {
      state = state.copyWith(step4ShowInvestigateForm: false);
      return;
    }

    // ✅ NEW: If on Step 5's Allocation (second) screen, go back to Step 5's
    // percentage screen instead of leaving Step 5 entirely.
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
