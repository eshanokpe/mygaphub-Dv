import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DialogBox {
  information(
    BuildContext context,
    String title,
    String description, {
    Function? no,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * .04,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              // ignore: unnecessary_null_comparison
              onPressed: () => no != null ? no() : Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  waiting(BuildContext context, String description) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () => Future.value(false),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.85,
                minWidth: MediaQuery.of(context).size.width * 0.3,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CircularProgressIndicator(
                        color: Colors.grey[500],
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      SizedBox(
                        width: 20.w,
                      ), // Use ScreenUtil for consistent sizing
                      // Wrap Text in Expanded to prevent overflow
                      Expanded(
                        child: Text(
                          description,
                          style: const TextStyle(
                            fontWeight: FontWeight.w300,
                            color: Colors.black,
                          ),
                          softWrap: true, // Allow text to wrap
                          overflow: TextOverflow.visible, // Allow wrapping
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void waiting22(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
              minWidth: MediaQuery.of(context).size.width * 0.3,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 3.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    // Use Expanded to prevent overflow
                    Expanded(
                      child: Text(
                        message,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        maxLines: 2, // Limit to 2 lines
                        overflow:
                            TextOverflow.ellipsis, // Add ellipsis if needed
                      ),
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

  options(
    BuildContext context,
    String title,
    String description,
    Function yes,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        Orientation orientation = MediaQuery.of(context).orientation;
        final width = orientation == Orientation.portrait
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.height;

        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'No',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text(
                'Yes',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                yes();
              },
            ),
          ],
        );
      },
    );
  }
}
