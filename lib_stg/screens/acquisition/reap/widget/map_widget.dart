import 'package:GapHub/models/propertyDetailModel.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../reapResult/viewAll.dart';

class MapWidget extends StatefulWidget {
  final LatLng currentLocation;
  final PropertyDetailModel propertyDetail;

  const MapWidget({
    super.key,
    required this.currentLocation,
    required this.propertyDetail,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late GoogleMapController _mapController;
  bool _isMapCreated = false;

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    final CameraPosition initialCameraPosition = CameraPosition(
      target: widget.currentLocation,
      zoom: 16, // Reduced for better performance
      tilt: 30, // Reduced for better performance
      bearing: 0,
    );

    return Stack(
      children: [
        SizedBox(height: width * 0.01),
        SizedBox(
          height: height * 0.30,
          width: width,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            child: GoogleMap(
              mapType: MapType
                  .normal, // Changed from hybrid for better iOS performance
              initialCameraPosition: initialCameraPosition,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _initMapStyle();
                setState(() => _isMapCreated = true);
              },
              myLocationEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
            ),
          ),
        ),
        if (_isMapCreated)
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  navigateWithSlideTransition(
                    context: context,
                    destinationScreen: ViewAll(
                      propertyDetail: widget.propertyDetail,
                      initialTabIndex: 2,
                      currentLocation: widget.currentLocation,
                    ),
                    transitionDuration: const Duration(milliseconds: 200),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.05,
                    vertical: height * 0.015,
                  ),
                  textStyle: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: width * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/icons/marker.png'),
                    SizedBox(width: width * 0.01),
                    const Text('Open Map'),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _initMapStyle() async {
    if (Platform.isIOS) {
      // Small delay for iOS initialization
      await Future.delayed(const Duration(milliseconds: 300));

      try {
        await _mapController.setMapStyle('''[
          {
            "featureType": "all",
            "elementType": "labels",
            "stylers": [{ "visibility": "on" }]
          }
        ]''');
      } catch (e) {
        debugPrint('Error setting map style: $e');
      }
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
