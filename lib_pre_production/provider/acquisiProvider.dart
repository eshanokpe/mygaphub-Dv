import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:GapHub/models/propertyDetailModel.dart';
import 'package:GapHub/models/propertyModel.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AcquisiProvider with ChangeNotifier {
  PropertyDetailModel? _propertyDetail;
  PropertyDetailModel? get propertyDetail => _propertyDetail;

  List<PropertyModel> _properties = [];
  bool _isLoading = true;

  List<PropertyModel> get properties =>
      _filteredProperties.isNotEmpty ? _filteredProperties : _properties;

  bool get isLoading => _isLoading;

  List<PropertyModel> _filteredProperties = [];
  String _selectedCategory = 'Any';
  String _selectedBedRooms = 'Any';
  String _selectedBathRooms = 'Any';
  String _selectedPropertyType = 'Any';
  double _minPrice = 100.0;
  double _maxPrice = 100000.0;

  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;

  String _searchKeyword = '';
  String get keyword => _searchKeyword;

  void updateKeyword(String newKeyword) {
    _searchKeyword = newKeyword;
    notifyListeners();
  }

  void clearKeyword() {
    _searchKeyword = '';
    notifyListeners();
  }

  final List<String> _items = ['Any', 'REAP UK', 'REAP US', 'REAP NIGERIA'];
  final List<bool> _isSelected = [true, false, false, false];
  final List<String> _bedRoom = ['Any', '1', '2', '3', '4', '5'];
  final List<bool> _isSelectedBedRoom = [
    true,
    false,
    false,
    false,
    false,
    false,
  ];
  List<String> bathRoom = ['Any', '1', '2', '3', '4', '5'];
  final List<bool> _isSelectedBathRoom = [
    true,
    false,
    false,
    false,
    false,
    false,
  ];
  final List<String> _propertyType = [
    'Any',
    'House',
    'Flat',
    'Bungalow',
    'Duplex',
    // 'Studio',
  ];
  final List<bool> _isSelectedPropertyType = [
    true,
    false,
    false,
    false,
    false,
    // false
  ];

  List<String> get items => _items;
  List<bool> get isSelected => _isSelected;
  List<String> get bedRoom => _bedRoom;
  List<bool> get isSelectedBedRoom => _isSelectedBedRoom;
  List<bool> get isSelectedBathRoom => _isSelectedBathRoom;
  List<String> get propertyType => _propertyType;
  List<bool> get isSelectedPropertyType => _isSelectedPropertyType;

  String get selectedCategory => _selectedCategory;
  String get selectedBedrooms => _selectedBedRooms;
  String get selectedBathrooms => _selectedBathRooms;
  String get selectedProperType => _selectedPropertyType;

  int get filteredPropertiesLength => _filteredProperties.length;
  bool get isEmpty => _filteredProperties.isEmpty;
  bool get isEmptyy => properties.isEmpty;

  Future<void> fetchProperties(String category) async {
    const url = '$assetBaseUrl/propery-listing';
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // print('Response data: $data');

        final List<dynamic> propertyList =
            data['properties_list'] as List<dynamic>;
        final fetchedProperties = propertyList.map<PropertyModel>((property) {
          return PropertyModel.fromJson(property);
        }).toList();
        _properties = fetchedProperties
            .where((property) => property.propertyCountrie == category)
            .toList();

        filterProperties(
          _selectedCategory,
          _selectedPropertyType,
          _selectedBedRooms,
          _selectedBathRooms,
          _minPrice,
          _maxPrice,
          _searchKeyword,
        );
      } else {
        print('Failed to load properties. Status code: ${response.statusCode}');
      }
    } catch (error) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onCategoryChanged(String selectedCategoryFromUI) {
    // Map the UI display string to the actual filter value
    if (selectedCategoryFromUI == 'REAP UK') {
      _selectedCategory = 'UK';
    } else if (selectedCategoryFromUI == 'REAP US') {
      _selectedCategory = 'US';
    } else if (selectedCategoryFromUI == 'REAP NIGERIA') {
      _selectedCategory = 'Nigeria';
    } else if (selectedCategoryFromUI == 'Any') {
      _selectedCategory = 'Any';
    } else {
      // Fallback, though ideally, input is always from _items
      _selectedCategory = 'Any';
    }

    // Update the selection state for UI elements based on the original UI string
    for (int i = 0; i < _items.length; i++) {
      _isSelected[i] = _items[i] == selectedCategoryFromUI;
    }

    filterProperties(
      _selectedCategory,
      _selectedPropertyType,
      _selectedBedRooms,
      _selectedBathRooms,
      _minPrice,
      _maxPrice,
      _searchKeyword,
    );
  }

  void onPropertyType(String selectedPropertyType) {
    _selectedPropertyType = selectedPropertyType;

    // Ensure you're iterating over the correct list length
    for (int i = 0; i < _isSelectedPropertyType.length; i++) {
      _isSelectedPropertyType[i] = _propertyType[i] == selectedPropertyType;
    }
    filterProperties(
      _selectedCategory,
      _selectedPropertyType,
      _selectedBedRooms,
      _selectedBathRooms,
      _minPrice,
      _maxPrice,
      _searchKeyword,
    );
  }

  void onBedroomsChanged(String selectedBedRoom) {
    _selectedBedRooms = selectedBedRoom;
    for (int i = 0; i < _isSelectedBedRoom.length; i++) {
      _isSelectedBedRoom[i] = _bedRoom[i] == selectedBedRoom;
    }
    filterProperties(
      _selectedCategory,
      _selectedPropertyType,
      _selectedBedRooms,
      _selectedBathRooms,
      _minPrice,
      _maxPrice,
      _searchKeyword,
    );
  }

  void onBathroomsChanged(String selectedBathRoom) {
    _selectedBathRooms = selectedBathRoom;
    for (int i = 0; i < _isSelectedBedRoom.length; i++) {
      _isSelectedBathRoom[i] = _bedRoom[i] == selectedBathRoom;
    }
    filterProperties(
      _selectedCategory,
      _selectedPropertyType,
      _selectedBedRooms,
      _selectedBathRooms,
      _minPrice,
      _maxPrice,
      _searchKeyword,
    );
  }

  void onPriceRangeChanged(double minPrice, double maxPrice) {
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    filterProperties(
      _selectedCategory,
      _selectedPropertyType,
      _selectedBedRooms,
      _selectedBathRooms,
      _minPrice,
      _maxPrice,
      _searchKeyword,
    );
  }

  void onSearchAddressChanged(String keyword) {
    _searchKeyword = keyword;
    filterProperties(
      _selectedCategory,
      _selectedPropertyType,
      _selectedBedRooms,
      _selectedBathRooms,
      _minPrice,
      _maxPrice,
      _searchKeyword,
    );
  }

  // List<PropertyModel> get filteredProperties =>
  //     _filteredProperties.isEmpty ? _properties : _filteredProperties;

  List<PropertyModel> get filteredProperties =>
      _filteredProperties.isEmpty ? _filteredProperties : _properties;

  void filterProperties(
    String category,
    String propertyType,
    String bedrooms,
    String bathrooms,
    double minPrice,
    double maxPrice,
    String keyword,
  ) {
    if (_filteredProperties.isNotEmpty) {
      print('_filteredProperties first element: ${_filteredProperties.first}');
    } else {
      print(
        '_filteredProperties is empty at the start of filterProperties method.',
      );
    }
    // Clean the search term
    final searchTerm = keyword.trim().toLowerCase();

    _filteredProperties = _properties.where((property) {
      // Convert all searchable fields to lowercase strings
      final searchableFields = [
        property.propertyAddress.toLowerCase(),
        property.propertyCountrie.toLowerCase(),
        property.propertyName.toLowerCase(),
        property.propertyType.name.toLowerCase(),
        property.noOfBedroom.toString(),
        property.noOfBathroom.toString(),
        property.propertyPrice.toLowerCase(),
        property.propertySaleOptions.toLowerCase(),
      ];

      // Check if any field contains the search term (if term is not empty)
      final hasSearchMatch =
          searchTerm.isEmpty ||
          searchableFields.any((field) => field.contains(searchTerm));

      // Only include properties that match ALL active filters
      return hasSearchMatch &&
          (category == 'Any' || property.propertyCountrie == category) &&
          (propertyType == 'Any' ||
              property.propertyType.name == propertyType) &&
          (bedrooms == 'Any' || property.noOfBedroom.toString() == bedrooms) &&
          (bathrooms == 'Any' ||
              property.noOfBathroom.toString() == bathrooms) &&
          (double.tryParse(
                    property.propertyPrice.replaceAll(RegExp(r'[^0-9.]'), ''),
                  ) ??
                  0) >=
              minPrice &&
          (double.tryParse(
                    property.propertyPrice.replaceAll(RegExp(r'[^0-9.]'), ''),
                  ) ??
                  0) <=
              maxPrice;
    }).toList();

    notifyListeners();
  }

  Future<void> fetchPropertyDetails(int propertyId) async {
    _propertyDetail = null;
    notifyListeners();
    final url = Uri.parse(
      '$assetBaseUrl/propery-details?id=$propertyId',
    ); // Ensure correct URL

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('Fetched property details for ID: $propertyId');
        final dynamic data = jsonDecode(response.body);

        if (data is List && data.isNotEmpty) {
          final Map<String, dynamic> matchingProperty = data.firstWhere(
            (property) => property['property_id'] == propertyId,
            orElse: () => null,
          );

          _propertyDetail = PropertyDetailModel.fromJson(matchingProperty);

          // Handle propertyVideoList separately
          var propertyVideoList = _propertyDetail?.propertyVideoList;

          // Check if propertyVideoList is a bool or a List
          if (propertyVideoList == null || propertyVideoList is bool) {
            print('No videos available for the property.');
          } else if (propertyVideoList is List) {
            print('propertyVideoList: $propertyVideoList');
          } else {
            print('Unexpected propertyVideoList format.');
          }

          notifyListeners();
        } else {
          print(
            'No data found for property ID: $propertyId or data format is incorrect.',
          );
        }
      } else {
        print(
          'Failed to load property details. Status code: ${response.statusCode}',
        );
      }
    } on TimeoutException catch (e) {
      print('Request timed out: $e');
    } on SocketException catch (e) {
      print('Connection error: $e');
    } catch (e) {
      print('An unexpected error occurred: $e');
    }
  }

  final List<int> _favoritePropertyIds = [];

  List<int> get favoritePropertyIds => _favoritePropertyIds;

  Future<void> addToFavorite(int propertyId) async {
    print("propertyId:$propertyId");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    const url = '$baseUrl/app/property/favourite'; // Add favorite endpoint
    final body = jsonEncode({'property_id': propertyId});

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": 'Bearer $token',
        },
        body: body,
      );
      print('response:${response.statusCode}');
      if (response.statusCode == 200) {
        // Add the propertyId to the favorite list if it was successfully added
        if (!_favoritePropertyIds.contains(propertyId)) {
          _favoritePropertyIds.add(propertyId);
          Fluttertoast.showToast(
            backgroundColor: AppColors.blackColor,
            textColor: Colors.white,
            msg: 'Add to Favorite',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
        notifyListeners(); // Notify listeners to update UI
      } else {
        Fluttertoast.showToast(
          backgroundColor: AppColors.blackColor,
          textColor: Colors.white,
          msg: 'Failed to add to favorite',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        throw Exception('Failed to add to favorite');
      }
    } catch (error) {
      print('Error adding to favorite: $error');
    }
  }

  Future<void> removeFromFavorite(int propertyId) async {
    print("propertyId:$propertyId");

    final url =
        '$baseUrl/app/property/favourite/$propertyId'; // Remove favorite endpoint
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": 'Bearer $token',
        },
      );
      print('response:${response.statusCode}');

      if (response.statusCode == 200) {
        // Remove the propertyId from the favorite list if successfully removed
        _favoritePropertyIds.remove(propertyId);
        Fluttertoast.showToast(
          backgroundColor: AppColors.blackColor,
          textColor: Colors.white,
          msg: 'Remove from favorite',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        notifyListeners(); // Notify listeners to update UI
      } else {
        throw Exception('Failed to remove from favorite');
      }
    } catch (error) {
      print('Error removing from favorite: $error');
    }
  }

  // Check if a property is in the favorite list
  bool isPropertyFavorited(int propertyId) {
    return _favoritePropertyIds.contains(propertyId);
  }

  // Non-nullable string fields with default values
  String _selectedCurrency = 'N/A';
  String _savings = '0';
  String _education = '0';
  String _mortgage = '0';
  String _mobility = '0';
  String _expenses = '0';
  String _utility = '0';
  String _debtRepay = '0';
  String _charity = '0';
  String _otherWages = '0';
  String _rainyDays = '0';
  // String _roce = "0";
  // String _investment = "0";

  // Controllers for fields needing user input
  final TextEditingController _roce = TextEditingController(text: "0");
  final TextEditingController _investment = TextEditingController(text: "0");

  // Public getters
  String get selectedCurrency => _selectedCurrency;
  String get savings => _savings;
  String get education => _education;
  String get mortgage => _mortgage;
  String get mobility => _mobility;
  String get expenses => _expenses;
  String get utility => _utility;
  String get debtRepay => _debtRepay;
  String get charity => _charity;
  String get otherWages => _otherWages;
  String get rainyDays => _rainyDays;
  // String get roce => _roce;
  // String get investment => _investment;
  TextEditingController get roce => _roce;
  TextEditingController get investment => _investment;

  Future<void> getBudget() async {
    final url = Uri.parse("$baseUrl/app/calculator");

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      if (token == null) {
        throw Exception("No token found in SharedPreferences");
      }

      final response = await http.get(
        url,
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        _handleResponse(jsonDecode(response.body)["data"]);
      } else {
        _handleError(response);
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  void _handleResponse(Map<String, dynamic> dataResponse) {
    _selectedCurrency = dataResponse['currency'] ?? 'N/A';
    _savings = dataResponse['periodic_savings']?.toString() ?? '0';
    _education = dataResponse['education']?.toString() ?? '0';
    _mortgage = dataResponse['mortgage']?.toString() ?? '0';
    _mobility = dataResponse['mobility']?.toString() ?? '0';
    _expenses = dataResponse['expenses']?.toString() ?? '0';
    _utility = dataResponse['utility']?.toString() ?? '0';
    _debtRepay = dataResponse['dept_repay']?.toString() ?? '0';
    _charity = dataResponse['charity']?.toString() ?? '0';
    _roce.text = dataResponse['roce']?.toString() ?? '0';
    _investment.text = dataResponse['investment']?.toString() ?? '0';

    // Update text fields
    _otherWages = dataResponse['other_income']?.toString() ?? '0';
    _rainyDays = dataResponse['extra_save']?.toString() ?? '0';

    notifyListeners(); // Notify listeners to update UI
  }

  void _handleError(http.Response response) {
    final Map<String, dynamic> errorData = jsonDecode(response.body);
    print('Error: ${response.statusCode}');
    print('Response Body: ${errorData['errors']}');
  }

  int? _income;
  int? _timeFinancialChart;
  String? _timeFinancial;
  num? _seedCost;
  num? _expenditure;
  num? _shortfalls;
  num? _average;
  num? _suggestedInvestment;
  Map<String, dynamic> _dataResponse = {};

  Map<String, dynamic> get dataResponse => _dataResponse;
  int? get income => _income;
  int? get timeFinancialChart => _timeFinancialChart;
  String? get timeFinancial => _timeFinancial;
  num? get seedCost => _seedCost;
  num? get expenditure => _expenditure;
  num? get shortfalls => _shortfalls;
  num? get average => _average;
  num? get suggestedInvestment => _suggestedInvestment;

  Future<void> fetchFinancialRecommendation() async {
    final url = Uri.parse('$baseUrl/app/financial/recommendations');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');
      if (token == null) {
        throw Exception("No token found in SharedPreferences");
      }
      final http.Response response = await http.get(
        url,
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );
      print('Error11: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _dataResponse = data["data"];

        print('Recommendations Data: $_dataResponse');
        // String currency = dataResponse['currency'];
        // context.read<Providers>().setCalculator(dataResponse);

        _income = _dataResponse['income'];
        _seedCost = _dataResponse['seed_cost'];
        _expenditure = _dataResponse['expenditure'];
        _shortfalls = _dataResponse['shortfall'];
        _average = _dataResponse['average'];
        _suggestedInvestment = _dataResponse['suggested_investment'];
        _timeFinancialChart = _dataResponse['time_finiancial_chart'] ?? '';
        _timeFinancial = _dataResponse['time_finiancial'] ?? '';
        notifyListeners();
      } else {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('Error: ${response.statusCode}');
        print('Response Body: ${data['errors']}');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }
}
