import 'dart:async';
import 'dart:convert';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/models/analyticsinfo.dart';
import 'package:GapHub/utils/connectTo.dart';
import 'package:GapHub/widgets/avatarImage.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'edits/editpage.dart';

class AnalyticHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool? newUserAnalytics;
  const AnalyticHeader({super.key, required this.newUserAnalytics});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isNewUserAnalytics = newUserAnalytics ?? false;
    var geere = context.watch<Providers>().sevengeemodel.steps;
    var colors = context.watch<Providers>().sevengeemodel.backgrounds;
    List<String> sevenGees = [];
    List<String> sevenGeesColor = [];
    List<String> sevenGeesColors = [];
    List<int> realColors = [];
    for (var a in geere) {
      sevenGees.add(a.toString());
    }
    for (var a in colors) {
      sevenGeesColor.add(a.toString().substring(1));
    }

    for (var a in sevenGeesColor) {
      sevenGeesColors.add('0xff$a');
    }
    for (var a in sevenGeesColors) {
      realColors.add(int.parse(a));
    }
    bool contains = realColors.contains(0xff494949);
    DialogBox dialogBox = DialogBox();
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return AppBar(
      backgroundColor: Colors.white,
      title: const Text(
        '',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
      elevation: 0,
      leading: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * .03),
        child: Image.asset('assets/logo.png'),
      ),
      surfaceTintColor: Colors.white,
      actions: [
        // Text('${isNewUserAnalytics}'),
        isNewUserAnalytics
            ? Container()
            : IconButton(
                onPressed: () async {
                  var timer = Timer(const Duration(milliseconds: 20000), () {
                    Navigator.pop(context);
                    dialogBox.information(
                      context,
                      'Status',
                      'Service timed out',
                    );
                    return;
                  });
                  dialogBox.waiting(context, 'Loading');
                  var url = Uri.parse('$baseUrl/app/seveng/edit');

                  final prefs = await SharedPreferences.getInstance();
                  String? finalToken = prefs.getString('tokenDB');

                  var response = await http.get(
                    url,
                    headers: {"Authorization": 'Bearer $finalToken'},
                  );
 
                  if (response.statusCode == 200) {
                    //var expendituredata = dd["data"]['grand'];
                    var body = jsonDecode(response.body);
                    var analyticsdata = body["data"];

                    Analyticsinfo? analyticsinfo = Analyticsinfo.fromJson(
                      analyticsdata,
                    );
                    context.read<Providers>().setAnalyticsInfo(analyticsinfo);
                    Navigator.pop(context);
                    timer.cancel();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Editpage(realColors, analyticsinfo, contains),
                      ),
                    );
                  }
                },
                icon: Image.asset(
                  'assets/icons/pencil-black.png',
                  width: 28.w,
                  height: 28.h,
                  fit: BoxFit.contain,
                ),
              ),
        const AvatarImage(),
      ],
    );
  }

  getAssetClasses(context, Function doing) {
    connectTo(context, "get", "/app/portfolio/information", {}, shoot: doing);
  }
}
