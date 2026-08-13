import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:GapHub/utils/extensions.dart';

import 'quickstartguide.dart';

class Support extends StatefulWidget {
  const Support({super.key});

  @override
  _Support createState() => _Support();
}

class _Support extends State<Support> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Support",
          style: TextStyle(
            color: Colors.white,
            fontSize: width * .035,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: true,
        centerTitle: true,
      ),
      body: SafeArea(
        child: CupertinoScrollbar(
          thumbVisibility: true,
          thickness: context.width(.015),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.width(.03)),
            child: ListView(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Choose from any of our support services ...',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: context.width(.045),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuickStartGuide(),
                      ),
                    );
                  },
                  leading: Image.asset("assets/images/guide.png"),
                  title: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Quick Start Guide',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                        fontSize: context.width(.05),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                ListTile(
                  leading: Image.asset("assets/images/faq.png"),
                  title: Center(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Frequently Asked Questions',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                          fontSize: context.width(.05),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                ListTile(
                  leading: Image.asset("assets/images/askaquestion.png"),
                  title: Center(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Ask a Question',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                          fontSize: context.width(.05),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                ListTile(
                  leading: Image.asset("assets/images/terms.png"),
                  title: Center(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Terms & Conditions',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                          fontSize: context.width(.05),
                        ),
                      ),
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
}
