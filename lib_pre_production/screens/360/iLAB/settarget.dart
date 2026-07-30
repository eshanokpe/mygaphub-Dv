import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:expandable/expandable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'ilab.dart';

class Settarget extends StatefulWidget {
  const Settarget({super.key});
  @override
  _SettargetState createState() => _SettargetState();
}

class _SettargetState extends State<Settarget> {
  DialogBox dialogBox = DialogBox();
  Dio dio = Dio();
  Map data = {};
  TextEditingController investContC = TextEditingController();
  TextEditingController equityContC = TextEditingController();
  TextEditingController savingsContC = TextEditingController();
  TextEditingController liabContC = TextEditingController();
  TextEditingController mortContC = TextEditingController();
  TextEditingController npContC = TextEditingController();
  TextEditingController apContC = TextEditingController();
  TextEditingController savperContC = TextEditingController();
  TextEditingController eduContC = TextEditingController();
  TextEditingController expContC = TextEditingController();
  TextEditingController disContC = TextEditingController();
  TextEditingController investContT = TextEditingController();
  TextEditingController equityContT = TextEditingController();
  TextEditingController savingsContT = TextEditingController();
  TextEditingController liabContT = TextEditingController();
  TextEditingController mortContT = TextEditingController();
  TextEditingController npContT = TextEditingController();
  TextEditingController apContT = TextEditingController();
  TextEditingController savperContT = TextEditingController();
  TextEditingController eduContT = TextEditingController();
  TextEditingController expContT = TextEditingController();
  TextEditingController disContT = TextEditingController();

  bool flip = false;

  @override
  void initState() {
    super.initState();
    setState(() => data = context.read<Providers>().settarget);
    investContC.text = "${data["current_ilab"]["investment"]}".replaceAllMapped(
      new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    equityContC.text = "${data["current_ilab"]["equity"]}".replaceAllMapped(
      new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    savingsContC.text = "${data["current_ilab"]["savings"]}".replaceAllMapped(
      new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    liabContC.text = "${data["current_ilab"]["credit"]}".replaceAllMapped(
      new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    mortContC.text = "${data["current_ilab"]["mortgage"]}".replaceAllMapped(
      new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    npContC.text = "${data["current_ilab"]["non_portfolio"]}".replaceAllMapped(
      new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    apContC.text = "${data["current_ilab"]["portfolio"]}".replaceAllMapped(
      new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    savperContC.text = "${data["current_ilab"]["periodic_saving"]}"
        .replaceAllMapped(
          new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    eduContC.text = "${data["current_ilab"]["education"]}".replaceAllMapped(
      new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    expContC.text = "${data["current_ilab"]["expenditure"]}".replaceAllMapped(
      new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    disContC.text = "${data["current_ilab"]["discretionary"]}".replaceAllMapped(
      new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    investContC.text = "${data["current_ilab"]["investment"]}" ?? "0";
    investContT.text = "${data["ilab"]["investment"]}".replaceAllMapped(
      new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    equityContT.text = "${data["ilab"]["equity"]}".replaceAllMapped(
      new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    savingsContT.text = "${data["ilab"]["savings"]}".replaceAllMapped(
      new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    liabContT.text = "${data["ilab"]["credit"]}".replaceAllMapped(
      new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    mortContT.text = "${data["ilab"]["mortgage"]}".replaceAllMapped(
      new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    npContT.text = "${data["ilab"]["non_portfolio"]}".replaceAllMapped(
      new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    apContT.text = "${data["ilab"]["asset_portfolio"]}".replaceAllMapped(
      new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    savperContT.text = "${data["ilab"]["periodic_savings"]}".replaceAllMapped(
      new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    eduContT.text = "${data["ilab"]["education"]}".replaceAllMapped(
      new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    expContT.text = "${data["ilab"]["expenditure"]}".replaceAllMapped(
      new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    disContT.text = "${data["ilab"]["discretionary"]}".replaceAllMapped(
      new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "iLAB Goal Setting",
          style: TextStyle(fontSize: width * .035, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              setState(() {
                flip = true;
              });
            },
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(4),
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * .02,
              vertical: height * .02,
            ),
            child: Column(
              children: [
                const Center(
                  child: Text("(Enter your values for Target Position Only)"),
                ),
                SizedBox(height: height * .03),
                ExpandablePanel(
                  header: Headers(width, "ASSET"),
                  expanded: col1(width, currency),
                  collapsed: const SizedBox.shrink(),
                ),
                SizedBox(height: height * .01),
                ExpandablePanel(
                  header: Headers(width, "LIABILITY"),
                  collapsed: const SizedBox.shrink(),
                  expanded: col2(width, currency),
                ),
                SizedBox(height: height * .01),
                ExpandablePanel(
                  header: Headers(width, "INCOME"),
                  collapsed: const SizedBox.shrink(),
                  expanded: col3(width, currency),
                ),
                SizedBox(height: height * .01),
                ExpandablePanel(
                  header: Headers(width, "BUDGET"),
                  collapsed: const SizedBox.shrink(),
                  expanded: col4(width, currency),
                ),
                SizedBox(height: height * .05),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * .02),
                    ),
                  ),
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(FocusNode());

                    dialogBox.waiting(context, "Loading");
                    var url = Uri.parse("$baseUrl/app/360/ilab");
                    Map data = {
                      "investment": investContT.text.replaceAll(',', ''),
                      "equity": equityContT.text.replaceAll(',', ''),
                      "savings": savingsContT.text.replaceAll(',', ''),
                      "credit": liabContT.text.replaceAll(',', ''),
                      "mortgage": mortContT.text.replaceAll(',', ''),
                      "non_portfolio": npContT.text.replaceAll(',', ''),
                      "portfolio": apContT.text.replaceAll(',', ''),
                      "periodic_savings": savingsContT.text.replaceAll(',', ''),
                      "education": eduContT.text.replaceAll(',', ''),
                      "expenditure": expContT.text.replaceAll(',', ''),
                      "discretionary": disContT.text.replaceAll(',', ''),
                    };
                    final prefs = await SharedPreferences.getInstance();
                    var token = prefs.getString('tokenDB');
                    var response = await http.post(
                      url,
                      body: data,
                      headers: {"Authorization": 'Bearer $token'},
                    );

                    if (response.statusCode == 400) {
                      Navigator.pop(context);

                      //dialogBox.information(context, "Status", response.body);
                      dialogBox.information(
                        context,
                        "Status",
                        'Something want wrong',
                      );
                      return;
                    }
                    if (response.statusCode == 200) {
                      var url = "$baseUrl/app/360/ilab";
                      var response2 = await dio.get(
                        url,
                        options: Options(
                          headers: {"Authorization": 'Bearer $token'},
                        ),
                      );
                      if (response2.statusCode == 200) {
                        Navigator.pop(context);
                        Fluttertoast.showToast(
                          backgroundColor: const Color(0xff00B050),
                          msg: 'iLab target has been set',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                        );
                        context.read<Providers>().setIlabdata(response2.data);
                        Navigator.of(context).pushNamed('Ilab');
                      } else {
                        Navigator.pop(context);
                      }
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    "Save",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * .05,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget col1(width, currency) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(width * .05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Current Position",
                style: TextStyle(
                  fontSize: width * .035,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: width * .06),
              Text(
                "Target Position",
                style: TextStyle(
                  fontSize: width * .035,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Textfield(
          width: width,
          flip: flip,
          currency: currency,
          controllerC: investContC,
          controllerT: investContT,
          name: "Investment",
        ),
        Textfield(
          name: "Home Equity",
          width: width,
          flip: flip,
          controllerC: equityContC,
          controllerT: equityContT,
          currency: currency,
        ),
        Textfield(
          name: "Cash",
          flip: flip,
          width: width,
          controllerC: savingsContC,
          controllerT: savingsContT,
          currency: currency,
        ),
      ],
    );
  }

  Widget col2(width, currency) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(width * .05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Current Position",
                style: TextStyle(
                  fontSize: width * .035,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: width * .06),
              Text(
                "Target Position",
                style: TextStyle(
                  fontSize: width * .035,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Textfield(
          width: width,
          currency: currency,
          flip: flip,
          controllerC: liabContC,
          controllerT: liabContT,
          name: "Credit",
        ),
        Textfield(
          name: "Mortgage",
          width: width,
          flip: flip,
          controllerC: mortContC,
          controllerT: mortContT,
          currency: currency,
        ),
      ],
    );
  }

  Widget col3(width, currency) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(width * .05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Current Position",
                style: TextStyle(
                  fontSize: width * .035,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: width * .06),
              Text(
                "Target Position",
                style: TextStyle(
                  fontSize: width * .035,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Textfield(
          width: width,
          flip: flip,
          currency: currency,
          controllerC: npContC,
          controllerT: npContT,
          name: "Non-Portfolio",
        ),
        Textfield(
          name: "Asset Portfolio",
          width: width,
          flip: flip,
          controllerC: apContC,
          controllerT: apContT,
          currency: currency,
        ),
      ],
    );
  }

  Widget col4(width, currency) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(width * .05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Current Position",
                style: TextStyle(
                  fontSize: width * .035,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: width * .06),
              Text(
                "Target Position",
                style: TextStyle(
                  fontSize: width * .035,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Textfield(
          width: width,
          flip: flip,
          currency: currency,
          controllerC: savperContC,
          controllerT: savperContT,
          name: "Savings Periodic",
        ),
        Textfield(
          name: "Education",
          flip: flip,
          width: width,
          controllerC: eduContC,
          controllerT: eduContT,
          currency: currency,
        ),
        Textfield(
          name: "Expenditure",
          width: width,
          flip: flip,
          controllerC: expContC,
          controllerT: expContT,
          currency: currency,
        ),
        Textfield(
          name: "Discretionary",
          flip: flip,
          width: width,
          controllerC: disContC,
          controllerT: disContT,
          currency: currency,
        ),
      ],
    );
  }
}

class Headers extends StatelessWidget {
  final double width;
  final String name;
  const Headers(this.width, this.name, {super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      elevation: 5,
      child: ListTile(
        trailing: Image.asset(
          'assets/images/chevron_down.png',
          height: width * .04,
        ),
        title: Text(
          name,
          style: TextStyle(
            color: Colors.white,
            fontSize: width * .04,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class Textfield extends StatelessWidget {
  const Textfield({
    super.key,
    required this.name,
    required this.width,
    required this.controllerC,
    required this.controllerT,
    required this.flip,
    required this.currency,
  });
  final bool flip;
  final double width;
  final String currency;
  final TextEditingController controllerC;
  final TextEditingController controllerT;

  final String name;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(width * .02),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "$name:",
                    style: TextStyle(
                      // color: Colors.white,
                      fontSize: width * .035,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: width * .01),
                Expanded(
                  child: TextField(
                    // focusNode: charFoc,
                    enabled: false,
                    inputFormatters: [amountValidator],

                    controller: controllerC,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(width * .03),
                      prefix: Text(currency),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: width * .01),
                Expanded(
                  child: TextField(
                    // focusNode: charFoc,
                    enabled: flip,
                    inputFormatters: [amountValidator],

                    controller: controllerT,

                    onTap: () {
                      if (controllerT.text == '0') {
                        controllerT.clear();
                      }
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(width * .03),
                      prefix: Text(currency),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
