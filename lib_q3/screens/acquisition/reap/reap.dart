import 'package:GapHub/provider/acquisitionProvider.dart';
import 'package:GapHub/screens/acquisition/reap/reaplist.dart';
import 'package:GapHub/screens/acquisition/reap/search/search.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/widgets/avatarImage.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:flutter/material.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'widget/reapcountries.dart';

class Reap extends StatefulWidget {
  const Reap({super.key});
  @override
  _ReapState createState() => _ReapState();
}

class _ReapState extends State<Reap> {
  Dio dio = Dio();
  DialogBox dialogBox = DialogBox();
  bool filterToggle = true;
  String item1 = 'Zip Code';
  String item2 = 'Bed';
  String item3 = 'Bath';
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
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
          actions: const [AvatarImage()],
        ),
        bottomNavigationBar: const BottomNav(2),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: width * .03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Search(),
                SizedBox(height: height * .01),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: width * .035),
                  child: Visibility(
                    visible: !filterToggle,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.name,
                                style: TextStyle(fontSize: width * .035),
                                controller: city,
                                decoration: InputDecoration(
                                  hintText: 'City',
                                  contentPadding: EdgeInsets.all(width * .03),
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      width * .02,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: width * .01),
                            Expanded(
                              child: TextField(
                                style: TextStyle(fontSize: width * .035),
                                controller: country,
                                keyboardType: TextInputType.name,
                                decoration: InputDecoration(
                                  hintText: 'Country',
                                  contentPadding: EdgeInsets.all(width * .03),
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      width * .02,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height * .01),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                style: TextStyle(fontSize: width * .035),
                                controller: priceFrom,
                                inputFormatters: [amountValidator],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Price From (\$)',
                                  contentPadding: EdgeInsets.all(width * .03),
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      width * .02,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: width * .01),
                            Expanded(
                              child: TextField(
                                style: TextStyle(fontSize: width * .035),
                                controller: priceTo,
                                inputFormatters: [amountValidator],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Price To (\$)',
                                  contentPadding: EdgeInsets.all(width * .03),
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      width * .02,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: height * .01),
                Reapcountries(
                  country: 'US',
                  // onClick: getReapUS,
                  onClick: () {
                    context.read<AcquisitionProvider>();
                    navigateWithSlideTransition(
                      context: context,
                      destinationScreen: const ReapList(category: 'US'),
                      transitionDuration: const Duration(milliseconds: 200),
                    );
                  },
                  imgAsset: 'assets/images/acquisition/us.jpeg',
                  imgAssetFlag: 'assets/images/acquisition/usaflag.png',
                  roi: '12',
                  mincap: '40,000',
                ),
                SizedBox(height: height * .01),
                Reapcountries(
                  country: 'UK',
                  // onClick: getReapUK,
                  onClick: () {
                    context.read<AcquisitionProvider>();
                    navigateWithSlideTransition(
                      context: context,
                      destinationScreen: const ReapList(category: 'UK'),
                      transitionDuration: const Duration(milliseconds: 200),
                    );
                  },
                  imgAsset: 'assets/images/acquisition/uk.png',
                  imgAssetFlag: 'assets/images/acquisition/ukflag.jpeg',
                  roi: '12',
                  mincap: '40,000',
                ),
                Reapcountries(
                  country: 'Nigeria',
                  // onClick: getReapNGR,
                  onClick: () {
                    context.read<AcquisitionProvider>();
                    navigateWithSlideTransition(
                      context: context,
                      destinationScreen: const ReapList(category: 'Nigeria'),
                      transitionDuration: const Duration(milliseconds: 200),
                    );
                  },
                  imgAsset: 'assets/images/acquisition/nig.jpeg',
                  imgAssetFlag: 'assets/images/acquisition/nig_flag.png',
                  roi: '17',
                  mincap: '20,000',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // search() async {
  //   FocusScope.of(context).requestFocus(FocusNode());

  //   String searchword = "";
  //   keywordText = keyword.text.trim();
  //   cityText = city.text.trim();
  //   countryText = country.text.trim();
  //   priceFromText = priceFrom.text.trim();
  //   priceToText = priceTo.text.trim();

  //   var timer = Timer(Duration(milliseconds: 20000), () {
  //     Navigator.pop(context);
  //     dialogBox.information(context, 'Status', 'Service timed out');
  //     return;
  //   });
  //   int page = 1;
  //   http.Response _url;

  //   String _baseUrl =
  //       'http://gappropertyhub.com/api/search?token=qswsdopspncagajkxnnznbxghsjksjujiubszajkbagznbzvszhjvxhvsvzghzgxgvxhgdjhvhchxbhxbxvvxvhhxvhvhhmdjxdbjxvhjhxdbvjxdxjbvlbjz&page=$page';

  //   String url2 =
  //       'http://gappropertyhub.com/api/search?token=qswsdopspncagajkxnnznbxghsjksjujiubszajkbagznbzvszhjvxhvsvzghzgxgvxhgdjhvhchxbhxbxvvxvhhxvhvhhmdjxdbjxvhjhxdbvjxdxjbvlbjz';

  //   dialogBox.waiting(context, 'Searching');
  //   if (keywordText.isEmpty &&
  //       cityText.isEmpty &&
  //       countryText.isEmpty &&
  //       priceFromText.isEmpty &&
  //       priceToText.isEmpty) {
  //     Navigator.pop(context);
  //     timer.cancel();
  //     Fluttertoast.showToast(msg: "Please Enter your search Keyword");
  //   }

  //   if (keywordText.isNotEmpty) {
  //     searchword = keywordText;
  //     print('search:$searchword');
  //     _url = await http.get(Uri.parse('$_baseUrl/&ct_keyword=$keywordText'));
  //   }

  //   if (cityText.isNotEmpty) {
  //     searchword = cityText;
  //     _url = await http.get(Uri.parse('$_baseUrl/&ct_city=$cityText'));
  //   }

  //   if (countryText.isNotEmpty) {
  //     searchword = countryText;
  //     _url = await http.get(Uri.parse('$_baseUrl/&ct_country=$countryText'));
  //   }

  //   if (priceFromText.isNotEmpty) {
  //     searchword = priceFromText;
  //     _url =
  //         await http.get(Uri.parse('$_baseUrl/&ct_price_from=$priceFromText'));
  //   }

  //   if (priceToText.isNotEmpty) {
  //     searchword = priceToText;
  //     _url = await http.get(Uri.parse('$_baseUrl/&ct_price_to=$priceToText'));
  //   }

  //   var response = _url;

  //   if (response.statusCode == 200) {
  //     var url3 = "$baseUrl/app/acquisition/favourite";
  //     final prefs = await SharedPreferences.getInstance();
  //     var token = prefs.getString('tokenDB');
  //     var response3 = await dio.get(url3,
  //         options: Options(
  //           headers: {"Authorization": 'Bearer $token'},
  //         ));
  //     context.read<Providers>().setFavorites(response3.data["assets"]);
  //     Reapserver reapserver = Reapserver.fromJson(jsonDecode(response.body));
  //     //print("reapserver:$reapserver");

  //     timer.cancel();
  //     Navigator.pop(context);
  //     keyword.clear();
  //     city.clear();
  //     country.clear();
  //     priceFrom.clear();
  //     priceTo.clear();

  //     Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) => ReapList(
  //                   url: url2,
  //                   search: true,
  //                   searchword: searchword.trim(),
  //                   reapList: reapserver.result['data'],
  //                   firstPage: page,
  //                   lastPage: reapserver.result['last_page'],
  //                 )));
  //   } else {
  //     timer.cancel();
  //     Navigator.pop(context);

  //     dialogBox.information(context, 'Error', 'An error ocurred');
  //   }
  // }

  // getReapUS() async {
  //   FocusScope.of(context).requestFocus(FocusNode());

  //   int page = 1;
  //   Timer timer = Timer(Duration(milliseconds: 20000), () {
  //     Navigator.pop(context);
  //     dialogBox.information(context, 'Status', 'Service timed out');
  //     return;
  //   });
  //   try {
  //     dialogBox.waiting(context, 'Loading');
  //     var url = Uri.parse(
  //         'http://gappropertyhub.com/api/search?ct_property_type=REAP%20US&token=qswsdopspncagajkxnnznbxghsjksjujiubszajkbagznbzvszhjvxhvsvzghzgxgvxhgdjhvhchxbhxbxvvxvhhxvhvhhmdjxdbjxvhjhxdbvjxdxjbvlbjz&page=$page');
  //     String url2 =
  //         'http://gappropertyhub.com/api/search?ct_property_type=REAP%20US&token=qswsdopspncagajkxnnznbxghsjksjujiubszajkbagznbzvszhjvxhvsvzghzgxgvxhgdjhvhchxbhxbxvvxvhhxvhvhhmdjxdbjxvhjhxdbvjxdxjbvlbjz';

  //     var response = await http.get(url);
  //     if (response.statusCode == 200) {
  //       var url3 = "$baseUrl/app/acquisition/favourite";
  //       final prefs = await SharedPreferences.getInstance();
  //       var token = prefs.getString('tokenDB');
  //       var response3 = await dio.get(url3,
  //           options: Options(
  //             headers: {"Authorization": 'Bearer $token'},
  //           ));
  //       print(response3.data);
  //       context.read<Providers>().setFavorites(response3.data["assets"]);
  //       Reapserver reapserver = Reapserver.fromJson(jsonDecode(response.body));
  //       timer.cancel();
  //       Navigator.pop(context);
  //       // Navigator.push(
  //       //     context,
  //       //     MaterialPageRoute(
  //       //         builder: (context) => ReapList(
  //       //               search: false,
  //       //               url: url2,
  //       //               reapList: reapserver.result['data'],
  //       //               firstPage: page,
  //       //               lastPage: reapserver.result['last_page'],
  //       //             )));
  //     } else {
  //       timer.cancel();
  //       Navigator.pop(context);
  //       dialogBox.information(context, 'Error', 'An error ocurred');
  //     }
  //   } catch (e) {
  //     timer.cancel();
  //     Navigator.pop(context);
  //     dialogBox.information(context, 'Error', e.toString());
  //   }
  // }

  // getReapUK() async {
  //   int page = 1;

  //   var timer = Timer(Duration(milliseconds: 20000), () {
  //     Navigator.pop(context);
  //     dialogBox.information(context, 'Status', 'Service timed out');
  //     return;
  //   });
  //   try {
  //     dialogBox.waiting(context, 'Loading');
  //     var url = Uri.parse(
  //         'http://gappropertyhub.com/api/search?ct_property_type=REAP%20UK&token=qswsdopspncagajkxnnznbxghsjksjujiubszajkbagznbzvszhjvxhvsvzghzgxgvxhgdjhvhchxbhxbxvvxvhhxvhvhhmdjxdbjxvhjhxdbvjxdxjbvlbjz&page=$page');

  //     String url2 =
  //         'http://gappropertyhub.com/api/search?ct_property_type=REAP%20UK&token=qswsdopspncagajkxnnznbxghsjksjujiubszajkbagznbzvszhjvxhvsvzghzgxgvxhgdjhvhchxbhxbxvvxvhhxvhvhhmdjxdbjxvhjhxdbvjxdxjbvlbjz';

  //     var response = await http.get(url);
  //     if (response.statusCode == 200) {
  //       var url3 = "$baseUrl/app/acquisition/favourite";
  //       final prefs = await SharedPreferences.getInstance();
  //       var token = prefs.getString('tokenDB');
  //       var response3 = await dio.get(url3,
  //           options: Options(
  //             headers: {"Authorization": 'Bearer $token'},
  //           ));
  //       context.read<Providers>().setFavorites(response3.data["assets"]);
  //       Reapserver reapserver = Reapserver.fromJson(jsonDecode(response.body));
  //       timer.cancel();
  //       Navigator.pop(context);
  //       // Navigator.push(
  //       //     context,
  //       //     MaterialPageRoute(
  //       //         builder: (context) => ReapList(
  //       //               search: false,
  //       //               url: url2,
  //       //               reapList: reapserver.result['data'],
  //       //               firstPage: page,
  //       //               lastPage: reapserver.result['last_page'],
  //       //             )));
  //     } else {
  //       timer.cancel();
  //       Navigator.pop(context);
  //       dialogBox.information(context, 'Error', 'An error ocurred');
  //     }
  //   } catch (e) {
  //     timer.cancel();
  //     Navigator.pop(context);
  //     dialogBox.information(context, 'Error', 'An error ocurred');
  //   }
  // }

  // getReapNGR() async {
  //   int page = 1;

  //   var timer = Timer(Duration(milliseconds: 20000), () {
  //     Navigator.pop(context);
  //     dialogBox.information(context, 'Status', 'Service timed out');
  //     return;
  //   });
  //   try {
  //     dialogBox.waiting(context, 'Loading');
  //     var url = Uri.parse(
  //         'http://gappropertyhub.com/api/search?ct_property_type=REAP%20NIGERIA&token=qswsdopspncagajkxnnznbxghsjksjujiubszajkbagznbzvszhjvxhvsvzghzgxgvxhgdjhvhchxbhxbxvvxvhhxvhvhhmdjxdbjxvhjhxdbvjxdxjbvlbjz&page=$page');

  //     String url2 =
  //         'http://gappropertyhub.com/api/search?ct_property_type=REAP%20NIGERIA&token=qswsdopspncagajkxnnznbxghsjksjujiubszajkbagznbzvszhjvxhvsvzghzgxgvxhgdjhvhchxbhxbxvvxvhhxvhvhhmdjxdbjxvhjhxdbvjxdxjbvlbjz';

  //     var response =
  //         await http.get(url, headers: {'Content-Type': 'application/json'});
  //     if (response.statusCode == 200) {
  //       var url3 = "$baseUrl/app/acquisition/favourite";
  //       final prefs = await SharedPreferences.getInstance();
  //       var token = prefs.getString('tokenDB');
  //       var response3 = await dio.get(url3,
  //           options: Options(
  //             headers: {"Authorization": 'Bearer $token'},
  //           ));
  //       context.read<Providers>().setFavorites(response3.data["assets"]);
  //       // print(response3.data["assets"]);
  //       Reapserver reapserver = Reapserver.fromJson(jsonDecode(response.body));
  //       timer.cancel();
  //       Navigator.pop(context);
  //       // Navigator.push(
  //       //     context,
  //       //     MaterialPageRoute(
  //       //         builder: (context) => ReapList(
  //       //               search: false,
  //       //               url: url2,
  //       //               reapList: reapserver.result['data'],
  //       //               firstPage: page,
  //       //               lastPage: reapserver.result['last_page'],
  //       //             )));
  //     } else {
  //       timer.cancel();
  //       Navigator.pop(context);
  //       dialogBox.information(context, 'Error', 'Something went wrong');
  //     }
  //   } catch (e) {
  //     timer.cancel();
  //     Navigator.pop(context);
  //     dialogBox.information(context, 'Error', e.toString());
  //   }
  // }
}
