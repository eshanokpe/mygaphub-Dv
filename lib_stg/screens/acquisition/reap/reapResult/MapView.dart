import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  static const LatLng currentLocation = LatLng(42.4051, -83.1783);
  GoogleMapController? _mapController;
  MapType _currentMapType = MapType.normal;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // Add a marker at the current location
    _markers.add(
      const Marker(
        markerId: MarkerId('currentLocation'),
        position: currentLocation,
        infoWindow: InfoWindow(title: 'Current Location'),
        icon: BitmapDescriptor.defaultMarker,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : _currentMapType == MapType.satellite
          ? MapType.terrain
          : _currentMapType == MapType.terrain
          ? MapType.hybrid
          : MapType.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    const CameraPosition initialPosition = CameraPosition(
      target: currentLocation,
      zoom: 18,
    );

    return SafeArea(
      child: Stack(
        children: [
          GoogleMap(
            mapType: _currentMapType,
            initialCameraPosition: initialPosition,
            onMapCreated: _onMapCreated,
            markers: _markers,
            myLocationEnabled: true,
            zoomControlsEnabled: false, // Disabling default zoom controls
          ),
          // Zoom Controls
          Positioned(
            top: 30,
            right: 10,
            child: Container(
              width: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, size: 16),
                    color: const Color(0xffc4c4c4),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      _mapController?.animateCamera(CameraUpdate.zoomIn());
                    },
                  ),
                  const Divider(
                    color: Color(0xffc4c4c4),
                    thickness: 0.5,
                    height: 1,
                    indent: 3,
                    endIndent: 3,
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove, size: 16),
                    color: const Color(0xffc4c4c4),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      _mapController?.animateCamera(CameraUpdate.zoomOut());
                    },
                  ),
                ],
              ),
            ),
          ),
          // Map Type Toggle Button
          Positioned(
            top: 150,
            right: 10,
            child: FloatingActionButton(
              onPressed: _toggleMapType,
              materialTapTargetSize: MaterialTapTargetSize.padded,
              backgroundColor: Colors.red,
              mini: true,
              child: const Icon(Icons.map, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
