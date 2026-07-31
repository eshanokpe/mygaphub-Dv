import 'dart:convert';
import 'package:GapHub/models/savingAllocationserver.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'education_allocation_summary.dart';

class EAddNote extends StatefulWidget {
  List<SavingAllserver> item;
  int index;
  EAddNote({super.key, required this.index, required this.item});

  @override
  State<EAddNote> createState() => _EAddNoteState();
}

class _EAddNoteState extends State<EAddNote> {
  final TextEditingController _note = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _label = TextEditingController();
  List<SavingAllserver> _data = [];
  FocusNode myFocusNode = FocusNode();
  String _enteredText = '';

  @override
  void initState() {
    setState(() {
      super.initState();
      _note.text = widget.item[widget.index].note.toString();
      _amount.text = widget.item[widget.index].amount.toString();
      _label.text = widget.item[widget.index].label.toString();
    });
  }

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
      // backgroundColor: Colors.blue.withOpacity(.05),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Add a note',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: context.width(.045),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Typicons.trash),
            ),
          ),
        ],
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              maxLength: 70,
              maxLines: 8,
              keyboardType: TextInputType.text,
              controller: _note,
              // focusNode: myFocusNode,
              onChanged: (value) {
                setState(() {
                  _enteredText = value;
                });
              },
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Type something',
                contentPadding: EdgeInsets.only(top: 60),
              ),
            ),
            Text("${70 - _enteredText.length} characters left"),
            SizedBox(height: height * .02),
            SizedBox(
              width: width * .90,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.only(
                    left: width * .10,
                    right: width * .10,
                  ),
                ),
                onPressed: () {
                  updateEducationAllocationNote();
                },
                child: const Text(
                  "Done",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  updateEducationAllocationNote() async {
    EasyLoading.show(status: 'Loading', dismissOnTap: false);
    // bool result = await isInternetAvailable();
    // if (!result) {
    //   dialogBox.information(
    //       context, 'Status', 'Check your Internet Connection');
    //   EasyLoading.dismiss();
    //   return;
    // }
    var id = widget.item[widget.index].id;
    print('id:$id');
    var url = Uri.parse("$baseUrl/app/seed/allocate/budget/$id");
    var urlSA = Uri.parse(
      "$baseUrl/app/seed/allocate/budget?category=education",
    );
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    final response = await http.put(
      url,
      body: {
        'category': 'education',
        'label': _label.text.trim(),
        "amount": _amount.text.trim(),
        'note': _note.text.trim(),
      },
      headers: {
        "Authorization": 'Bearer $token',
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      encoding: Encoding.getByName("utf-8"),
    );
    if (response.statusCode == 200) {
      var response2 = await http.get(
        urlSA,
        headers: {"Authorization": 'Bearer $token'},
      );
      if (response2.statusCode == 200) {
        EasyLoading.dismiss();
        var savall = jsonDecode(response2.body);
        var data = savall["data"]['budget_allocations'];
        print(data);
        List res = data;
        setState(() {
          _data = res.map((data) => SavingAllserver.fromJson(data)).toList();
        });
        //Navigator.pop(context);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FSEducationAllocationSummary(data: _data),
          ),
        );
        Fluttertoast.showToast(
          backgroundColor: const Color(0xffE6C069),
          msg: 'Education Allocation has been updated',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        EasyLoading.dismiss();
        Fluttertoast.showToast(
          msg: 'Error E',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } else {
      EasyLoading.dismiss();
      Fluttertoast.showToast(
        msg: 'Error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}
