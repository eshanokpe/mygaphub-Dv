import 'package:GapHub/screens/homepage/financial_intelligence_hub/video_display_page.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:GapHub/utils/extensions.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:cached_network_image/cached_network_image.dart';

class QuickStartGuide extends StatefulWidget {
  const QuickStartGuide({super.key});

  @override
  _QuickStartGuideState createState() => _QuickStartGuideState();
}

class _QuickStartGuideState extends State<QuickStartGuide> {
  List supportData = [];

  @override
  void didChangeDependencies() {
    final newSupportData = context.watch<Providers>().supportData;
    if (newSupportData != supportData) {
      setState(() {
        supportData = newSupportData;
      });
    }
    super.didChangeDependencies();
  }

  String _getThumbnailUrl(String videoUrl) {
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
    return 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
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
        padding: EdgeInsets.symmetric(horizontal: width * .03),
        child: supportData.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: supportData.length,
                itemBuilder: (context, index) {
                  final item = supportData[index];
                  final videoLink = item["video_link"].toString();
                  final title = item["title"].toString();
                  final description = item["description"] ?? 'null';
                  final thumbnailUrl = _getThumbnailUrl(videoLink);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              VideoDisplayPage(videoUrl: videoLink),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: context.width(.04),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Stack(
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: thumbnailUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          color: Colors.grey,
                                          child: const Center(
                                            child: Icon(Icons.error),
                                          ),
                                        ),
                                  ),
                                  Center(
                                    child: Icon(
                                      Icons.play_circle_filled,
                                      size: 50,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: context.width(.02)),
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: width * .04,
                              fontFamily: 'Nunito',
                            ),
                          ),
                          Text(
                            description == 'null' ? ' ' : description,
                            style: TextStyle(
                              fontSize: width * .035,
                              fontFamily: 'Nunito',
                              color: AppColors.grayColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
