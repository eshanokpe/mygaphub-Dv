import 'dart:convert';

import 'package:GapHub/models/actionplanserver.dart';
import 'package:GapHub/models/analyticsinfo.dart';
import 'package:GapHub/models/chartsmodel.dart';
import 'package:GapHub/models/educationAllocationmodel.dart';
import 'package:GapHub/models/loginusermodel.dart';
import 'package:GapHub/models/remindermodel.dart';
import 'package:GapHub/models/savingAllocationmodel.dart';
import 'package:GapHub/models/savingAllocationserver.dart';
import 'package:GapHub/models/sevengeemodel.dart';
import 'package:GapHub/models/snapshotmodel.dart';
import 'package:GapHub/models/IncomeChartModel.dart';
import 'package:GapHub/screens/SEED/seedash/seedallocation/saving/saving_allocation.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:GapHub/models/AssetAcquisitionModel.dart';
import 'package:GapHub/models/AssetTypeModel.dart';

class Providers extends ChangeNotifier {
  Dio dio = Dio();

  Snapshotmodel snapshotmodel = Snapshotmodel(
    currency: '',
    financial: {},
    snapshot: {},
  );
  Sevengeemodel sevengeemodel = Sevengeemodel(
    steps: [],
    backgrounds: [],
    bespokes: [],
    total_bespoke: 0,
    questions: Questions(),
  );
  String fName = '';
  Loginusermodel loginDetails = Loginusermodel(
    id: 0,
    email: '',
    firstname: '',
    surname: '',
    phone: '',
    extra: '',
    emailVerifiedAt: '',
    createdAt: '',
    updatedAt: '',
    unseenNotifications: 0,
  );
  List savingAllocationDetails = [];
  String token = '';
  String personalSetup = '';
  String capdataType = '';
  String philanthropycurrency = '';
  double totMonExp = 0;
  double incAwayFromWage = 0;
  double rainySavings = 0;
  double expROCE = 0;
  double total = 0;
  double capToInv = 0;
  double statusTime = 0;
  double statusPercent = 0;
  String currencySymbol = '';
  Todayplanserver todayPlan = Todayplanserver(
    business: {},
    risk: {},
    intellectual: {},
    appreciating: {},
    depreciating: {},
  );
  Analyticsinfo analyticsinfo = Analyticsinfo(
    alpha: {},
    beta: {},
    credit: {},
    dept: {},
    education: {},
    freedom: {},
    grand: {},
  );
  List<ReminderModel> reminderList = [];
  List<SavAllocation> savingAllocationList = [];
  List<ReminderModel> archiveList = [];
  List<SavingAllocationmodel> savingList = [];
  List<EducationAllocationmodel> educationList = [];
  List<Actionplanmodel> actionPlanListB = [];
  List<Actionplanmodel> actionPlanListR = [];
  List<Actionplanmodel> actionPlanListA = [];
  List<Actionplanmodel> actionPlanListI = [];
  List<Actionplanmodel> actionPlanListD = [];
  List<String> details = [
    'N/A',
    'N/A',
    'N/A',
    'N/A',
    'N/A',
    'N/A',
    'N/A',
    'N/A',
    'N/A',
    'N/A',
    'N/A',
  ];
  bool newPort = false;
  bool archivedData = true;
  bool treesisty = true;
  bool liabilitiesunallocated = true;
  bool primaryRes = false;

  Map<String, dynamic> ganpCountryAssetList = {};
  List ganpCountryServerList = [];
  List recents = [];
  List<int> listofQueVal = [];
  List parameters = [];
  double alpha = 0;
  double beta = 0;
  double credit = 0;
  double debt = 0;
  double education = 0;
  double freedom = 0;
  double grand = 0;

  int colorAlpha = 0XFF3f48cc;
  int colorBeta = 0XFF3f48cc;
  int colorDebt = 0XFF000000;
  int colorCredit = 0XFF000000;
  int colorEducation = 0XFF000000;
  int colorFreedom = 0XFF000000;
  int colorGrand = 0XFF000000;
  int preference = 0;
  int liabilitiesbalance = 0;

  var savingsbalance;
  var educationbalance;
  var discretionarybalance;
  var discretionarytotalspentt;
  var accommadationbalance;
  var accommadationspent;
  var familybalance;
  var familyEtotalspent;
  var utilitybalance;
  var transportationbalance;
  var debt_repaymentbalance;

  List<Kpi> bespokeData = [];
  List mortgages = [];
  List mortgagesList = [];

  List favorites = [];
  List favoritesG = [];
  //income
  List incomeData = [];
  List incomesList = [];
  Map incomeDataLite = {};
  Map channelsData = {};
  int incomeallocated = 0;
  Map braidList = {};

  //liability
  List mapList = [];
  Map mapListLite = {};
  List sevengList = [];
  List bespokesList = [];
  List equityData = [];
  Map equityDataLite = {};
  Map mortgageInfo = {};

  //Philanthropy
  Map philanthropydata = {};
  Map notificationData = {};
  List supportData = [];
  List feedbackData = [];

  Map pensionsdata = {};
  Map assetsData = {};
  Map retiredata = {};
  Map nonporfolioData = {};
  List mortgageList = [];
  Map mortgageListLite = {};
  Map sevengitem = {};

  //cash
  List cashData = [];
  Map cashDataLite = {};
  List cashbespokes = [];
  List cashseveng = [];

  //equity
  // Map equityData = {};
  // Map equityDataDistribution = {};

  //Protection
  List protectionList = [];
  Map protectionListLite = {};
  Map protectionDistribution = {};

  List accommodationdata = [];

  //expenditure
  Map expenditureList = {};
  Map expenditureListLite = {};
  Map ilabdata = {};

  Map retarchivesData = {};
  Map retirementdetailsData = {};

  Map portfolio = {};
  Map settarget = {};

  List<String> assets = [];
  List mapAsset = [];
  double portfolioDiff = 0;
  var currentPortfolio;
  var recorddata;
  var invSum;
  var transactionSlabel;
  var transactionSlabel2;
  var transactionSdate;
  var transactionSnote;
  var incomesData;

  String? transactionSamounttext;
  int transactionSamount = 0;
  int transactionSallocationid = 0;
  int transactionSrecuring = 0;
  int transactionSspentcurrentmonth = 0;
  int transactionSspentlastmonth = 0;
  int transactionSbalance = 0;

  List countries = [];
  Map seedata = {};
  Map calculatorData = {};
  Map seedtarget = {};
  Map seedatabudget = {};
  Map dashdata = {};
  String currency = "";
  Map manualCurrency = {};
  Map systemCurrency = {};
  Map assistance = {};
  IncomeChartModel incomeChart = IncomeChartModel(
    periods: [],
    nonPortfolioValues: [],
    portfolioValues: [],
    hasImprove: false,
  );

  List<AssetAcquisition> assetAcquisition = [];

  List<AssetType> businessAssetType = [];
  List<AssetType> appreciatingAssetType = [];
  List<AssetType> intellectualAssetType = [];
  List<AssetType> riskAssetType = [];
  List<AssetType> depreciatingAssetType = [];

  dynamic httpData;

  addHttpData(dynamic data) {
    httpData = data;
    notifyListeners();
  }

  addAssetAcquisition(Map data) {
    addAssetType(data);
    var adjust = data["acquisition"];
    print("adjust:$adjust");
    for (var item in adjust) {
      assetAcquisition.add(AssetAcquisition.fromJson(item));
    }
    notifyListeners();
  }

  addAssetType(Map data) {
    var adjust = data["asset_types"];
    print("asset_types: $adjust ");

    businessAssetType = [];
    intellectualAssetType = [];
    riskAssetType = [];
    appreciatingAssetType = [];
    depreciatingAssetType = [];

    for (var item1 in adjust["business"]) {
      businessAssetType.add(AssetType.fromJson(item1));
    }

    for (var item2 in adjust["intellectual"]) {
      intellectualAssetType.add(AssetType.fromJson(item2));
    }

    for (var item3 in adjust["risk"]) {
      riskAssetType.add(AssetType.fromJson(item3));
    }

    for (var item4 in adjust["appreciating"]) {
      appreciatingAssetType.add(AssetType.fromJson(item4));
    }

    for (var item5 in adjust["depreciating"]) {
      depreciatingAssetType.add(AssetType.fromJson(item5));
    }

    notifyListeners();
  }

  setNewPort(bool a) {
    newPort = a;
    notifyListeners();
  }

  setAssistance(Map data) {
    assistance = data;
    notifyListeners();
  }

  setCurrency(String data) {
    currency = data;
    notifyListeners();
  }

  setManualCurrency(Map data) {
    manualCurrency = data;
    notifyListeners();
  }

  setSystemCurrency(Map data) {
    systemCurrency = data;
    notifyListeners();
  }

  setDashData(Map data) {
    dashdata = data;
    notifyListeners();
  }

  setSeeBudget(Map data) {
    seedatabudget = data;
    notifyListeners();
  }

  // *** Add this method ***
  void updateBudgetData(Map<String, dynamic> newData) {
    calculatorData.addAll(newData);
    notifyListeners();
  }

  setSeeData(Map data) {
    seedata = data;
    notifyListeners();
  }

  setCalculator(Map data) {
    calculatorData = data;
    notifyListeners();
  }

  String? _baseCurrency;

  String? get baseCurrency => _baseCurrency;

  void setBaseCurrency(String currency) {
    _baseCurrency = currency;
    notifyListeners();
  }

  incomesAccount(var data) {
    incomesData = data;
    notifyListeners();
  }

  setSeedTarget(Map data) {
    seedtarget = data;
    notifyListeners();
  }

  setCountries(List data) {
    countries = data;
    notifyListeners();
  }

  setCurrentPortfolio(var data) {
    currentPortfolio = data;
    notifyListeners();
  }

  setPortfolioDiff(double data) {
    portfolioDiff = data;
    notifyListeners();
  }

  setRecorddata(var data) {
    recorddata = data;
    notifyListeners();
  }

  setMapAsset(List data) {
    mapAsset = data;
    notifyListeners();
  }

  setAssets(List<String> data) {
    assets = data;
    notifyListeners();
  }

  //Record Spend
  setTransactionSlabel(var data) {
    transactionSlabel = data;
    notifyListeners();
  }

  setTransactionSlabel2(var data) {
    transactionSlabel2 = data;
    notifyListeners();
  }

  setTransactionSamount(int data) {
    transactionSamount = data;
    notifyListeners();
  }

  setTransactionSamounttext(String data) {
    transactionSamounttext = data;
    notifyListeners();
  }

  setTransactionSallocationid(int data) {
    transactionSallocationid = data;
    notifyListeners();
  }

  setTransactionSrecuring(int data) {
    transactionSrecuring = data;
    notifyListeners();
  }

  setTransactionSspentcurrentmonth(int data) {
    transactionSspentcurrentmonth = data;
    notifyListeners();
  }

  setTransactionSspentlastmonth(int data) {
    transactionSspentlastmonth = data;
    notifyListeners();
  }

  setTransactionSbalances(int data) {
    transactionSbalance = data;
    notifyListeners();
  }

  setTransactionSdate(var data) {
    transactionSdate = data;
    notifyListeners();
  }

  setTransactionSnote(var data) {
    transactionSnote = data;
    notifyListeners();
  }

  //iLab
  setSettarget(Map data) {
    settarget = data;
    notifyListeners();
  }

  setPortfolio(Map data) {
    portfolio = data;
    notifyListeners();
  }

  setFavorites(List favs) {
    favorites = favs;
    notifyListeners();
  }

  setFavoritesG(List favs) {
    favoritesG = favs;
    notifyListeners();
  }

  setSupport(List data) {
    supportData = data;
    notifyListeners();
  }

  setFeedback(List data) {
    feedbackData = data;
    notifyListeners();
  }

  setNotification(Map noti) {
    notificationData = noti;
    notifyListeners();
  }

  //income
  setincomeData(List incomeDatas) {
    incomeData = incomeDatas;
    notifyListeners();
  }

  setincomes(List incomes) {
    incomesList = incomes;
    notifyListeners();
  }

  setincomeDataLite(Map data) {
    incomeDataLite = data;
    notifyListeners();
  }

  setchannels(Map data) {
    channelsData = data;
    notifyListeners();
  }

  setallocated(int numb) {
    incomeallocated = numb;
    notifyListeners();
  }

  //Liabilitydetails

  setcap(String data) {
    capdataType = data;
    notifyListeners();
  }

  setbraid(Map data) {
    braidList = data;
    notifyListeners();
  }

  setinvSum(var data) {
    invSum = data;
    notifyListeners();
  }

  setequityList(List list) {
    equityData = list;
    notifyListeners();
  }

  setequityDetail(Map data) {
    equityDataLite = data;
    notifyListeners();
  }

  //setphilanList
  setphilanList(Map data) {
    philanthropydata = data;
    notifyListeners();
  }

  //Retiredash
  setretiredata(Map data) {
    retiredata = data;
    notifyListeners();
  }

  //nonporfolioData
  setnonporfolioData(Map data) {
    nonporfolioData = data;
    notifyListeners();
  }

  //savingsavailabelbalance
  savingsavailabelbalance(var data) {
    savingsbalance = data;
    notifyListeners();
  }

  //educationavailabelbalance
  educationavailabelbalance(var data) {
    educationbalance = data;
    notifyListeners();
  }

  //discretionaryavailabelbalance
  discretionaryavailabelbalance(var data) {
    discretionarybalance = data;
    notifyListeners();
  }

  //discretionarytotalspent
  discretionarytotalspent(var data) {
    discretionarytotalspentt = data;
    notifyListeners();
  }

  //accommadationavailabelbalance
  accommadationavailabelbalance(var data) {
    accommadationbalance = data;
    notifyListeners();
  }

  //accommadationtotalspent
  accommadationtotalspent(var data) {
    accommadationspent = data;
    notifyListeners();
  }

  //familyavailabelbalance
  familyavailabelbalance(var data) {
    familybalance = data;
    notifyListeners();
  }

  //familyavailabelbalance
  familytotalspent(var data) {
    familyEtotalspent = data;
    notifyListeners();
  }

  //utilityavailabelbalance
  utilityavailabelbalance(var data) {
    utilitybalance = data;
    notifyListeners();
  }

  //transportationavailabelbalance
  transportationavailabelbalance(var data) {
    transportationbalance = data;
    notifyListeners();
  }

  //debt_repaymentavailabelbalance
  debt_repaymentavailabelbalance(var data) {
    debt_repaymentbalance = data;
    notifyListeners();
  }

  //debt_repaymentavailabelbalance
  expen(var data) {
    accommodationdata = data;
    notifyListeners();
  }

  setpensions(Map data) {
    pensionsdata = data;
    notifyListeners();
  }

  setAssetsData(Map data) {
    assetsData = data;
    notifyListeners();
  }

  setRecent(List rec) {
    recents = rec;
    notifyListeners();
  }

  int _index = 0;
  List<SavingAllserver> _item = [];
  List<dynamic> get item => _item;

  allocationItem(List<SavingAllserver> value) {
    _item = value;
    notifyListeners();
  }

  int get index => _index;
  allocationIndex(int value) {
    _index = value;
    notifyListeners();
  }

  setMortgages(List mort) {
    mortgages = mort;
    notifyListeners();
  }

  setMortgagesList(List mort) {
    mortgagesList = mort;
    notifyListeners();
  }

  setBespokeData(Kpi kpi) {
    bespokeData.insert(0, kpi);
    notifyListeners();

    // bespokeData.removeLast();
  }

  setPref(int numb) {
    preference = numb;
    notifyListeners();
  }

  setLiabilitiesbalance(int numb) {
    liabilitiesbalance = numb;
    notifyListeners();
  }

  setLiabilitiesunallocated(bool a) {
    liabilitiesunallocated = a;
    notifyListeners();
  }

  setprimaryRes(bool a) {
    primaryRes = a;
    notifyListeners();
  }

  setGanpCountryServer(List ganp) {
    ganpCountryServerList = ganp;
    notifyListeners();
  }

  setGanpCountryAssetServer(Map<String, dynamic> assets) {
    ganpCountryAssetList = assets;
    notifyListeners();
  }

  setDetailsList(String item, int index) {
    details[index] = item;
    notifyListeners();
  }

  setAnalyticsInfo(Analyticsinfo info) {
    analyticsinfo = info;
    notifyListeners();
  }

  setPersonalSetup(String text) {
    personalSetup = text;
    notifyListeners();
  }

  setTodayPlan(Todayplanserver today) {
    todayPlan = today;
    notifyListeners();
  }

  setSnapshot(Snapshotmodel snapshot) {
    snapshotmodel = snapshot;
    notifyListeners();
  }

  // void updateSnapshotCurrency(String newCurrency) {
  //   snapshotmodel = snapshotmodel.copyWith(
  //     currency: newCurrency,
  //   );
  //   notifyListeners();
  // }

  setSevenGee(Sevengeemodel sevengee) {
    sevengeemodel = sevengee;
    notifyListeners();
  }

  setLoginDetails(Loginusermodel details) {
    loginDetails = details;
    notifyListeners();
  }

  //Allocation
  setsavingAllocation(List details) {
    savingAllocationDetails = details;
    notifyListeners();
  }

  seToken(String finalToken) {
    token = finalToken;
    notifyListeners();
  }

  setcurrency(String currency) {
    philanthropycurrency = currency;
    notifyListeners();
  }

  //Mortgagedetails
  setsevengitem(String index) {
    sevengitem[index] = index;
    notifyListeners();
  }

  //Protection
  setProtectionList(List list) {
    protectionList = list;
    notifyListeners();
  }

  setProtectionListLite(Map data) {
    protectionListLite = data;
    notifyListeners();
  }

  setProtectionDistribution(Map data) {
    protectionDistribution = data;
    notifyListeners();
  }

  //protection
  setExpenditureList(Map data) {
    expenditureList = data;
    notifyListeners();
  }

  setExpenditureListLite(Map data) {
    expenditureListLite = data;
    notifyListeners();
  }

  setIlabdata(Map data) {
    ilabdata = data;
    notifyListeners();
  }

  //Retirement
  setretarchivesData(Map data) {
    retarchivesData = data;
    notifyListeners();
  }

  setretirementdetailsData(Map data) {
    retirementdetailsData = data;
    notifyListeners();
  }

  settreesisty(bool a) {
    treesisty = a;
    notifyListeners();
  }

  setarchivedData(bool a) {
    archivedData = a;
    notifyListeners();
  }

  // setEquityData(Map data) {
  //   equityData = data;
  //   notifyListeners();
  // }

  // setEquityDataDistribution(Map data) {
  //   equityDataDistribution = data;
  //   notifyListeners();
  // }

  //cash
  setcashData(List list) {
    cashData = list;
    notifyListeners();
  }

  setcashDataLite(Map data) {
    cashDataLite = data;
    notifyListeners();
  }

  setcashseveng(List list) {
    cashseveng = list;
    notifyListeners();
  }

  setcashbespokes(List list) {
    cashbespokes = list;
    notifyListeners();
  }

  setTotMonthly(double monthly) {
    totMonExp = monthly;
    notifyListeners();
  }

  setRainy(double rainy) {
    rainySavings = rainy;
    notifyListeners();
  }

  setAlpha(setAlpha) {
    alpha = setAlpha;
    notifyListeners();
  }

  setBeta({setBeta, color}) {
    beta = setBeta;
    colorBeta = color;
    notifyListeners();
  }

  setCredit({setCredit, color}) {
    credit = setCredit;
    colorCredit = color;
    notifyListeners();
  }

  setDebt({setDebt, color}) {
    debt = setDebt;
    colorDebt = color;
    notifyListeners();
  }

  setEducation({setEducation, color}) {
    education = setEducation;
    colorEducation = color;
    notifyListeners();
  }

  setFreedom({setFreedom, color}) {
    freedom = setFreedom;
    colorFreedom = color;
    notifyListeners();
  }

  setGrand({setGrand, color}) {
    grand = setGrand;
    notifyListeners();
  }

  setQueVal(List<int> queVal) {
    listofQueVal = queVal;
    notifyListeners();
  }

  setParameters(List para) {
    parameters = para;
    notifyListeners();
  }

  setIncFromWage(double incfrmwage) {
    incAwayFromWage = incfrmwage;
    notifyListeners();
  }

  setStatusTime() {
    statusTime = (rainySavings * 30) / totMonExp;
    notifyListeners();
  }

  setStatusPercent() {
    statusPercent = (incAwayFromWage * 100) / totMonExp;
    notifyListeners();
  }

  setSymbol(String currency) {
    currencySymbol = currency;
    notifyListeners();
  }

  setROCE(double roce) {
    expROCE = roce;
    notifyListeners();
  }

  setCapToInv() {
    capToInv = ((totMonExp * 12) * 100) / expROCE;
    notifyListeners();
  }

  addReminder(ReminderModel remindermodel) {
    reminderList.add(remindermodel);
    notifyListeners();
  }

  addSavingAllocation(SavingAllocationmodel savingmodel) {
    savingList.add(savingmodel);
    notifyListeners();
  }

  addEducationAllocation(EducationAllocationmodel educationmodel) {
    educationList.add(educationmodel);
    notifyListeners();
  }

  deleteReminder() {
    reminderList.clear();
    notifyListeners();
  }

  deleteSavingAllocation() {
    savingList.clear();
    notifyListeners();
  }

  deleteEducationAllocation() {
    educationList.clear();
    notifyListeners();
  }

  addArchives(ReminderModel remindermodel) {
    archiveList.add(remindermodel);
    notifyListeners();
  }

  deleteArchives() {
    archiveList.clear();
    notifyListeners();
  }

  addActionPlanB(Actionplanmodel actionplanmodel) {
    actionPlanListB.add(actionplanmodel);
    notifyListeners();
  }

  popActionPlanB() {
    actionPlanListB.clear();
    notifyListeners();
  }

  addActionPlanR(Actionplanmodel actionplanmodel) {
    actionPlanListR.add(actionplanmodel);
    notifyListeners();
  }

  popActionPlanR() {
    actionPlanListR.clear();
    notifyListeners();
  }

  addActionPlanA(Actionplanmodel actionplanmodel) {
    actionPlanListA.add(actionplanmodel);
    notifyListeners();
  }

  popActionPlanA() {
    actionPlanListA.clear();
    notifyListeners();
  }

  addActionPlanI(Actionplanmodel actionplanmodel) {
    actionPlanListI.add(actionplanmodel);
    notifyListeners();
  }

  popActionPlanI() {
    actionPlanListI.clear();
    notifyListeners();
  }

  addActionPlanD(Actionplanmodel actionplanmodel) {
    actionPlanListD.add(actionplanmodel);
    notifyListeners();
  }

  popActionPlanD() {
    actionPlanListD.clear();
    notifyListeners();
  }

  addIncomeChart(model) {
    incomeChart = IncomeChartModel.fromJson(model);
    notifyListeners();
  }

  void updateFirstName(String newName) {
    details[0] = newName;
    notifyListeners();
  }

  void updateLastName(String newName) {
    details[1] = newName;
    notifyListeners();
  }

  void updatePhoneNumber(String newName) {
    details[3] = newName;
    notifyListeners();
  }

  void updateDateOfBirth(String newDob) {
    if (details.length > 4) {
      details[4] = newDob;
    } else {
      // Safety fallback if list isn't initialized properly
      while (details.length <= 4) {
        details.add('');
      }
      details[4] = newDob;
    }
    notifyListeners(); // ✅ CRITICAL: Triggers context.watch<Providers>() rebuild
  }

  // In your Providers class
  void updateCountry(String countryName) {
    // Store both name and flag
    details[6] = countryName; // Or use a different approach
    notifyListeners();
  }

  void clearAllData() {
    // Reset all variables to their initial values

    // Basic data
    snapshotmodel = Snapshotmodel(currency: '', financial: {}, snapshot: {});

    sevengeemodel = Sevengeemodel(
      steps: [],
      backgrounds: [],
      bespokes: [],
      total_bespoke: 0,
      questions: Questions(),
    );

    fName = '';
    loginDetails = Loginusermodel(
      id: 0,
      email: '',
      firstname: '',
      surname: '',
      phone: '',
      extra: '',
      emailVerifiedAt: '',
      createdAt: '',
      updatedAt: '',
      unseenNotifications: 0,
    );

    savingAllocationDetails = [];
    token = '';
    capdataType = '';
    philanthropycurrency = '';
    totMonExp = 0;
    incAwayFromWage = 0;
    rainySavings = 0;
    expROCE = 0;
    total = 0;
    capToInv = 0;
    statusTime = 0;
    statusPercent = 0;
    currencySymbol = '';

    todayPlan = Todayplanserver(
      business: {},
      risk: {},
      intellectual: {},
      appreciating: {},
      depreciating: {},
    );

    analyticsinfo = Analyticsinfo(
      alpha: {},
      beta: {},
      credit: {},
      dept: {},
      education: {},
      freedom: {},
      grand: {},
    );

    // Clear all lists
    reminderList = [];
    savingAllocationList = [];
    archiveList = [];
    savingList = [];
    educationList = [];
    actionPlanListB = [];
    actionPlanListR = [];
    actionPlanListA = [];
    actionPlanListI = [];
    actionPlanListD = [];

    details = [
      'N/A',
      'N/A',
      'N/A',
      'N/A',
      'N/A',
      'N/A',
      'N/A',
      'N/A',
      'N/A',
      'N/A',
      'N/A',
    ];

    newPort = false;
    archivedData = true;
    treesisty = true;
    liabilitiesunallocated = true;
    primaryRes = false;

    ganpCountryAssetList = {};
    ganpCountryServerList = [];
    recents = [];
    listofQueVal = [];
    parameters = [];
    alpha = 0;
    beta = 0;
    credit = 0;
    debt = 0;
    education = 0;
    freedom = 0;
    grand = 0;

    // Reset colors
    colorAlpha = 0XFF3f48cc;
    colorBeta = 0XFF3f48cc;
    colorDebt = 0XFF000000;
    colorCredit = 0XFF000000;
    colorEducation = 0XFF000000;
    colorFreedom = 0XFF000000;
    colorGrand = 0XFF000000;
    preference = 0;
    liabilitiesbalance = 0;

    // Reset balances
    savingsbalance = null;
    educationbalance = null;
    discretionarybalance = null;
    discretionarytotalspentt = null;
    accommadationbalance = null;
    accommadationspent = null;
    familybalance = null;
    familyEtotalspent = null;
    utilitybalance = null;
    transportationbalance = null;
    debt_repaymentbalance = null;

    bespokeData = [];
    mortgages = [];
    mortgagesList = [];
    favorites = [];
    favoritesG = [];

    // Income data
    incomeData = [];
    incomesList = [];
    incomeDataLite = {};
    channelsData = {};
    incomeallocated = 0;
    braidList = {};

    // Liability data
    mapList = [];
    mapListLite = {};
    sevengList = [];
    bespokesList = [];
    equityData = [];
    equityDataLite = {};
    mortgageInfo = {};

    // Philanthropy
    philanthropydata = {};
    notificationData = {};
    supportData = [];
    feedbackData = [];

    pensionsdata = {};
    retiredata = {};
    nonporfolioData = {};
    mortgageList = [];
    mortgageListLite = {};
    sevengitem = {};

    // Cash
    cashData = [];
    cashDataLite = {};
    cashbespokes = [];
    cashseveng = [];

    // Protection
    protectionList = [];
    protectionListLite = {};
    accommodationdata = [];

    // Expenditure
    expenditureList = {};
    expenditureListLite = {};
    ilabdata = {};

    retarchivesData = {};
    retirementdetailsData = {};

    portfolio = {};
    settarget = {};
    assets = [];
    mapAsset = [];
    portfolioDiff = 0;
    currentPortfolio = null;
    recorddata = null;
    invSum = null;

    // Transaction data
    transactionSlabel = null;
    transactionSlabel2 = null;
    transactionSdate = null;
    transactionSnote = null;
    incomesData = null;
    transactionSamounttext = null;
    transactionSamount = 0;
    transactionSallocationid = 0;
    transactionSrecuring = 0;
    transactionSspentcurrentmonth = 0;
    transactionSspentlastmonth = 0;
    transactionSbalance = 0;

    countries = [];
    seedata = {};
    calculatorData = {};
    seedtarget = {};
    seedatabudget = {};
    dashdata = {};
    // currency = "";
    manualCurrency = {};
    systemCurrency = {};
    assistance = {};

    incomeChart = IncomeChartModel(
      periods: [],
      nonPortfolioValues: [],
      portfolioValues: [],
      hasImprove: false,
    );

    assetAcquisition = [];
    businessAssetType = [];
    appreciatingAssetType = [];
    intellectualAssetType = [];
    riskAssetType = [];
    depreciatingAssetType = [];

    httpData = null;
    _baseCurrency = null;

    // Clear item list and index
    _item = [];
    _index = 0;

    notifyListeners();
  }
}
