import 'dart:async';
import 'dart:convert';

import 'package:GapHub/screens/acquisition/reap/ReapReserve.dart';
import 'package:GapHub/screens/acquisition/reap/reapdetails.dart';
import 'package:GapHub/utils/connectTo.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:share/share.dart';
import 'package:http/http.dart' as http;
import 'ganp/ganpdetails.dart';

class FavouritesPage extends StatelessWidget {
  const FavouritesPage({super.key});

  final tabs = const [
    Tab(text: 'REAP'),
    // Tab(text: 'GANP'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Favourite Assets",
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          centerTitle: true,
        ),
        body: const SafeArea(child: ReapFavourites()),
      ),
    );
  }
}

class ReapFavourites extends StatefulWidget {
  const ReapFavourites({super.key});

  @override
  _ReapFavouritesState createState() => _ReapFavouritesState();
}

class _ReapFavouritesState extends State<ReapFavourites> {
  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<Providers>().favorites;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;
    final height = isPortrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = isPortrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Scaffold(
      body: favorites.isEmpty
          ? _buildEmptyState(height, width)
          : _buildFavoritesList(height, width, favorites),
    );
  }

  Widget _buildEmptyState(double height, double width) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 60, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            'No favorite properties yet',
            style: TextStyle(
              fontSize: width * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tap the heart icon on properties to add them here',
            style: TextStyle(fontSize: width * 0.035, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(double height, double width, List favorites) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        vertical: height * 0.02,
        horizontal: width * 0.03,
      ),
      itemCount: favorites.length,
      itemBuilder: (ctx, index) {
        final property = favorites[index];
        final meta = property['meta'];
        return _FavoriteItem(
          property: property,
          meta: meta,
          height: height,
          width: width,
          onRemove: () => _removeFavorite(context, property['id']),
        );
      },
    );
  }

  Future<void> _removeFavorite(BuildContext context, String propertyId) async {
    EasyLoading.show(status: 'Removing...', dismissOnTap: false);

    try {
      final url = Uri.parse(
        "$baseUrl/app/acquisition/favourite/$propertyId?acquisition=retyanshamdaahgs_rmzojishjbdx&signature=ahgfhagbhgsbhgsbyuhjwgs65wytgv7wystdg6tygfvdtydgvgyhdnxngb",
      );

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      final response = await http
          .get(url, headers: {"Authorization": 'Bearer $token'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        Provider.of<Providers>(
          context,
          listen: false,
        ).setFavorites(body['assets']);
        Fluttertoast.showToast(msg: "Removed from favorites");
      } else {
        Fluttertoast.showToast(msg: "Failed to remove");
      }
    } on TimeoutException {
      Fluttertoast.showToast(msg: "Request timed out");
    } catch (e) {
      Fluttertoast.showToast(msg: "Error occurred");
    } finally {
      EasyLoading.dismiss();
    }
  }
}

class _FavoriteItem extends StatelessWidget {
  final dynamic property;
  final dynamic meta;
  final double height;
  final double width;
  final VoidCallback onRemove;

  const _FavoriteItem({
    required this.property,
    required this.meta,
    required this.height,
    required this.width,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.white,
      margin: EdgeInsets.only(bottom: height * 0.02),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageGallery(context),
          Padding(
            padding: EdgeInsets.all(width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPropertyHeader(),
                SizedBox(height: height * 0.01),
                _buildLocationText(),
                SizedBox(height: height * 0.02),
                _buildPriceInfo(),
                SizedBox(height: height * 0.02),
                _buildPropertyDetails(),
                SizedBox(height: height * 0.02),
                // _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(BuildContext context) {
    final featuredImage = meta['property_featured_image'];
    final galleryImages = meta['property_gallery_images'] ?? [];
    final allImages = [
      featuredImage,
      ...galleryImages,
    ].where((img) => img != null).toList();

    return Stack(
      children: [
        SizedBox(
          height: height * 0.25,
          width: double.infinity,
          child: PageView.builder(
            itemCount: allImages.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: CachedNetworkImage(
                  imageUrl: allImages[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.home),
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.favorite, color: Colors.red, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            meta['property_name'] ?? 'No Name',
            style: TextStyle(
              fontSize: width * 0.055,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            meta['property_type']['name'] ?? 'Property',
            style: TextStyle(fontSize: width * 0.035, color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationText() {
    return Row(
      children: [
        const Icon(Icons.location_on, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '${meta['property_address']}, ${meta['property_city']}, ${meta['property_postcode']}',
            style: TextStyle(fontSize: width * 0.04, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Purchase Price',
          style: TextStyle(fontSize: width * 0.04, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          '£${meta['property_total_price']}',
          style: TextStyle(
            fontSize: width * 0.06,
            fontWeight: FontWeight.bold,
            // color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoColumn('Monthly Rent', '£${meta['monthly_income']}'),
            _buildInfoColumn('Gross ROI', '${meta['gross_roi']}%'),
            _buildInfoColumn('Net ROI', '${meta['net_roi']}%'),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: width * 0.035, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          _formatWithCommas(value),
          style: TextStyle(fontSize: width * 0.04, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatWithCommas(String value) {
    try {
      final doubleValue = double.parse(value.replaceAll(RegExp(r'[^\d.]'), ''));
      final formatted = doubleValue.toStringAsFixed(2);
      return formatted.replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (Match m) => ',',
      );
    } catch (e) {
      return value; // fallback if
    }
  }

  Widget _buildPropertyDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Property Details',
          style: TextStyle(
            fontSize: width * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDetailItem(Icons.king_bed, '${meta['no_of_bedroom']} Beds'),
            _buildDetailItem(Icons.bathtub, '${meta['no_of_bathroom']} Baths'),
            _buildDetailItem(
              Icons.zoom_out_map,
              meta['property_area'] ?? 'N/A',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Description',
          style: TextStyle(
            fontSize: width * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          meta['property_content'] ?? 'No description available',
          style: TextStyle(fontSize: width * 0.04, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.remove_red_eye, size: 20),
            label: const Text('View Details'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => Reapdetails(property),
              //   ),
              // );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
            label: const Text('Remove', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: const BorderSide(color: Colors.red),
            ),
            onPressed: onRemove,
          ),
        ),
      ],
    );
  }
}
