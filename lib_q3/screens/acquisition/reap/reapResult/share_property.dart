import 'dart:io'; // For File
import 'package:GapHub/models/propertyDetailModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:path_provider/path_provider.dart'; // For temporary directory
import 'package:share_plus/share_plus.dart';

class SharedProperty extends StatefulWidget {
  final PropertyDetailModel propertyDetail;
  final String currency; // Added currency

  const SharedProperty({
    super.key,
    required this.propertyDetail,
    required this.currency, // Added currency
  });

  @override
  State<SharedProperty> createState() => _SharedPropertyState();
}

class _SharedPropertyState extends State<SharedProperty> {
  bool _isSharing = false; // State variable for loading indicator

  // Helper function to download and save the file temporarily
  Future<String?> _downloadAndSaveFile(String url, String fileName) async {
    if (url.isEmpty) return null;
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$fileName';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        print('Error downloading file: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading image: ${response.statusCode}'),
          ),
        );
        return null;
      }
    } catch (e) {
      print('Exception during file download: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not prepare image for sharing.')),
      );
      return null;
    }
  }

  void _sharePropertyDetails(BuildContext context) async {
    if (_isSharing) return; // Prevent multiple share attempts

    setState(() {
      _isSharing = true;
    });

    // Create the share text with property details
    final String propertyName =
        widget.propertyDetail.propertyName ?? 'Unnamed Property';
    final String propertyAddress =
        widget.propertyDetail.propertyAddress ?? 'Address not available';
    final String propertyPrice =
        'Price: ${widget.currency}${widget.propertyDetail.pricePerMonth}';
    // Consider adding a deep link to your app or property listing if available
    // final String appLink = "https://yourapp.com/property/${widget.propertyDetail.propertyId}";

    final String shareText =
        'Check out this property on GapHub!\n\n'
        '🏡 *$propertyName*\n'
        '📍 Address: $propertyAddress\n'
        '💰 $propertyPrice\n\n'
        'Find more details in the GapHub app!'; // Or add appLink here

    String? localImagePath;
    if (widget.propertyDetail.propertyFeaturedImage.isNotEmpty) {
      String fileExtension = widget.propertyDetail.propertyFeaturedImage
          .split('.')
          .last;
      // Basic validation for common image extensions
      if (![
        'jpg',
        'jpeg',
        'png',
        'gif',
        'webp',
      ].contains(fileExtension.toLowerCase())) {
        fileExtension =
            'jpg'; // Default to jpg if extension is unusual or missing
      }
      String imageName =
          'share_image_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      localImagePath = await _downloadAndSaveFile(
        widget.propertyDetail.propertyFeaturedImage,
        imageName,
      );
    }

    try {
      if (localImagePath != null) {
        final xFile = XFile(localImagePath);
        await Share.shareXFiles(
          [xFile],
          text: shareText,
          subject:
              'Property Recommendation: $propertyName', // Optional: for email subjects
        );
      } else {
        // Fallback to sharing text only if image is not available or failed to download
        await Share.share(
          shareText,
          subject: 'Property Recommendation: $propertyName',
        );
        if (widget.propertyDetail.propertyFeaturedImage.isNotEmpty) {
          // Inform user if image was intended but failed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image could not be shared. Sharing details only.'),
            ),
          );
        }
      }
    } catch (e) {
      // Handle any errors
      print('Error sharing property: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while sharing. Please try again.'),
        ),
      );
    } finally {
      // Clean up the downloaded file
      if (localImagePath != null) {
        try {
          final file = File(localImagePath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          print('Error deleting temporary share file: $e');
        }
      }
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _isSharing
          ? null
          : () => _sharePropertyDetails(context), // Disable tap during sharing
      child: _isSharing
          ? Container(
              // Show a loading indicator
              width: 24.w,
              height: 24.w, // Maintain size
              padding: EdgeInsets.all(3.w), // Adjust padding for visual balance
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: Theme.of(context).colorScheme.primary, // Use theme color
              ),
            )
          : Image.asset(
              'assets/images/acquisition/share.png',
              width: 24.w,
              height: 24.w, // Ensure height is also constrained
              errorBuilder: (context, error, stackTrace) {
                // Add error builder for local asset
                return Icon(
                  Icons.share,
                  size: 24.w,
                  color: Colors.grey[600],
                ); // Fallback icon
              },
            ),
    );
  }
}
