import 'dart:async';
import 'dart:convert';
import 'package:GapHub/models/savingAllocationserver.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/seed_form.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'education_allocation_summary.dart';

class EducationAllocation extends StatefulWidget {
  const EducationAllocation({super.key});

  @override
  State<EducationAllocation> createState() => _EducationAllocationState();
}

class _EducationAllocationState extends State<EducationAllocation> {
  final DialogBox dialogBox = DialogBox();

  // Controllers
  final TextEditingController savingAmount = TextEditingController();
  final TextEditingController savingNote = TextEditingController();
  final TextEditingController newlabel = TextEditingController();

  // Form key
  final _formKey = GlobalKey<FormState>();

  // Data
  Map<dynamic, dynamic> data = {};
  List<SavingAllserver> _data = [];

  // State variables
  String datez = "";
  int budget_amount = 0;
  String val = "-Select-";
  bool _showTextField = false;
  String dropdownError = '';
  bool isValid = false;
  String newlabell = '';

  // Constants
  static const List<String> assets = [
    '-Select-',
    'Financial Intelligence Training',
    'Career & Professional Development',
    'Mental & Personal Development',
    'Others',
  ];

  final List<DropdownMenuItem<String>> optionList = assets
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ),
      )
      .toList();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    try {
      data = context.read<Providers>().seedata;
      if (data['data'] != null &&
          data['data']["current_seed"] != null &&
          data['data']["current_seed"]["period"] != null) {
        DateTime date = DateTime.parse(data['data']["current_seed"]["period"]);
        datez = DateFormat.yMMMM().format(date);
      }
    } catch (e) {
      print('Error initializing data: $e');
    }
  }

  @override
  void dispose() {
    savingAmount.dispose();
    savingNote.dispose();
    newlabel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allocationamount = _getAllocationAmount();
    final currency = context.watch<Providers>().snapshotmodel.currency;
    final orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.blue.withOpacity(.05),
      appBar: _buildAppBar(width),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: height * .02),
              _buildCategoryHeader(width),
              SizedBox(height: height * .01),
              _buildDropdown(width),
              if (dropdownError.isNotEmpty) _buildErrorText(width),
              if (_showTextField) _buildCustomLabelField(width),
              SeedForm(
                name: "Amount",
                hintText: ' 0.00',
                controller: savingAmount,
                symbol: currency,
                inputFormatters: [amountValidator],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your Amount';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              SeedForm(
                name: "Note",
                hintText: '',
                controller: savingNote,
                keyboardType: TextInputType.text,
                symbol: '',
                maxLines: 4,
              ),
              SizedBox(height: height * .06),
              _buildSubmitButton(width, allocationamount, currency),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(double width) {
    return AppBar(
      backgroundColor: Colors.blue.withOpacity(.05),
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Education Allocation',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: width * .035,
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.black),
      ),
    );
  }

  Widget _buildCategoryHeader(double width) {
    return Padding(
      padding: EdgeInsets.only(left: width * .08),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Education Category",
            style: TextStyle(
              fontSize: width * .04,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(double width) {
    return Container(
      padding: EdgeInsets.only(left: width * .02),
      width: width,
      margin: EdgeInsets.symmetric(horizontal: width * .08),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
        border: Border.all(color: const Color.fromARGB(255, 196, 196, 196)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          focusColor: Theme.of(context).primaryColor,
          value: val,
          items: optionList,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                val = value;
                dropdownError = '';
                isValid = val != assets[0];
                _showTextField = val == assets[4];
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildErrorText(double width) {
    return Padding(
      padding: EdgeInsets.only(left: width * .08),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(dropdownError, style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildCustomLabelField(double width) {
    return Padding(
      padding: EdgeInsets.only(
        left: width * .08,
        top: width * .05,
        right: width * .08,
      ),
      child: TextFormField(
        keyboardType: TextInputType.text,
        controller: newlabel,
        style: TextStyle(fontSize: width * .04, fontWeight: FontWeight.w300),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter your Label';
          }
          return null;
        },
        decoration: InputDecoration(
          filled: true,
          hintText: 'Create a new label',
          contentPadding: EdgeInsets.only(top: width * .05, left: width * .02),
          disabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(width * .02),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 196, 196, 196),
            ),
            borderRadius: BorderRadius.circular(width * .02),
          ),
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(width * .01),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(
    double width,
    dynamic allocationamount,
    String currency,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        padding: EdgeInsets.symmetric(horizontal: width * .10, vertical: 12),
      ),
      onPressed: () => _handleSubmit(allocationamount, currency),
      child: Text(
        "Submit",
        style: TextStyle(
          fontSize: width * .04,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  dynamic _getAllocationAmount() {
    try {
      return data['data']?["current_seed"]?["budget_amount"] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _handleSubmit(dynamic allocationamount, String currency) async {
    // Cancel any existing timers
    // Create timeout timer
    late Timer timer;

    try {
      // Validate form
      if (!_formKey.currentState!.validate()) {
        return;
      }

      // Validate dropdown
      if (val == '-Select-') {
        setState(() => dropdownError = "Please select an option");
        return;
      }

      // Validate amount
      final amountText = savingAmount.text.trim();
      if (amountText.isEmpty) {
        _showErrorToast('Please enter an amount');
        return;
      }

      final int amount = int.tryParse(amountText) ?? 0;
      if (amount <= 0) {
        _showErrorToast('Please enter a valid amount');
        return;
      }

      // Check allocation limit
      final totalAllocation = int.tryParse(allocationamount.toString()) ?? 0;
      if (totalAllocation < amount) {
        _showErrorToast(
          'Amount exceeds available allocation. Please set a lower amount.',
        );
        return;
      }

      // Show loading
      dialogBox.waiting(context, 'Creating allocation...');

      // Set timeout
      timer = Timer(const Duration(seconds: 25), () {
        _handleTimeout();
      });

      // Get token
      final token = await _getToken();
      if (token == null) {
        timer.cancel();
        _dismissLoading();
        _showErrorToast('Authentication failed. Please login again.');
        return;
      }

      // Determine label
      newlabell = val == 'Others' ? newlabel.text.trim() : val;
      if (newlabell.isEmpty) {
        timer.cancel();
        _dismissLoading();
        _showErrorToast('Please enter a label');
        return;
      }

      // Calculate new budget
      final newBudget = totalAllocation - amount;

      // Make API calls
      final success = await _makeApiCalls(token, newBudget, amount);

      timer.cancel();
      _dismissLoading();

      if (success && mounted) {
        _showSuccessToast('Education Allocation has been created');
        _navigateToSummary();
      }
    } catch (e) {
      print('Submission error: $e');
      if (timer.isActive) timer.cancel();
      _dismissLoading();
      _showErrorToast('Failed to create allocation. Please try again.');
    }
  }

  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('tokenDB');
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  Future<bool> _makeApiCalls(String token, int newBudget, int amount) async {
    try {
      // 1. Update budget
      final budgetSuccess = await _updateBudget(token, newBudget);
      if (!budgetSuccess) return false;

      // 2. Create allocation
      final allocationSuccess = await _createAllocation(token, amount);
      if (!allocationSuccess) return false;

      // 3. Fetch updated data
      return await _fetchUpdatedData(token);
    } catch (e) {
      print('API calls error: $e');
      return false;
    }
  }

  Future<bool> _updateBudget(String token, int newBudget) async {
    try {
      final url = Uri.parse("$baseUrl/app/seed/store/budget");
      final response = await http
          .post(
            url,
            body: {'budget': newBudget.toString()},
            headers: {
              "Authorization": 'Bearer $token',
              "Accept": "application/json",
              "Content-Type": "application/x-www-form-urlencoded",
            },
            encoding: Encoding.getByName("utf-8"),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Budget update timeout'),
          );

      if (response.statusCode != 200) {
        print('Budget update failed: ${response.statusCode}');
        return false;
      }
      return true;
    } catch (e) {
      print('Budget update error: $e');
      return false;
    }
  }

  Future<bool> _createAllocation(String token, int amount) async {
    try {
      final url = Uri.parse("$baseUrl/app/seed/allocate/budget");
      print('label:$newlabell');
      print('amount:$amount');

      final response = await http
          .post(
            url,
            body: {
              'category': 'education',
              'label': newlabell,
              'amount': amount.toString(),
              'note': savingNote.text.trim() ?? '',
            },
            headers: {
              "Authorization": 'Bearer $token',
              "Accept": "application/json",
              "Content-Type": "application/x-www-form-urlencoded",
            },
            encoding: Encoding.getByName("utf-8"),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw TimeoutException('Allocation creation timeout'),
          );

      // Parse the response body
      final responseBody = jsonDecode(response.body);

      if (response.statusCode != 200) {
        print('Allocation creation failed: ${response.statusCode}');
        print('Response body: $responseBody');

        // Check if there's an error message in the response
        String errorMessage = 'Failed to create allocation';

        if (responseBody['errors'] != null) {
          // Handle nested JSON error string
          if (responseBody['errors'] is String) {
            try {
              final errors = jsonDecode(responseBody['errors']);
              if (errors['amount'] != null && errors['amount'] is List) {
                errorMessage = errors['amount'][0];
              }
            } catch (e) {
              // If it's not valid JSON, use the string as is
              errorMessage = responseBody['errors'];
            }
          } else if (responseBody['errors'] is Map) {
            // Handle direct error map
            final errors = responseBody['errors'];
            if (errors['amount'] != null && errors['amount'] is List) {
              errorMessage = errors['amount'][0];
            }
          }
        } else if (responseBody['message'] != null) {
          errorMessage = responseBody['message'];
        }

        // Show error toast
        if (mounted) {
          _showErrorToast(errorMessage);
        }

        return false;
      }

      return true;
    } catch (e) {
      print('Allocation creation error: $e');
      if (mounted) {
        _showErrorToast('Network error. Please try again.');
      }
      return false;
    }
  }

  Future<bool> _fetchUpdatedData(String token) async {
    try {
      // Fetch seed data
      final seedUrl = Uri.parse("$baseUrl/app/seed/");
      final seedResponse = await http
          .get(seedUrl, headers: {"Authorization": 'Bearer $token'})
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Seed data timeout'),
          );

      if (seedResponse.statusCode == 200) {
        final seedBody = jsonDecode(seedResponse.body);
        context.read<Providers>().setSeeData(seedBody);
      }

      // Fetch education allocations
      final eduUrl = Uri.parse(
        "$baseUrl/app/seed/allocate/budget?category=education",
      );
      final eduResponse = await http
          .get(eduUrl, headers: {"Authorization": 'Bearer $token'})
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Education data timeout'),
          );

      if (eduResponse.statusCode == 200) {
        final educationBody = jsonDecode(eduResponse.body);
        final data = educationBody["data"]?['budget_allocations'];

        if (data != null) {
          List res = data;
          setState(() {
            _data = res.map((item) => SavingAllserver.fromJson(item)).toList();
          });
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Fetch data error: $e');
      return false;
    }
  }

  void _handleTimeout() {
    if (mounted) {
      _dismissLoading();
      dialogBox.information(
        context,
        'Status',
        'Service timed out. Please check your internet connection and try again.',
      );
    }
  }

  void _dismissLoading() {
    if (mounted) {
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (e) {
        // Dialog might already be dismissed
      }
    }
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      backgroundColor: Colors.red,
      textColor: Colors.white,
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      backgroundColor: const Color(0xffE6C069),
      textColor: Colors.white,
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _navigateToSummary() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EducationAllocationSummary(data: _data),
        ),
      );
    }
  }
}
