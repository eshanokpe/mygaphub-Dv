import 'dart:async';
import 'dart:convert';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/seed_form.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'viewtransaction.dart';

class RecordSpendData extends StatefulWidget {
  final bool month;
  const RecordSpendData(this.month, {super.key});

  @override
  State<RecordSpendData> createState() => _RecordSpendDataState();
}

class _RecordSpendDataState extends State<RecordSpendData> {
  // Controllers
  final TextEditingController savingAmount = TextEditingController();
  final TextEditingController savingNote = TextEditingController();
  final TextEditingController savdateinput = TextEditingController();
  final TextEditingController savingPayee = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // State variables
  Map data = {};
  String datez = "";
  String currentmonth = "";
  double budgetAmount = 0;

  // Recurring switch
  final _recurringController = ValueNotifier<bool>(false);
  bool showRecurring = false;

  // Dropdown values
  String category = '-Select-';
  String savings = '0';
  String accommodation = '0';
  String family = '0';
  String utility = '0';
  String transportation = '0';
  String debtRepayment = '0';
  String education = '0';
  String expenditure = '0';
  String discretionary = '0';

  // Error messages
  String dropdownError = '';
  String educationError = '';
  String savingsError = '';
  String expenditureError = '';
  String accommodationError = '';
  String familyError = '';
  String utilityError = '';
  String transportationError = '';
  String debtRepaymentError = '';
  String discretionaryError = '';

  // Visibility flags
  bool _showSavingTextField = false;
  bool _showSavingAllocation = false;
  bool _showEducationDropdown = false;
  bool _showEducationAllocation = false;
  bool _showExpenditureDropdown = false;
  bool _showDiscretionaryDropdown = false;
  bool _showDiscretionaryAllocation = false;
  bool _showFamilyAllocation = false;

  // Sub-expenditure visibility flags
  bool _showSubExpenditureAccommodation = false;
  bool _showSubExpenditureFamily = false;
  bool _showSubExpenditureUtilities = false;
  bool _showSubExpenditureTransportation = false;
  bool _showSubExpenditureDebtRepayment = false;

  // Data lists
  List _savingsData = [];
  List _educationData = [];
  List _expenditureData = [];
  List _familyData = [];
  List _utilityData = [];
  List _transportationData = [];
  List _debtRepaymentData = [];
  List _discretionaryData = [];
  List _accommodationData = [];

  // Balance variables
  num amount = 0.0;
  num? savingsBalance;
  num? educationBalance;
  num? accommodationBalance;
  num? discretionaryBalance;
  num? familyBalance;
  num? utilityBalance;
  num? transportationBalance;
  num? debtRepaymentBalance;

  // Available balances
  num? savingsAvailableBalance;
  num? educationAvailableBalance;
  num? accommodationAvailableBalance;
  num? discretionaryAvailableBalance;
  num? familyAvailableBalance;
  num? utilityAvailableBalance;
  num? transportationAvailableBalance;
  num? debtRepaymentAvailableBalance;

  // Spent amounts
  num? savingsTotalSpent;
  num? educationTotalSpent;
  num? accommodationTotalSpent;
  num? discretionaryTotalSpent;
  num? familyTotalSpent;
  num? utilityTotalSpent;
  num? transportationTotalSpent;
  num? debtRepaymentTotalSpent;

  // Allocation ID
  int allocationId = 0;

  // Dropdown options
  static const subExpenditureOptions = <String>[
    '-Select-',
    'accommodation',
    'family',
    'utilities',
    'transportation',
    'debt_repayment',
  ];

  static const categoryOptions = <String>[
    '-Select-',
    'Savings',
    'Education',
    'Expenditure',
    'Discretionary',
  ];

  @override
  void initState() {
    super.initState();
    data = context.read<Providers>().seedata;
    DateTime date = DateTime.parse(data['data']["current_seed"]["period"]);
    datez = DateFormat.yMMMM().format(date);

    _recurringController.addListener(_handleRecurringSwitchChange);

    _fetchInitialData();
  }

  @override
  void dispose() {
    _recurringController.dispose();
    savingAmount.dispose();
    savingNote.dispose();
    savdateinput.dispose();
    savingPayee.dispose();
    super.dispose();
  }

  void _handleRecurringSwitchChange() {
    setState(() {
      showRecurring = _recurringController.value;
    });
  }

  Future<void> _fetchInitialData() async {
    await Future.wait([
      fetchSavings(),
      fetchEducation(),
      fetchExpenditure(),
      fetchAccommodation(),
      fetchFamily(),
      fetchUtility(),
      fetchTransportation(),
      fetchDebtRepayment(),
      fetchDiscretionary(),
    ]);
  }

  // Data fetching methods
  Future<void> fetchSavings() async {
    final response = await _fetchCategoryData('savings');
    if (response != null) {
      setState(() => _savingsData = response);
    }
  }

  Future<void> fetchEducation() async {
    final response = await _fetchCategoryData('education');
    if (response != null) {
      setState(() => _educationData = response);
    }
  }

  Future<void> fetchExpenditure() async {
    final response = await _fetchExpenditureData();
    if (response != null) {
      setState(() => _expenditureData = response);
    }
  }

  Future<void> fetchAccommodation() async {
    final response = await _fetchSubExpenditureData('accommodation');
    if (response != null) {
      context.read<Providers>().expen(response);
      setState(() => _accommodationData = response);
    }
  }

  Future<void> fetchFamily() async {
    final response = await _fetchSubExpenditureData('family');
    if (response != null) {
      setState(() => _familyData = response);
    }
  }

  Future<void> fetchUtility() async {
    final response = await _fetchSubExpenditureData('utilities');
    if (response != null) {
      setState(() => _utilityData = response);
    }
  }

  Future<void> fetchTransportation() async {
    final response = await _fetchSubExpenditureData('transportation');
    if (response != null) {
      setState(() => _transportationData = response);
    }
  }

  Future<void> fetchDebtRepayment() async {
    final response = await _fetchSubExpenditureData('debt_repayment');
    if (response != null) {
      setState(() => _debtRepaymentData = response);
    }
  }

  Future<void> fetchDiscretionary() async {
    final response = await _fetchCategoryData('discretionary');
    if (response != null) {
      context.read<Providers>().deleteReminder();
      setState(() => _discretionaryData = response);
    }
  }

  Future<List<dynamic>?> _fetchCategoryData(String category) async {
    final url = Uri.parse(
      "$baseUrl/app/seed/allocate/budget?category=$category",
    );
    final token = await _getToken();

    final response = await http.get(url, headers: _buildHeaders(token));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["data"]['budget_allocations'];
    }
    return null;
  }

  Future<List<dynamic>?> _fetchExpenditureData() async {
    final url = Uri.parse(
      "$baseUrl/app/seed/allocate/budget?category=expenditure",
    );
    final token = await _getToken();

    final response = await http.get(url, headers: _buildHeaders(token));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["data"]['budget_expenditures'];
    }
    return null;
  }

  Future<List<dynamic>?> _fetchSubExpenditureData(String subCategory) async {
    final url = Uri.parse(
      "$baseUrl/app/seed/allocate/budget?category=expenditure&expenditure=$subCategory",
    );
    final token = await _getToken();

    final response = await http.get(url, headers: _buildHeaders(token));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["data"]['budget_allocations'];
    }
    return null;
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tokenDB');
  }

  Map<String, String> _buildHeaders(String? token) {
    return {
      "Authorization": 'Bearer $token',
      "Accept": "application/json",
      "Content-Type": "application/x-www-form-urlencoded",
    };
  }

  Future<void> _fetchAllocationBalance(String id, String category) async {
    print("id:$id");
    final url = Uri.parse("$baseUrl/app/seed/allocate/$id");
    final token = await _getToken();

    final response = await http.get(url, headers: _buildHeaders(token));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final totalLeft = body['data']['summary']['total_left'];

      setState(() {
        switch (category) {
          case 'savings':
            savingsAvailableBalance = totalLeft;
            savingsTotalSpent = savingsAvailableBalance! - amount;
            context.read<Providers>().savingsavailabelbalance(totalLeft);
            break;
          case 'education':
            educationAvailableBalance = totalLeft;
            educationTotalSpent = educationAvailableBalance! - amount;
            context.read<Providers>().educationavailabelbalance(totalLeft);
            break;
          case 'accommodation':
            accommodationAvailableBalance = totalLeft;
            accommodationTotalSpent = accommodationAvailableBalance! - amount;
            context.read<Providers>().accommadationavailabelbalance(totalLeft);
            break;
          case 'family':
            familyAvailableBalance = totalLeft;
            familyTotalSpent = familyAvailableBalance! - amount;
            context.read<Providers>().familyavailabelbalance(totalLeft);
            context.read<Providers>().familytotalspent(familyTotalSpent);
            break;
          case 'utilities':
            utilityAvailableBalance = totalLeft;
            utilityTotalSpent = utilityAvailableBalance! - amount;
            context.read<Providers>().utilityavailabelbalance(totalLeft);
            break;
          case 'transportation':
            transportationAvailableBalance = totalLeft;
            transportationTotalSpent = transportationAvailableBalance! - amount;
            context.read<Providers>().transportationavailabelbalance(totalLeft);
            break;
          case 'debt_repayment':
            debtRepaymentAvailableBalance = totalLeft;
            debtRepaymentTotalSpent = debtRepaymentAvailableBalance! - amount;
            context.read<Providers>().debt_repaymentavailabelbalance(totalLeft);
            break;
          case 'discretionary':
            discretionaryAvailableBalance = totalLeft;
            discretionaryTotalSpent = discretionaryAvailableBalance! - amount;
            context.read<Providers>().discretionaryavailabelbalance(totalLeft);
            context.read<Providers>().discretionarytotalspent(
              discretionaryTotalSpent,
            );
            break;
        }
      });
    }
  }

  void _updateCategoryVisibility(String selectedCategory) {
    // Reset all visibility flags
    _showSavingTextField = false;
    _showSavingAllocation = false;
    _showEducationDropdown = false;
    _showEducationAllocation = false;
    _showExpenditureDropdown = false;
    _showDiscretionaryDropdown = false;
    _showDiscretionaryAllocation = false;

    // Reset sub-expenditure visibility
    _showSubExpenditureAccommodation = false;
    _showSubExpenditureFamily = false;
    _showSubExpenditureUtilities = false;
    _showSubExpenditureTransportation = false;
    _showSubExpenditureDebtRepayment = false;
    _showFamilyAllocation = false;

    // Set visibility based on selected category
    switch (selectedCategory) {
      case 'Savings':
        _showSavingTextField = true;
        break;
      case 'Education':
        _showEducationDropdown = true;
        break;
      case 'Expenditure':
        _showExpenditureDropdown = true;
        break;
      case 'Discretionary':
        _showDiscretionaryDropdown = true;
        break;
    }
  }

  void _updateSubExpenditureVisibility(String selectedSubExpenditure) {
    // Reset all sub-expenditure visibility flags
    _showSubExpenditureAccommodation = false;
    _showSubExpenditureFamily = false;
    _showSubExpenditureUtilities = false;
    _showSubExpenditureTransportation = false;
    _showSubExpenditureDebtRepayment = false;
    _showFamilyAllocation = false;

    // Set visibility based on selected sub-expenditure
    switch (selectedSubExpenditure) {
      case 'accommodation':
        _showSubExpenditureAccommodation = true;
        break;
      case 'family':
        _showSubExpenditureFamily = true;
        break;
      case 'utilities':
        _showSubExpenditureUtilities = true;
        break;
      case 'transportation':
        _showSubExpenditureTransportation = true;
        break;
      case 'debt_repayment':
        _showSubExpenditureDebtRepayment = true;
        break;
    }
  }

  Future<void> _handleDateSelection() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        savdateinput.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _updateAmount() {
    setState(() {
      amount = savingAmount.text.isNotEmpty
          ? double.tryParse(savingAmount.text) ?? 0.0
          : 0.0;
    });
  }

  Future<void> _submitForm() async {
    final timer = Timer(const Duration(milliseconds: 2000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
    });

    try {
      if (!_formKey.currentState!.validate()) {
        timer.cancel();
        return;
      }
      print('category:$category');

      if (category == '-Select-' || category.isEmpty) {
        setState(() => dropdownError = "Please select an option");
        timer.cancel();
        return;
      }

      // Validate category-specific selections
      if (!_validateCategorySelections()) {
        timer.cancel();
        return;
      }

      // Validate amount
      final amountValue = double.tryParse(savingAmount.text) ?? 0.0;
      if (amountValue <= 0) {
        Fluttertoast.showToast(
          backgroundColor: Colors.red,
          textColor: Colors.white,
          msg: 'Please enter a valid amount',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        timer.cancel();
        return;
      }

      // Validate payee
      if (savingPayee.text.length <= 2) {
        Fluttertoast.showToast(
          backgroundColor: Colors.red,
          textColor: Colors.white,
          msg: 'The payee must be between 3 and 50 characters.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        timer.cancel();
        return;
      }

      // Set allocation ID based on category
      _setAllocationId();

      // Submit the data
      await _submitSpendingRecord();

      timer.cancel();
    } catch (e) {
      timer.cancel();
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: 'Error: ${e.toString()}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  bool _validateCategorySelections() {
    switch (category) {
      case 'Savings':
        if (_savingsData.isEmpty) {
          _showToast('Please make your Savings Allocation');
          return false;
        }
        if (savings == '0') {
          setState(() => savingsError = "Please select an option1");
          return false;
        }
        break;
      case 'Education':
        if (_educationData.isEmpty) {
          _showToast('Please make your Education Allocation');
          return false;
        }
        if (education == '0') {
          setState(() => educationError = "Please select an option2");
          return false;
        }
        break;
      case 'Expenditure':
      // Similar validation for expenditure
      case 'Discretionary':
        if (_discretionaryData.isEmpty) {
          _showToast('Please make your Discretionary Allocation');
          return false;
        }
        // if (discretionary == '0') {
        //   setState(() => discretionaryError = "Please select an option");
        //   return false;
        // }
        break;
    }
    return true;
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      backgroundColor: Colors.red,
      textColor: Colors.white,
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _setAllocationId() {
    switch (category) {
      case 'Savings':
        allocationId = int.parse(savings);
        break;
      case 'Education':
        allocationId = int.parse(education);
        break;
      case 'Expenditure':
        if (_showSubExpenditureAccommodation) {
          allocationId = int.parse(accommodation);
        } else if (_showSubExpenditureFamily) {
          allocationId = int.parse(family);
        } else if (_showSubExpenditureUtilities) {
          allocationId = int.parse(utility);
        } else if (_showSubExpenditureTransportation) {
          allocationId = int.parse(transportation);
        } else if (_showSubExpenditureDebtRepayment) {
          allocationId = int.parse(debtRepayment);
        }
        break;
      case 'Discretionary':
        allocationId = int.parse(discretionary);
        break;
    }
  }

  Future<void> _submitSpendingRecord() async {
    dialogBox.waiting(context, "Saving");

    final token = await _getToken();
    final amountValue = double.parse(savingAmount.text);
    final categoryLower = category.toLowerCase();
    final isRecurring = showRecurring ? "1" : "0";

    final response = await http.post(
      Uri.parse("$baseUrl/app/seed/record/spent"),
      body: {
        'category': categoryLower,
        'label': savingPayee.text.trim(),
        'amount': amountValue.toString(),
        'note': savingNote.text.trim(),
        'allocation': allocationId.toString(),
        'date': savdateinput.text.trim(),
        'recuring': isRecurring,
      },
      headers: _buildHeaders(token),
      encoding: Encoding.getByName("utf-8"),
    );
    print('status:${response.statusCode}');
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      print('body:$body');
      Navigator.pop(context);

      final recordData = await _fetchAllocationData(
        body["data"]['allocation_id'],
        token,
      );

      if (recordData != null) {
        Navigator.of(context).pop();
        _showSuccessAndNavigate(recordData);
      }
    } else {
      Navigator.of(context).pop();
      _handleErrorResponse(response);
    }
  }

  Future<Map<String, dynamic>?> _fetchAllocationData(
    dynamic allocationId,
    String? token,
  ) async {
    try {
      // Convert to string then parse to int to handle both string and int IDs
      final id = int.tryParse(allocationId.toString());
      if (id == null) {
        debugPrint('Invalid allocation ID: $allocationId');
        return null;
      }

      final url = Uri.parse("$baseUrl/app/seed/allocate/$id");
      final response = await http.get(url, headers: _buildHeaders(token));

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching allocation data: $e');
      return null;
    }
  }

  void _showSuccessAndNavigate(Map<String, dynamic> recordData) {
    Fluttertoast.showToast(
      backgroundColor: Colors.green,
      msg: 'Record spent has been recorded',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    context.read<Providers>().setRecorddata(recordData);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ViewTransactionSummary(body: recordData),
      ),
    );
  }

  void _handleErrorResponse(http.Response response) {
    try {
      final errorResponse = jsonDecode(response.body);
      final errorMap = errorResponse is String
          ? jsonDecode(errorResponse)
          : errorResponse;

      if (errorMap.containsKey('errors')) {
        final errors = errorMap['errors'];
        final errorMessage = errors is String
            ? errors
            : errors.values.first.toString();

        Fluttertoast.showToast(
          backgroundColor: Colors.red,
          textColor: Colors.white,
          msg: errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        Fluttertoast.showToast(
          backgroundColor: Colors.red,
          textColor: Colors.white,
          msg: 'An error occurred',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: 'Failed to parse error response',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update state from providers
    _updateStateFromProviders();
    _updateAmount();

    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;
    final height = isPortrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = isPortrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    final currency = context.watch<Providers>().snapshotmodel.currency;

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: height * .02),
            SeedForm(
              name: "Amount",
              hintText: '0.00',
              controller: savingAmount,
              symbol: currency,
              validator: (value) =>
                  value!.trim().isEmpty ? 'Please enter your Amount' : null,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: height * .01),
            _buildDatePicker(width),
            SizedBox(height: height * .01),
            _buildCategoryDropdown(width),
            if (dropdownError.isNotEmpty) _buildErrorText(dropdownError, width),
            SizedBox(height: height * .01),

            // Savings Section
            if (_showSavingTextField) _buildSavingsDropdown(width),
            if (savingsError.isNotEmpty) _buildErrorText(savingsError, width),
            if (_showSavingAllocation)
              _buildAllocationDetails(
                "Savings Available Balance:",
                savingsBalance ?? 0,
                savingsTotalSpent ?? 0,
                currency,
                width,
                height,
              ),

            // Education Section
            if (_showEducationDropdown) _buildEducationDropdown(width),
            if (educationError.isNotEmpty)
              _buildErrorText(educationError, width),
            if (_showEducationAllocation)
              _buildAllocationDetails(
                "Education Available Balance:",
                educationBalance ?? 0,
                educationTotalSpent ?? 0,
                currency,
                width,
                height,
              ),

            // Expenditure Section
            // Expenditure Section
            if (_showExpenditureDropdown) _buildExpenditureDropdown(width),
            if (expenditureError.isNotEmpty)
              _buildErrorText(expenditureError, width),

            // Sub-expenditure allocation details
            if (_showSubExpenditureAccommodation) ...[
              if (_accommodationData.isNotEmpty)
                _buildAccommodationDropdown(width),
              if (accommodationError.isNotEmpty)
                _buildErrorText(accommodationError, width),
              _buildAllocationDetails(
                "Accommodation Available Balance:",
                accommodationBalance ?? 0,
                accommodationTotalSpent ?? 0,
                currency,
                width,
                height,
              ),
            ],

            if (_showSubExpenditureFamily) ...[
              if (_familyData.isNotEmpty) _buildFamilyDropdown(width),
              if (familyError.isNotEmpty) _buildErrorText(familyError, width),
              _buildAllocationDetails(
                "Family Available Balance:",
                familyBalance ?? 0,
                familyTotalSpent ?? 0,
                currency,
                width,
                height,
              ),
            ],

            if (_showSubExpenditureUtilities) ...[
              if (_utilityData.isNotEmpty) _buildUtilitiesDropdown(width),
              if (utilityError.isNotEmpty) _buildErrorText(utilityError, width),
              _buildAllocationDetails(
                "Utilities Available Balance:",
                utilityBalance ?? 0,
                utilityTotalSpent ?? 0,
                currency,
                width,
                height,
              ),
            ],

            if (_showSubExpenditureTransportation) ...[
              if (_transportationData.isNotEmpty)
                _buildTransportationDropdown(width),
              if (transportationError.isNotEmpty)
                _buildErrorText(transportationError, width),
              _buildAllocationDetails(
                "Transportation Available Balance:",
                transportationBalance ?? 0,
                transportationTotalSpent ?? 0,
                currency,
                width,
                height,
              ),
            ],

            if (_showSubExpenditureDebtRepayment) ...[
              if (_debtRepaymentData.isNotEmpty)
                _buildDebtRepaymentDropdown(width),
              if (debtRepaymentError.isNotEmpty)
                _buildErrorText(debtRepaymentError, width),
              _buildAllocationDetails(
                "Debt Repayment Available Balance:",
                debtRepaymentBalance ?? 0,
                debtRepaymentTotalSpent ?? 0,
                currency,
                width,
                height,
              ),
            ],

            // Common form fields for all expenditure types
            if (_showSubExpenditureAccommodation ||
                _showSubExpenditureFamily ||
                _showSubExpenditureUtilities ||
                _showSubExpenditureTransportation ||
                _showSubExpenditureDebtRepayment) ...[
              SeedForm(
                name: "Payee / Merchant",
                hintText: 'E.g. Landlord, Electricity Company',
                controller: savingPayee,
                keyboardType: TextInputType.text,
                symbol: '',
                maxLines: 1,
                validator: (value) =>
                    value!.trim().isEmpty ? 'Please fill the details' : null,
              ),
              SeedForm(
                name: "Description / Note",
                hintText: 'Optional',
                controller: savingNote,
                keyboardType: TextInputType.text,
                symbol: '',
                maxLines: 2,
              ),
              SizedBox(height: height * .01),
              _buildRecurringSwitch(width),
            ],

            // Discretionary Section
            if (_showDiscretionaryDropdown) _buildDiscretionaryDropdown(width),
            if (discretionaryError.isNotEmpty)
              _buildErrorText(discretionaryError, width),
            if (_showDiscretionaryAllocation)
              _buildAllocationDetails(
                "Discretionary Available Balance:",
                discretionaryBalance ?? 0,
                discretionaryTotalSpent ?? 0,
                currency,
                width,
                height,
              ),

            // Sub-expenditure sections...
            // [Similar patterns for other sections]

            // Common form fields
            if (_showSavingAllocation ||
                _showEducationAllocation ||
                _showDiscretionaryAllocation ||
                _showFamilyAllocation)
              Column(
                children: [
                  SeedForm(
                    name: "Payee / Merchant",
                    hintText: 'E.g Hargreaves Lansdown',
                    controller: savingPayee,
                    keyboardType: TextInputType.text,
                    symbol: '',
                    maxLines: 1,
                    validator: (value) => value!.trim().isEmpty
                        ? 'Please fill the details'
                        : null,
                  ),
                  SeedForm(
                    name: "Description / Note",
                    hintText: 'Optional',
                    controller: savingNote,
                    keyboardType: TextInputType.text,
                    symbol: '',
                    maxLines: 2,
                  ),
                  SizedBox(height: height * .01),
                  _buildRecurringSwitch(width),
                ],
              ),

            SizedBox(height: height * .06),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                // minimumSize: Size(width * 0.8, 50),
                padding: EdgeInsets.symmetric(horizontal: width * .08),
              ),
              onPressed: _submitForm,
              child: const Text(
                "Submit",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: height * .06),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * .08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Date:",
            style: TextStyle(
              fontSize: width * .035,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: savdateinput,
            validator: (value) =>
                value!.trim().isEmpty ? 'Please enter date' : null,
            decoration: InputDecoration(
              suffixIcon: const Icon(Icons.calendar_month),
              labelText: "Enter Date",
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(width * .02),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 196, 196, 196),
                ),
                borderRadius: BorderRadius.circular(width * .02),
              ),
            ),
            readOnly: true,
            onTap: _handleDateSelection,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * .08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SEED Category",
            style: TextStyle(
              fontSize: width * .035,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: width * .01),
          Container(
            padding: EdgeInsets.symmetric(horizontal: width * .02),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.white,
              border: Border.all(
                color: const Color.fromARGB(255, 196, 196, 196),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: Colors.white,
                isExpanded: true,
                value: category == '-Select-' ? null : category,
                hint: const Text('-Select-'),
                items: categoryOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    category = newValue ?? '-Select-';
                    dropdownError = ''; // Clear error when selecting
                    _updateCategoryVisibility(category);
                  });
                },
              ),
            ),
          ),
          if (dropdownError.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: width * .08),
              child: Text(
                dropdownError,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSavingsDropdown(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * .08),
      child: _buildDataDropdown(
        data: _savingsData,
        value:
            savings == '0' ||
                savings == '-Select-' ||
                !_savingsData.any((item) => item['id'].toString() == savings)
            ? null
            : savings,
        hint: 'Select Savings',
        onChanged: (value) {
          setState(() {
            savings = value!;
            savingsError = value == '0' ? "Please select an option" : "";
            _showSavingAllocation = value != '0';
          });
          if (value != '0') _fetchAllocationBalance(value!, 'savings');
        },
        width: width,
        isEmpty: _savingsData.isEmpty,
        emptyMessage: "No Savings Allocation Record",
      ),
    );
  }

  Widget _buildEducationDropdown(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * .08),
      child: _buildDataDropdown(
        data: _educationData,
        value:
            education == '0' ||
                savings == '-Select-' ||
                !_educationData.any(
                  (item) => item['id'].toString() == education,
                )
            ? null
            : education,
        hint: 'Select Education',
        onChanged: (value) {
          setState(() {
            education = value!;
            educationError = value == '0' ? "Please select an option" : "";
            _showEducationAllocation = value != '0';
          });
          if (value != '0') _fetchAllocationBalance(value!, 'education');
        },
        width: width,
        isEmpty: _educationData.isEmpty,
        emptyMessage: "No Education Allocation",
      ),
    );
  }

  Widget _buildDiscretionaryDropdown(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * .08),
      child: _buildDataDropdown(
        data: _discretionaryData,
        value:
            discretionary == '0' ||
                savings == '-Select-' ||
                !_educationData.any(
                  (item) => item['id'].toString() == discretionary,
                )
            ? null
            : discretionary,
        hint: 'Select Discretionary',
        onChanged: (value) {
          setState(() {
            discretionary = value!;
            discretionaryError = value == '0' ? "Please select an option" : "";
            _showDiscretionaryAllocation = value != '0';
          });
          if (value != '0') _fetchAllocationBalance(value!, 'discretionary');
        },
        width: width,
        isEmpty: _discretionaryData.isEmpty,
        emptyMessage: "No Discretionary Allocation",
      ),
    );
  }

  Widget _buildExpenditureDropdown(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * .08),
      child: _buildDataDropdown(
        data: _expenditureData,
        value:
            expenditure == '-Select-' ||
                !_expenditureData.any((item) => item['label'] == expenditure)
            ? null
            : expenditure,
        hint: 'Select Expenditure',
        onChanged: (value) {
          setState(() {
            expenditure = value!;
            expenditureError = value == '-Select-'
                ? "Please select an option"
                : "";
            _updateSubExpenditureVisibility(value);
          });
        },
        width: width,
        isEmpty: _expenditureData.isEmpty,
        emptyMessage: "No Expenditure Allocation",
        isExpenditure: true,
      ),
    );
  }

  Widget _buildDataDropdown({
    required List<dynamic> data,
    required String? value,
    required String hint,
    required ValueChanged<String?> onChanged,
    required double width,
    required bool isEmpty,
    required String emptyMessage,
    bool isExpenditure = false,
  }) {
    if (isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: width * .01, left: width * .08),
        child: Text(emptyMessage, style: const TextStyle(color: Colors.red)),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: width * .01),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: width * .02),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
          border: Border.all(color: const Color.fromARGB(255, 196, 196, 196)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            hint: Text(hint),
            items: [
              // Always include the '-Select-' option for expenditure dropdowns
              if (isExpenditure)
                const DropdownMenuItem(
                  value: '-Select-',
                  child: Text('-Select-'),
                ),
              ...data.map((item) {
                // For expenditure, we use the label as both value and display text
                final itemValue = isExpenditure
                    ? item['label']
                    : item['id'].toString();
                final itemText = isExpenditure
                    ? _formatExpenditureLabel(item['label'])
                    : item['label'];

                return DropdownMenuItem(
                  value: itemValue,
                  child: Text(itemText),
                );
              }),
            ],
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  String _formatExpenditureLabel(String label) {
    switch (label) {
      case 'debt_repayment':
        return 'Debt Repayment';
      case 'family':
        return 'Home and Family';
      default:
        return label[0].toUpperCase() + label.substring(1);
    }
  }

  Widget _buildAllocationDetails(
    String title,
    num availableBalance,
    num afterSpend,
    String currency,
    double width,
    double height,
  ) {
    return Padding(
      padding: EdgeInsets.only(left: width * .09, top: height * .01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "$title $currency${availableBalance.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: width * .04,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: height * .005),
          Text(
            "Available After Spend: $currency${afterSpend.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: width * .04,
              color: Colors.black26,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccommodationDropdown(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * .08, vertical: 10),
      child: _buildDataDropdown(
        data: _accommodationData,
        value:
            accommodation == '0' ||
                !_accommodationData.any(
                  (item) => item['id'].toString() == accommodation,
                )
            ? null
            : accommodation,
        hint: 'Select Accommodation',
        onChanged: (value) {
          setState(() {
            accommodation = value!;
            accommodationError = value == '0' ? "Please select an option" : "";
          });
          if (value != '0') _fetchAllocationBalance(value!, 'accommodation');
        },
        width: width,
        isEmpty: _accommodationData.isEmpty,
        emptyMessage: "No Accommodation Allocation",
      ),
    );
  }

  Widget _buildFamilyDropdown(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * .08, vertical: 10),
      child: _buildDataDropdown(
        data: _familyData,
        value:
            family == '0' ||
                !_familyData.any((item) => item['id'].toString() == family)
            ? null
            : family,
        hint: 'Select Family',
        onChanged: (value) {
          setState(() {
            family = value!;
            familyError = value == '0' ? "Please select an option" : "";
          });
          if (value != '0') _fetchAllocationBalance(value!, 'family');
        },
        width: width,
        isEmpty: _familyData.isEmpty,
        emptyMessage: "No Family Allocation",
      ),
    );
  }

  Widget _buildUtilitiesDropdown(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * .08, vertical: 10),
      child: _buildDataDropdown(
        data: _utilityData,
        value:
            utility == '0' ||
                !_utilityData.any((item) => item['id'].toString() == utility)
            ? null
            : utility,
        hint: 'Select Utilities',
        onChanged: (value) {
          setState(() {
            utility = value!;
            utilityError = value == '0' ? "Please select an option" : "";
          });
          if (value != '0') _fetchAllocationBalance(value!, 'utilities');
        },
        width: width,
        isEmpty: _utilityData.isEmpty,
        emptyMessage: "No Utilities Allocation",
      ),
    );
  }

  Widget _buildTransportationDropdown(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * .08, vertical: 10),
      child: _buildDataDropdown(
        data: _transportationData,
        value:
            transportation == '0' ||
                !_transportationData.any(
                  (item) => item['id'].toString() == transportation,
                )
            ? null
            : transportation,
        hint: 'Select Transportation',
        onChanged: (value) {
          setState(() {
            transportation = value!;
            transportationError = value == '0' ? "Please select an option" : "";
          });
          if (value != '0') _fetchAllocationBalance(value!, 'transportation');
        },
        width: width,
        isEmpty: _transportationData.isEmpty,
        emptyMessage: "No Transportation Allocation",
      ),
    );
  }

  Widget _buildDebtRepaymentDropdown(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * .08, vertical: 10),
      child: _buildDataDropdown(
        data: _debtRepaymentData,
        value:
            debtRepayment == '0' ||
                !_debtRepaymentData.any(
                  (item) => item['id'].toString() == debtRepayment,
                )
            ? null
            : debtRepayment,
        hint: 'Select Debt Repayment',
        onChanged: (value) {
          setState(() {
            debtRepayment = value!;
            debtRepaymentError = value == '0' ? "Please select an option" : "";
          });
          if (value != '0') _fetchAllocationBalance(value!, 'debt_repayment');
        },
        width: width,
        isEmpty: _debtRepaymentData.isEmpty,
        emptyMessage: "No Debt Repayment Allocation",
      ),
    );
  }

  Widget _buildRecurringSwitch(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * .08),
      child: Row(
        children: [
          Text(
            "Recurring",
            style: TextStyle(
              fontSize: width * .05,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(width: width * .12),
          AdvancedSwitch(
            inactiveColor: Colors.grey,
            activeChild: const Text('On'),
            inactiveChild: const Text('Off'),
            width: 70.0,
            height: 30.0,
            controller: _recurringController,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorText(String error, double width) {
    return Padding(
      padding: EdgeInsets.only(left: width * .08),
      child: Text(error, style: const TextStyle(color: Colors.red)),
    );
  }

  void _updateStateFromProviders() {
    setState(() {
      _accommodationData = context.read<Providers>().accommodationdata;
      savingsBalance = context.read<Providers>().savingsbalance;
      educationBalance = context.read<Providers>().educationbalance;
      accommodationBalance = context.read<Providers>().accommadationbalance;
      print("accommodationBalance:$accommodationBalance");

      familyBalance = context.read<Providers>().familybalance;
      utilityBalance = context.read<Providers>().utilitybalance;
      transportationBalance = context.read<Providers>().transportationbalance;
      print("transportationBalance:$transportationBalance");
      debtRepaymentBalance = context.read<Providers>().debt_repaymentbalance;
      discretionaryBalance = context.read<Providers>().discretionarybalance;
      discretionaryTotalSpent = context
          .read<Providers>()
          .discretionarytotalspentt;
    });
  }
}

class SavAllocation {
  final String token;

  SavAllocation(this.token);

  factory SavAllocation.fromJSON(dynamic json) {
    return SavAllocation(json['data']['access_token'] as String);
  }

  @override
  String toString() => 'SavAllocation{token: $token}';
}
