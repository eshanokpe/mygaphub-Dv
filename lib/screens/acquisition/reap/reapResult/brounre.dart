import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:GapHub/models/propertyDetailModel.dart';

class Brochure extends StatelessWidget {
  final PropertyDetailModel propertyDetail;

  const Brochure({super.key, required this.propertyDetail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => _launchBrochure(context, propertyDetail),
          child: const Text('Open Brochure'),
        ),
      ),
    );
  }

  Future<void> _launchBrochure(
    BuildContext context,
    PropertyDetailModel propertyDetail,
  ) async {
    // Check if the brochure is available
    if (propertyDetail.brochure.isEmpty) {
      // Show a message that no document is uploaded
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No brochure document uploaded.')),
      );
      return;
    }

    // Show loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    final Uri url = Uri.parse(propertyDetail.brochure);

    try {
      // Try to launch the brochure URL
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch brochure URL.')),
        );
      }
    } finally {
      // Dismiss the loading spinner after the task is completed
      Navigator.of(context).pop();
    }
  }
}
