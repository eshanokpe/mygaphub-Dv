import 'dart:async';
import 'dart:convert';
import 'package:GapHub/utils/dialog.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/models/reapserver.dart';
import 'package:GapHub/screens/acquisition/reap/reaplist.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/customBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AcquisitionHeader2 extends StatefulWidget {
  final bool backArrow;
  const AcquisitionHeader2({super.key, this.backArrow = true});

  @override
  State<AcquisitionHeader2> createState() => _AcquisitionHeader2State();
}

class _AcquisitionHeader2State extends State<AcquisitionHeader2> {
  Dio dio = Dio();
  DialogBox dialogBox = DialogBox();
  bool filterToggle = true;
  String keywordText = '';
  String cityText = '';
  String countryText = '';
  String priceToText = '';
  String priceFromText = '';
  TextEditingController keyword = TextEditingController();

  TextEditingController city = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController priceFrom = TextEditingController();
  TextEditingController priceTo = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: height * 0.20,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(
                  right: width * 0.06,
                  left: width * 0.06,
                ),
                height: height * 0.15,
                color: Colors.white,
              ),
            ],
          ),
        ),
        widget.backArrow == true
            ? Positioned(
                left: 18,
                top: 30,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                      size: 23,
                    ),
                  ),
                ),
              )
            : Positioned(
                left: 15,
                top: 25,
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(15.0),
                        ),
                      ),
                      builder: (BuildContext context) {
                        return const CustomBottomSheet(
                          title: 'Disclaimer',
                          content:
                              'The information provided in our asset acquisition content is intended solely for informational purposes. It should not be considered as financial advice, investment recommendations, or a solicitation to buy or sell any financial products. Always conduct your own research and consult with a qualified financial advisor before making any investment decisions.',
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.asset(
                      'assets/icons/red_zone.png',
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
              ),
        Positioned(
          right: 3,
          top: 20,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/avatar.png',
              width: 35,
              height: 35,
            ),
          ),
        ),
        Positioned(
          left: 10,
          top: 62,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Real Estate Asset Program ',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w800,
                        fontSize: width * .05,
                      ),
                    ),
                    Text(
                      '[REAP]',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w800,
                        fontSize: width * .05,
                        color: const Color(0xff808080),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * .01),
                SizedBox(
                  // padding: EdgeInsets.symmetric(horizontal: width * .02),
                  width: width * .9,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: EdgeInsets.zero,
                              child: TextField(
                                style: TextStyle(fontSize: width * .035),
                                controller: keyword,
                                onEditingComplete: () {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(FocusNode());
                                  search();
                                },
                                textCapitalization:
                                    TextCapitalization.sentences,
                                textInputAction: TextInputAction.search,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xffe5e5e5),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  hintText:
                                      'Enter a street address, postcode, e.t.c',
                                  filled: true,
                                  contentPadding: EdgeInsets.all(width * .01),
                                  hintStyle: const TextStyle(
                                    fontFamily: 'Nunito',
                                    color: Color(0xff808080),
                                    fontWeight: FontWeight.w300,
                                  ),
                                  prefixIcon: Image.asset(
                                    'assets/images/acquisition/searchIcon.png',
                                  ),
                                  fillColor: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: width * .02),
                          InkWell(
                            onTap: () {
                              setState(() {
                                filterToggle = !filterToggle;
                              });
                            },
                            child: filterToggle
                                ? Image.asset(
                                    'assets/images/acquisition/filter.png',
                                    height: height * .03,
                                  )
                                : Image.asset(
                                    'assets/images/acquisition/filter.png',
                                    height: height * .03,
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> search() async {
    FocusScope.of(context).requestFocus(FocusNode());

    String searchword = "";
    keywordText = keyword.text.trim();
    cityText = city.text.trim();
    countryText = country.text.trim();
    priceFromText = priceFrom.text.trim();
    priceToText = priceTo.text.trim();

    if (keywordText.isEmpty &&
        cityText.isEmpty &&
        countryText.isEmpty &&
        priceFromText.isEmpty &&
        priceToText.isEmpty) {
      Fluttertoast.showToast(msg: "Please Enter your search Keyword");
      return;
    }

    var timer = Timer(const Duration(seconds: 20), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
    });

    int page = 1;
    String baseUrl = 'http://gappropertyhub.com/api/search';

    Map<String, String> queryParams = {
      'token':
          'qswsdopspncagajkxnnznbxghsjksjujiubszajkbagznbzvszhjvxhvsvzghzgxgvxhgdjhvhchxbhxbxvvxvhhxvhvhhmdjxdbjxvhjhxdbvjxdxjbvlbjz',
      'page': page.toString(),
    };

    if (keywordText.isNotEmpty) queryParams['ct_keyword'] = keywordText;
    if (cityText.isNotEmpty) queryParams['ct_city'] = cityText;
    if (countryText.isNotEmpty) queryParams['ct_country'] = countryText;
    if (priceFromText.isNotEmpty) queryParams['ct_price_from'] = priceFromText;
    if (priceToText.isNotEmpty) queryParams['ct_price_to'] = priceToText;

    Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    try {
      dialogBox.waiting(context, 'Searching');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        var url3 = "http://gappropertyhub.com/app/acquisition/favourite";
        final prefs = await SharedPreferences.getInstance();
        var token = prefs.getString('tokenDB');

        var response3 = await dio.get(
          url3,
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );

        context.read<Providers>().setFavorites(response3.data["assets"]);
        Reapserver reapserver = Reapserver.fromJson(jsonDecode(response.body));

        timer.cancel();
        Navigator.pop(context);

        keyword.clear();
        city.clear();
        country.clear();
        priceFrom.clear();
        priceTo.clear();

        // Uncomment if navigation is needed
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ReapList(
        //       url: uri.toString(),
        //       search: true,
        //       searchword: searchword.trim(),
        //       reapList: reapserver.result['data'],
        //       firstPage: page,
        //       lastPage: reapserver.result['last_page'],
        //     ),
        //   ),
        // );
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      timer.cancel();
      Navigator.pop(context);
      dialogBox.information(context, 'Error', 'An error occurred: $e');
    }
  }
}
