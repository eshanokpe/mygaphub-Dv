import 'package:GapHub/utils/connectTo.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReapReserve extends StatefulWidget {
  const ReapReserve({super.key, required this.assetId});
  final String assetId;
  @override
  _ReapReserveState createState() => _ReapReserveState();
}

class _ReapReserveState extends State<ReapReserve> {
  TextEditingController phoneNumsController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        elevation: 25,
        backgroundColor: Colors.white,
        title: const Text(
          "Asset Reservation",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * .03,
          vertical: height * .02,
        ),
        child: ListView(
          children: [
            SizedBox(height: height * .03),
            if (["", null].contains(
              Provider.of<Providers>(context, listen: false).details[3],
            ))
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Phone Number',
                  style: TextStyle(
                    fontSize: width * .045,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            SizedBox(height: height * .005),
            if (["", null].contains(
              Provider.of<Providers>(context, listen: false).details[3],
            ))
              TextFormField(
                controller: phoneNumsController,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  prefixText: "",
                  prefixStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.only(
                    left: width * .013,
                    right: width * .03,
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
            if (["", null].contains(
              Provider.of<Providers>(context, listen: false).details[3],
            ))
              SizedBox(height: height * .03),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Subject',
                style: TextStyle(
                  fontSize: width * .045,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: height * .005),
            TextFormField(
              controller: subjectController,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                prefixText: "",
                prefixStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.only(
                  left: width * .013,
                  right: width * .03,
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            SizedBox(height: height * .03),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Message',
                style: TextStyle(
                  fontSize: width * .045,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: height * .005),
            TextFormField(
              controller: messageController,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 7,
              decoration: InputDecoration(
                prefixText: "",
                prefixStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.only(
                  left: width * .013,
                  right: width * .03,
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            SizedBox(height: height * .005),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  Save();
                },
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Save() {
    print("asset id: ${widget.assetId}");
    var details = Provider.of<Providers>(context, listen: false).details;
    if (["", null].contains(details[3])) {
      if (["", null].contains(phoneNumsController.text.trim()) ||
          ["", null].contains(subjectController.text.trim()) ||
          ["", null].contains(messageController.text.trim())) {
        var dialogBox = DialogBox();
        dialogBox.information(
          context,
          'Provide All Details',
          'All fields must be filled',
        );
        return;
      }
      var data = {
        "message": messageController.text.trim(),
        "phone": phoneNumsController.text.trim(),
        "subject": subjectController.text.trim(),
      };
      connectTo(
        context,
        "post",
        "/app/acquisition/interest/reap/${widget.assetId}",
        data,
        shoot: () {
          Navigator.pop(context);
        },
      );
    } else {
      if (!["", null].contains(subjectController.text.trim()) &&
          !["", null].contains(messageController.text.trim())) {
        var data = {
          "message": messageController.text.trim(),
          "subject": subjectController.text.trim(),
        };
        connectTo(
          context,
          "post",
          "/app/acquisition/interest/reap/${widget.assetId}",
          data,
          shoot: () {
            Navigator.pop(context);
          },
        );
      } else {
        var dialogBox = DialogBox();
        dialogBox.information(
          context,
          'Provide All Details',
          'All fields must be filled',
        );
      }
    }
  }
}
