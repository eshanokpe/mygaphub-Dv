import 'package:GapHub/screens/homepage/widget/row_view_details.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/plus_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widget/customlisttile.dart';

class UpcomingPayments extends StatefulWidget {
  const UpcomingPayments({super.key});

  @override
  State<UpcomingPayments> createState() => _UpcomingPaymentsState();
}

class _UpcomingPaymentsState extends State<UpcomingPayments> {
  List payments = [];
  Map assistance = {};
  String empty = "";

  @override
  void initState() {
    super.initState();
    assistance = context.read<Providers>().assistance;
    payments = assistance["payments"]["reminders"];
  }

  @override
  Widget build(BuildContext context) {
    String currency = context.watch<Providers>().snapshotmodel.currency;
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(
          color: Color.fromARGB(255, 241, 241, 241),
          width: 1.5,
        ),
      ),
      color: const Color.fromARGB(255, 253, 253, 253),
      child: Column(
        children: [
          SizedBox(height: height * .01),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8, top: 10),
            child: RowViewDetails(
              mainText: 'Upcoming Payments',
              detailText: 'View',
              onTap: () {},
              arrowTap: true,
            ),
          ),
          SizedBox(height: height * .01),
          const Divider(
            height: 10,
            thickness: 0.2,
            color: Color.fromARGB(133, 128, 128, 128),
          ),
          payments.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: width * .0,
                    vertical: height * .02,
                  ),
                  child: Column(
                    children: [
                      CustomListTile(
                        currency: currency,
                        imagePath: 'assets/icons/amazon.png',
                        title: 'Amazon',
                        subtitle: 'Monthly on 22nd',
                        width: width,
                        amount: 5.99,
                      ),
                      SizedBox(height: height * 0.01),
                      const Divider(
                        thickness: 1.5,
                        color: Color(0xffF1F1F1),
                        indent: 70,
                      ),
                      CustomListTile(
                        currency: currency,
                        imagePath: 'assets/icons/google_pay.png',
                        title: 'Google Subscri... ',
                        subtitle: 'Monthly on 22nd',
                        width: width,
                        amount: 7.99,
                      ),
                      SizedBox(height: height * 0.02),
                      const Divider(
                        thickness: 1.5,
                        color: Color(0xffF1F1F1),
                        indent: 70,
                      ),
                      CustomListTile(
                        currency: currency,
                        imagePath: 'assets/icons/airbnb.png',
                        title: 'Airbnb',
                        subtitle: 'Monthly on 22nd',
                        width: width,
                        amount: 177.00,
                      ),
                      const Divider(
                        thickness: 1.5,
                        color: Color(0xffF1F1F1),
                        indent: 70,
                      ),
                      CustomListTile(
                        currency: currency,
                        imagePath: 'assets/icons/snapchat.png',
                        title: 'Snapchat',
                        subtitle: 'Monthly on 22nd',
                        width: width,
                        amount: 4.99,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 13.0,
                              top: 12,
                            ),
                            child: PlusButton(
                              color: Colors.white,
                              iconsColor: AppColors.primaryColor,
                              textColor: AppColors.blackColor,
                              icons: Icons.add,
                              text: 'Add Payment',
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.03),
                    ],
                  ),
                )
              : Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: width * .04,
                    vertical: height * .02,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: height * 0.03),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'You have no Upcoming Payments',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xff666666),
                              fontSize: width * 0.04,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.03),
                      PlusButton(
                        color: Colors.white,
                        iconsColor: AppColors.primaryColor,
                        textColor: AppColors.blackColor,
                        icons: Icons.add,
                        text: 'Add Payment',
                        onPressed: () {},
                      ),
                      SizedBox(height: height * 0.03),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
