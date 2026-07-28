import 'package:GapHub/utils/dialog.dart';

DialogBox dialogBox = DialogBox();

whatError(statusCode, context, {message}) {
  // Navigator.pop(context);
  switch (statusCode) {
    case 400:
      if (message != null) {
        dialogBox.information(context, 'Error', '$message');
        return;
      }
      dialogBox.information(context, 'Error', 'Incorrect Details');
      break;
    case 401:
      dialogBox.information(context, 'Error', 'You are Unauthorized');
      break;
    case 405:
      dialogBox.information(context, 'Error', 'Wrong method used.');
      break;
    case 404:
      dialogBox.information(context, 'Error', 'Url/Data not found');
      break;
    case 422:
      dialogBox.information(context, 'Error', '422: Critical error');
      break;
    case 500:
      dialogBox.information(context, 'Error', 'Server Error');
      break;
    default:
      dialogBox.information(context, 'Error', '$message');
    // dialogBox.information(
    //     context, 'Error', 'Unable to process this information');
  }
}
