import 'package:GapHub/provider/marketOpportunitiesProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MarketPlaceList extends StatefulWidget {
  const MarketPlaceList({super.key});

  @override
  _MarketPlaceListState createState() => _MarketPlaceListState();
}

class _MarketPlaceListState extends State<MarketPlaceList> {
  @override
  void initState() {
    super.initState();
    // Fetch data on load
    Provider.of<MarketOpportunitiesProvider>(
      context,
      listen: false,
    ).fetchMarketOpportunities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Market Opportunities")),
      body: Consumer<MarketOpportunitiesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.marketOpportunities.isEmpty) {
            return const Center(
              child: Text("No market opportunities available"),
            );
          } else {
            return ListView.builder(
              itemCount: provider.marketOpportunities.length,
              itemBuilder: (context, index) {
                final item = provider.marketOpportunities[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: Image.network(
                      item.bannerUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item.title),
                    subtitle: Text(item.buttonText),
                    onTap: () {
                      // Optional: Open link or detail page
                      print("Opening: ${item.destinationLink}");
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
