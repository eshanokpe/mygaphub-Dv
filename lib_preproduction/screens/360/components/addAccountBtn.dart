import 'package:GapHub/screens/360/addaccount.dart';
import 'package:GapHub/screens/360/decider.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Addaccountbtn extends StatelessWidget {
  const Addaccountbtn({super.key, required this.index});

  final String index;

  @override
  Widget build(BuildContext context) {
    void dropdown() {
      showDialog(context: context, builder: (context) => const Addaccount());
    }

    return GestureDetector(
      onTap: () {
        switch (index) {
          case "Protection":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Decider("Protection")),
            );
            break;
          case "protection":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Decider("Protection")),
            );
            break;
          case "Mortgage":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Decider("Mortgage")),
            );
            break;
          case "Liabilities":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Decider("Liabilities")),
            );
            break;
          case "Cash":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Decider("Cash")),
            );
            break;
          case "Assets":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Decider("Assets")),
            );
            break;
          case "Income":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Decider("Income")),
            );
            break;
          default:
            dropdown();
        }
      },

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add, color: AppColors.primaryColor),
          const SizedBox(width: 6),
          Text(
            "Add Account",
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
