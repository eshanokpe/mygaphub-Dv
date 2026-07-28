import 'dart:async';
import 'dart:convert';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/models/actionplanserver.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'actionplanote.dart';
import 'package:http/http.dart' as http;
 
class Actionplan extends StatefulWidget {
  const Actionplan({super.key});

  @override
  _ActionplanState createState() => _ActionplanState();
}

class _ActionplanState extends State<Actionplan> {
  DialogBox dialogBox = DialogBox();
  List<String> assets = [
    'Business Asset',
    'Risk Asset',
    'Appreciating Asset',
    'Intellectual Asset',
    'Depreciating Asset',
  ];

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    navigateToPopPage() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('last_route');

      Navigator.of(context).pop(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Action Plan',
          style: TextStyle(fontSize: width * .035, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const BottomNav(2),
      body: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          Image.asset(
            'assets/images/bridge.jpg',
            height: height,
            width: width,
            fit: BoxFit.fill,
          ),
          Container(
            height: double.infinity,
            width: width,
            color: Colors.black.withOpacity(.8),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: height * .03,
              horizontal: width * .03,
            ),
            child: Column(
              children: [
                Expanded(
                  // height: height * .8,
                  child: ListView.builder(
                    itemCount: assets.length,
                    itemBuilder: (context, index) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      color: const Color(0xffF3F3F3),
                      child: ListTile(
                        onTap: () async {
                          var timer = Timer(
                            const Duration(milliseconds: 20000),
                            () {
                              Navigator.pop(context);
                              dialogBox.information(
                                context,
                                'Status',
                                'Service timed out',
                              );
                              return;
                            },
                          );
                          dialogBox.waiting(context, 'Loading');

                          var url = Uri.parse('$baseUrl/app/todayplan');
                          final prefs = await SharedPreferences.getInstance();
                          var token = prefs.getString('tokenDB');
                          final response2 = await http.get(
                            url,
                            headers: {"Authorization": 'Bearer $token'},
                          );

                          if (response2.statusCode == 200) {
                            Todayplanserver todayplanserver =
                                Todayplanserver.fromJson(
                                  jsonDecode(response2.body),
                                );

                            context.read<Providers>().setTodayPlan(
                              todayplanserver,
                            );
                            timer.cancel();
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Actionplanote(
                                  assetType: assets[index],
                                  todayplan: todayplanserver,
                                ),
                              ),
                            );
                          } else {
                            timer.cancel();
                            Navigator.pop(context);
                            dialogBox.information(
                              context,
                              'Error',
                              'An error occured',
                            );
                          }
                        },
                        title: Text(
                          assets[index],
                          style: TextStyle(
                            fontSize: width * .045,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        trailing: Image.asset(
                          'assets/images/chevron_right.png',
                          height: height * .035,
                          width: width * .035,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
