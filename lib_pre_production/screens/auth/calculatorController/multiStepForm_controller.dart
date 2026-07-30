import 'package:get/get.dart';
import 'package:GapHub/models/calculatormodel.dart';

class MultiStepController extends GetxController {
  var currentPageIndex = 0.obs;

  var parameters = Calculatormodel(
    currency: '0',
    periodic: '0',
    education: '0',
    mortgage: '0',
    mobility: '0',
    expenses: '0',
    utility: '0',
    debtRepay: '0',
    charity: '0',
    extraSave: '0',
    otherIncome: '0',
  ).obs;

  void updateParameters(Calculatormodel newParams) {
    parameters.value = newParams;
  }

  void nextPage() {
    currentPageIndex.value++;
  }

  void previousPage() {
    if (currentPageIndex.value > 0) {
      currentPageIndex.value--;
    }
  }
}
