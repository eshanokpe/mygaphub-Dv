import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'braidItem/portquestions.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';

import 'widget/asset_rowWithTap.dart';

class AssetClasses extends StatelessWidget {
  final List<String> data;
  List assetTypeList = [];

  AssetClasses(this.data, {super.key});
  @override
  Widget build(BuildContext context) {
    List<dynamic> assetTypeInfos = context.read<Providers>().assetAcquisition;

    for (var item in assetTypeInfos) {
      assetTypeList.add(item.toMap());
    }
    List<String> titles = [
      "Business Assets",
      "Appreciating Assets",
      "Risk Assets",
    ];
    List<String> img = [
      "assets/images/business.png",
      "assets/images/appreciating.png",
      "assets/images/risk_asset.png",
    ];

    List<String> subtitles = [
      "Buy an existing business currently generating revenue. An asset that can run without your physical presence.",
      "Both architecture and agriculture depend heavily on land to implement their solutions, offering profitable opportunities in either field.",
      "Explore the world of stocks and share. Many retirement plans in the world today are based on this vehicle",
    ];

    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    List<Widget> images = [
      Image.asset('assets/images/depreciating.png', height: height * .13),
    ];
    void dropdown(classe) {
      showDialog(context: context, builder: (context) => Select(data, classe));
    }

    return Scaffold(
      bottomNavigationBar: const BottomNav(3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Portfolio Management',
          style: TextStyle(
            fontSize: width * .045,
            color: const Color(0xff808080),
            fontWeight: FontWeight.w600,
            fontFamily: 'Nunito',
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              vertical: height * .02,
              horizontal: 20,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Asset Classes',
                      style: TextStyle(
                        fontSize: width * .05,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * .01),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Tap on the asset class you will like to add this asset to",
                        style: TextStyle(
                          fontSize: width * .040,
                          color: AppColors.grayColor,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * .02),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemCount: titles.length,
                  itemBuilder: (context, index) => InkWell(
                    onTap: () {
                      _showBottomSheet(
                        context,
                        data,
                        titles[index].toLowerCase(),
                      );
                      // dropdown(titles[index].toLowerCase());
                    },
                    child: Padding(
                      padding: EdgeInsets.only(bottom: height * .01),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        child: Container(
                          // padding: const EdgeInsets.all(16),
                          height: height * .20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                assetTypeList[index]['photo'], // Cached network image
                              ),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.8),
                                BlendMode.darken,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                      top: 10,
                                    ),
                                    child: Container(
                                      width: 45,
                                      height: 45,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: Image.asset(
                                        img[index],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: height * .005),
                              Row(
                                children: [
                                  SizedBox(width: width * .02),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          titles[index],
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            color: Colors.white,
                                            fontFamily: 'Nunito',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(height: height * .005),
                                        Text(
                                          subtitles[index],
                                          // assetTypeList[index]['description'],
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontFamily: 'Nunito',
                                            color: Colors.white,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * .02),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBottomSheet(
    BuildContext context,
    final List data,
    final String text,
  ) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        Orientation orientation = MediaQuery.of(context).orientation;
        final height = orientation == Orientation.portrait
            ? MediaQuery.of(context).size.height
            : MediaQuery.of(context).size.width;
        final width = orientation == Orientation.portrait
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.height;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                color: const Color(0xffcdcdcd),
                height: height * .02,
                thickness: 5,
                indent: width * .38,
                endIndent: width * .38,
              ),
              SizedBox(height: height * .02),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Pick your option",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: width * .05,
                          fontFamily: 'Nunito Sans',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AssetRowWithTap(
                imagePath: 'assets/images/manual.png',
                title: 'Manual',
                subtitleParts: const [
                  {
                    'text': 'Enter your stock details manually',
                    'color': Colors.black54,
                  },
                ],
                trailing: false,
                percentage: '0%',
                changeValue: '-0.0',
                changeColor: const Color(0xffCE0001),
                onTap: () {
                  print("text:$text");
                  print("data:$data");
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Portquestions(data, text),
                    ),
                  );
                },
              ),
              SizedBox(height: height * 0.01),
              const Divider(
                indent: 60.0,
                thickness: 1.0,
                color: AppColors.cardColor2,
              ),
              SizedBox(height: height * 0.01),
              AssetRowWithTap(
                percentage: '',
                changeValue: '',
                imagePath: 'assets/images/automatic.png',
                title: 'Automatic',
                subtitleParts: const [
                  {
                    'text': 'sync and add stocks automatically',
                    'color': Colors.black54,
                  },
                ],
                trailing: false,
                changeColor: const Color(0xffce009933),
                onTap: () {},
              ),
              SizedBox(height: height * 0.01),
              SizedBox(height: height * 0.03),
              CustomButton(
                text: 'Close',
                fontSize: 16,
                isLoading: false,
                borderRadius: 30,
                borderColor: const Color(0xffC8CECC),
                onPressed: () => Navigator.pop(context),
                color: Colors.white,
                textColor: Colors.black,
              ),
              SizedBox(height: height * 0.03),
            ],
          ),
        );
      },
    );
  }
}

class Select extends StatefulWidget {
  final List data;
  final String text;

  const Select(this.data, this.text, {super.key});

  @override
  _SelectState createState() => _SelectState();
}

class _SelectState extends State<Select> {
  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return AlertDialog(
      // insetPadding: EdgeInsets.zero,
      // titlePadding: EdgeInsets.only(top: width * .01),
      // contentPadding: EdgeInsets.zero,
      elevation: 5,
      title: Text(
        "Provide your asset details",
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: width * .04),
      ),
      content: StatefulBuilder(
        builder: (context, StateSetter setState) {
          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff7F7F7F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * .01),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Portquestions(widget.data, widget.text),
                      ),
                    );
                  },
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      "Manually",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * .01),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff7F7F7F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * .01),
                    ),
                  ),
                  onPressed: null,
                  child: Text(
                    "Automatically(coming soon)",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
