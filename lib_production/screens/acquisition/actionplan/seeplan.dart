import 'package:GapHub/models/remindermodel.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter/material.dart';

class Seeplan extends StatefulWidget {
  final String assetType;
  final List<Actionplanmodel> actionPlanList;

  const Seeplan({
    super.key,
    required this.actionPlanList,
    required this.assetType,
  });

  @override
  _SeeplanState createState() => _SeeplanState();
}

class _SeeplanState extends State<Seeplan> {
  @override
  Widget build(BuildContext context) {
    List actionPlanLists = widget.actionPlanList.reversed.toList();
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text(widget.assetType), centerTitle: true),
      bottomNavigationBar: const BottomNav(2),
      body: actionPlanLists.isEmpty
          ? Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'No action plan added yet',
                      style: TextStyle(fontSize: width * .05),
                    ),
                  ),
                ],
              ),
            )
          : Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * .04,
                vertical: width * .04,
              ),
              child: ListView.builder(
                itemBuilder: (context, index) => Card(
                  elevation: 5,
                  child: ListTile(
                    onTap: () {
                      _showPicker(
                        context,
                        widget.assetType,
                        width,
                        height,
                        actionPlanLists[index],
                      );
                    },
                    title: Text(
                      actionPlanLists[index].note,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: width * .045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Image.asset(
                      'assets/images/chevron_right.png',
                      height: height * .05,
                      width: width * .05,
                    ),
                    subtitle: Text(
                      actionPlanLists[index].date,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: width * .035,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
                itemCount: widget.actionPlanList.length,
              ),
            ),
    );
  }

  void _showPicker(
    BuildContext context,
    String assetType,
    width,
    height,
    Actionplanmodel actionplanmodel,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            height: height * .5,
            padding: EdgeInsets.all(width * .02),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      actionplanmodel.date,
                      style: TextStyle(
                        color: const Color(0xff000000),
                        fontWeight: FontWeight.w900,
                        fontSize: width * .055,
                      ),
                    ),
                    SizedBox(
                      height: height * .03,
                      child: Divider(color: Theme.of(context).primaryColor),
                    ),
                    Text(
                      actionplanmodel.note,
                      style: TextStyle(
                        color: const Color(0xff000000),
                        fontWeight: FontWeight.w400,
                        fontSize: width * .040,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: height * .02,
                      child: Divider(color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
