import 'package:GapHub/models/FinancialHubModel.dart';
import 'package:GapHub/provider/marketOpportunitiesProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'video_display_page.dart';

class FinancialIntelligenceHub extends StatefulWidget {
  const FinancialIntelligenceHub({super.key});
 
  @override
  _FinancialIntelligenceHubState createState() =>
      _FinancialIntelligenceHubState();
}

class _FinancialIntelligenceHubState extends State<FinancialIntelligenceHub> {
  @override
  void initState() {
    super.initState();
    Provider.of<MarketOpportunitiesProvider>(context, listen: false)
        .fetchFinancialIntelligenceHub();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Financial Intelligence Hub',
          style: TextStyle(fontSize: width * .035, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * .03, vertical: 5),
        child: Consumer<MarketOpportunitiesProvider>(
          builder: (context, provider, _) {
            if (provider.financialHubModel.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return SizedBox(
              child: ListView.builder(
                itemCount: provider.financialHubModel.length,
                itemBuilder: (context, index) {
                  final financialHub = provider.financialHubModel[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _buildCard(
                      context,
                      financialHub,
                      width,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    FinancialHubModel financialHub,
    double width,
  ) {
    return GestureDetector(
      onTap: () {
       
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoDisplayPage(
              videoUrl: financialHub.videoLink,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: financialHub.bannerUrl,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(height: 120, color: Colors.grey.shade200),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                    const Positioned(
                      bottom: 10,
                      right: 10,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 16,
                        child: Icon(Icons.play_arrow, size: 18),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        financialHub.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ], 
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        financialHub.category,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
