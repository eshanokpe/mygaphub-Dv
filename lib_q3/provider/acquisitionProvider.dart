import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:GapHub/models/propertyDetailModel.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/models/propertyModel.dart';

class AcquisitionProvider with ChangeNotifier {
  PropertyDetailModel? _propertyDetail;
  PropertyDetailModel? get propertyDetail => _propertyDetail;

  List<PropertyModel> _properties = [];
  bool _isLoading = true;

  List<PropertyModel> get properties => _properties;
  bool get isLoading => _isLoading;

  List<PropertyModel> get filteredProperties => _filteredProperties ?? [];

  List<PropertyModel> _filteredProperties = [];
  String _selectedCategory = 'Any';
  String _selectedBedRooms = 'Any';
  String _selectedBathRooms = 'Any';
  String _selectedPropertyType = 'Any';
  double _minPrice = 100.0;
  double _maxPrice = 100000.0;

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

        _properties = propertyList.map<PropertyModel>((property) {
          return PropertyModel.fromJson(property);
        }).toList();
        // Apply initial filtering
        _applyInitialFilters(category);
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

  void _applyInitialFilters(String category) {
    try {
      filterProperties(category, 'Any', 'Any', 'Any', _minPrice, _maxPrice, '');
      debugPrint(
        'Initial filtering applied with ${_filteredProperties.length} results',
      );
    } catch (e) {
      debugPrint('Filter error: $e');
      _filteredProperties = _properties; // Fallback to all properties
    }
  }

  void onCategoryChanged(String selectedCategory) {
    _selectedCategory = selectedCategory;
    for (int i = 0; i < _isSelected.length; i++) {
      _isSelected[i] = _items[i] == selectedCategory;
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

  void filterProperties(
    String category,
    String propertyType,
    String bedrooms,
    String bathrooms,
    double minPrice,
    double maxPrice,
    String keyword,
  ) {
    // Clean and prepare the search term
    final searchTerm = keyword.trim().toLowerCase();

    _filteredProperties = _properties.where((property) {
      // Safe price parsing
      final price =
          double.tryParse(
            property.propertyPrice.replaceAll(RegExp(r'[^0-9.]'), ''),
          ) ??
          0.0;

      // Category filter
      final categoryMatch =
          category == 'Any' ||
          (category.startsWith('REAP')
              ? property.propertyCountrie == category.replaceFirst('REAP ', '')
              : property.propertyCountrie == category);

      // Property type filter
      final propertyTypeMatch =
          propertyType == 'Any' || property.propertyType.name == propertyType;

      // Bedroom filter
      final bedroomMatch =
          bedrooms == 'Any' || property.noOfBedroom.toString() == bedrooms;

      // Bathroom filter
      final bathroomMatch =
          bathrooms == 'Any' || property.noOfBathroom.toString() == bathrooms;

      // Price filter
      final priceMatch = price >= minPrice && price <= maxPrice;

      // Search term filter - only apply if there's a search term
      final searchMatch =
          searchTerm.isEmpty ||
          [
            property.propertyAddress.toLowerCase(),
            property.propertyCountrie.toLowerCase(),
            property.propertyName.toLowerCase(),
            property.propertyType.name.toLowerCase(),
            property.noOfBedroom.toString(),
            property.noOfBathroom.toString(),
            property.propertyPrice,
            property.propertySaleOptions.toLowerCase(),
          ].any((field) => field.contains(searchTerm));

      return categoryMatch &&
          propertyTypeMatch &&
          bedroomMatch &&
          bathroomMatch &&
          priceMatch &&
          searchMatch;
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
}
