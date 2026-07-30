import 'package:GapHub/models/analyticsinfo.dart';
import 'package:GapHub/models/chartsmodel.dart';
import 'package:GapHub/provider/reminderProvider.dart';
import 'package:GapHub/screens/acquisition/preacquisition.dart';
import 'package:GapHub/screens/more/moreHeader.dart';
import 'package:GapHub/screens/portfolio/portdashboard.dart';
import 'package:GapHub/screens/more/more.dart';
import 'package:GapHub/screens/analytics/kpistab.dart';
import 'package:GapHub/screens/portfolio/widget/portfolio_header.dart';
import 'package:GapHub/widgets/customAnimatedBottomNav.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/analytics/analytics.dart';
import 'package:GapHub/screens/homepage/homepage.dart';
import 'package:nimble_charts/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../analytics/analytic_header.dart';
import '../../analytics/tab/bespoke_KPI.dart';
import '../../homepage/widget/homepage_header.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key, required this.index});

  final int index;

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final Key _pageStrKey1 = const PageStorageKey('pageOne');
  final Key _pageStrKey2 = const PageStorageKey('pageTwo');
  final Key _pageStrKey3 = const PageStorageKey('pageThree');
  final Key _pageStrKey4 = const PageStorageKey('pageFour');
  final Key _pageStrKey5 = const PageStorageKey('pageFive');
  final Key _pageStrKey6 = const PageStorageKey('pagesix');

  List<charts.Series<Kpi, String>> _seriesData = [];

  PageStorageBucket bucket = PageStorageBucket();
  bool _hasFetchedStartupReminders = false;

  var page1, page2, noNeedPage;
  int currentTabIndex = 0;
  DialogBox dialogBox = DialogBox();
  pop() {
    SystemNavigator.pop();
  }

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 4), () {
      // AppLock.of(context).enable();
    });
    super.initState();
    currentTabIndex = widget.index ?? 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchStartupRemindersIfNeeded();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchStartupRemindersIfNeeded();
  }

  void _fetchStartupRemindersIfNeeded() {
    if (!mounted || _hasFetchedStartupReminders) return;

    final currency = context.read<Providers>().snapshotmodel.currency;
    if (currency.isEmpty) return;

    _hasFetchedStartupReminders = true;
    context.read<ReminderProvider>().fetchReminders(currency);
  }

  @override
  Widget build(BuildContext context) {
    var geere = context.watch<Providers>().sevengeemodel.steps;

    var colors = context.watch<Providers>().sevengeemodel.backgrounds;
    List<String> sevenGees = [];
    List<String> sevenGeesColor = [];
    List<String> sevenGeesColors = [];
    List<int> realColors = [];
    for (var a in geere) {
      sevenGees.add(a.toString());
    }
    for (var a in colors) {
      sevenGeesColor.add(a.toString().substring(1));
    }

    for (var a in sevenGeesColor) {
      sevenGeesColors.add('0xff$a');
    }
    for (var a in sevenGeesColors) {
      realColors.add(int.parse(a));
    }

    // bool contains = realColors.contains(0xff494949);
    double alpha = double.parse(sevenGees[6]);
    double beta = double.parse(sevenGees[5]);
    double credit = double.parse(sevenGees[4]);
    double debt = double.parse(sevenGees[3]);
    double education = double.parse(sevenGees[2]);
    double freedom = double.parse(sevenGees[1]);
    double grand = double.parse(sevenGees[0]);

    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    final sliderKey = GlobalKey();
    Text empty = const Text('');
    Text g = const Text('Grand', textAlign: TextAlign.left);
    Text f = const Text('Freedom', textAlign: TextAlign.left);
    Text e = const Text('Education', textAlign: TextAlign.left);
    Text d = const Text('Debt', textAlign: TextAlign.left);
    Text c = const Text('Credit', textAlign: TextAlign.left);
    Text b = const Text('Beta', textAlign: TextAlign.left);
    Text a = const Text('Alpha', textAlign: TextAlign.left);

    _seriesData = [];
    final analyticsInfoFromProvider = context.watch<Providers>().analyticsinfo;

    _seriesData.add(
      charts.Series(
        data: [
          Kpi(
            kpi: g,
            value: grand,
            gradientColors: [const Color(0xffff0001), const Color(0xffCE0001)],
          ),
          Kpi(
            kpi: f,
            value: freedom,
            gradientColors: [const Color(0xffff0001), const Color(0xffCE0001)],
          ),
          Kpi(
            kpi: e,
            value: education,
            gradientColors: [const Color(0xffF6AE39), const Color(0xffFF7A00)],
          ),
          Kpi(
            kpi: d,
            value: debt,
            gradientColors: [const Color(0xffF6AE39), const Color(0xffFF7A00)],
          ),
          Kpi(
            kpi: c,
            value: credit,
            gradientColors: [const Color(0xff005E32), const Color(0xff17B26A)],
          ),
          Kpi(
            kpi: b,
            value: beta,
            gradientColors: [const Color(0xff005E32), const Color(0xff17B26A)],
          ),
          Kpi(
            kpi: a,
            value: alpha,
            gradientColors: [const Color(0xff005E77), const Color(0xff002E77)],
          ),
          // Kpi(kpi: '', value: 100, colorVal: 0xfffffff)
        ],
        domainFn: (Kpi kpi, _) => kpi.kpi.data.toString(),
        measureFn: (Kpi kpi, _) => kpi.value,
        colorFn: (Kpi kpi, _) =>
            charts.ColorUtil.fromDartColor((kpi.gradientColors.first)),
        outsideLabelStyleAccessorFn: (Kpi kpi, _) => charts.TextStyleSpec(
          color: charts.MaterialPalette.red.shadeDefault,
        ),
        fillPatternFn: (_, __) => charts.FillPatternType.solid,
        id: '7G KPI',

        // domainLowerBoundFn: (datum, index) => datum.kpi.data,
        labelAccessorFn: (Kpi kpi, _) => '${(kpi.value).toInt()}%',
      ),
    );
    // var mainValue = context.watch<Providers>().analyticsinfo.grand;
    final Map<String, dynamic> sectionDataMap = {
      "Grand": analyticsInfoFromProvider.grand?['main'],
      "Freedom": analyticsInfoFromProvider.freedom?['main'],
      "Education": analyticsInfoFromProvider.education?['main'],
      "Debt": analyticsInfoFromProvider.dept?['main'],
      "Credit": analyticsInfoFromProvider.credit?['main'],
      "Beta": analyticsInfoFromProvider.beta?['main'],
      "Alpha": analyticsInfoFromProvider.alpha?['main'],
    };
    final newUserAnalytics = sectionDataMap.values.every(
      (value) => value != null && value.toString() == '1',
    );
    print("newUserAnalytics: $newUserAnalytics");

    final tabPages = <Widget>[
      Analytics(
        key: _pageStrKey2,
        height: height,
        newUserAnalytics: newUserAnalytics,
        average:
            (alpha + beta + credit + debt + education + freedom + grand) / 7,
        realColors: realColors,
        seriesData: _seriesData,
        width: width,
      ),
      BespokeKPI(key: _pageStrKey6),
    ];

    final pages = <Widget>[
      Homepage(
        key: _pageStrKey1,
        width: width,
        height: height,
        newUserAnalytics: newUserAnalytics,
        analyticsInfo: analyticsInfoFromProvider,
        sliderKey: sliderKey,
        realColors: realColors,
      ),
      _buildAnalyticsOrKpis(
        newUser: newUserAnalytics,
        height: height,
        width: width,
        tabPages: tabPages,
        realColors: realColors,
        seriesData: _seriesData,
        alpha: alpha,
        beta: beta,
        credit: credit,
        debt: debt,
        education: education,
        freedom: freedom,
        grand: grand,
      ),
      Preacquisition(key: _pageStrKey3),
      Portdashboard(key: _pageStrKey4),
      More(key: _pageStrKey5),
    ];

    // Replace your current bottomItems list with this:

    final bottomItems = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: CustomAnimatedBottomNav(
          isActive: currentTabIndex == 0,
          onTap: () {
            setState(() {
              currentTabIndex = 0;
            });
          },
          child: Image.asset('assets/images/snapshotFFF.png', height: 20.h),
        ),
        activeIcon: CustomAnimatedBottomNav(
          isActive: currentTabIndex == 0,
          onTap: () {
            setState(() {
              currentTabIndex = 0;
            });
          },
          child: Image.asset('assets/images/snapshot000.png', height: 22.h),
        ),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: CustomAnimatedBottomNav(
          isActive: currentTabIndex == 1,
          onTap: () {
            setState(() {
              currentTabIndex = 1;
            });
          },
          child: Image.asset('assets/images/analyticsFFF.png', height: 20.h),
        ),
        activeIcon: CustomAnimatedBottomNav(
          isActive: currentTabIndex == 1,
          onTap: () {
            setState(() {
              currentTabIndex = 1;
            });
          },
          child: Image.asset('assets/images/analytics000.png', height: 22.h),
        ),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: CustomAnimatedBottomNav(
          isActive: currentTabIndex == 2,
          onTap: () {
            setState(() {
              currentTabIndex = 2;
            });
          },
          child: Image.asset('assets/images/acquisitionFFF.png', height: 20.h),
        ),
        activeIcon: CustomAnimatedBottomNav(
          isActive: currentTabIndex == 2,
          onTap: () {
            setState(() {
              currentTabIndex = 2;
            });
          },
          child: Image.asset('assets/images/acquisition000.png', height: 22.h),
        ),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: CustomAnimatedBottomNav(
          isActive: currentTabIndex == 3,
          onTap: () {
            setState(() {
              currentTabIndex = 3;
            });
          },
          child: Image.asset('assets/images/portfolioFFF.png', height: 20.h),
        ),
        activeIcon: CustomAnimatedBottomNav(
          isActive: currentTabIndex == 3,
          onTap: () {
            setState(() {
              currentTabIndex = 3;
            });
          },
          child: Image.asset('assets/images/portfolio000.png', height: 22.h),
        ),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: CustomAnimatedBottomNav(
          isActive: currentTabIndex == 4,
          onTap: () {
            setState(() {
              currentTabIndex = 4;
            });
          },
          child: Image.asset('assets/images/more000.png', height: 20.h),
        ),
        activeIcon: CustomAnimatedBottomNav(
          isActive: currentTabIndex == 4,
          onTap: () {
            setState(() {
              currentTabIndex = 4;
            });
          },
          child: Image.asset('assets/images/more000.png', height: 22.h),
        ),
        label: '',
      ),
    ];
    PreferredSizeWidget? appBar() {
      switch (currentTabIndex) {
        case 0:
          return HomePageHeader(sliderKey: sliderKey);

        case 1:
          return AnalyticHeader(newUserAnalytics: newUserAnalytics);

        case 2:
          break;
        case 3:
          return PortfolioHeader();

        case 4:
          return const MoreHeader();

        default:
          return null;
      }
      return null;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: WillPopScope(
        onWillPop: () {
          return dialogBox.options(
            context,
            'Exit',
            'Are you sure you want to exit?',
            pop,
          );
        },
        child: PageStorage(bucket: bucket, child: pages[currentTabIndex]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: width * .04,
        unselectedFontSize: width * .03,
        items: bottomItems,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentTabIndex,
        // onTap: (index) {
        //   setState(() {
        //     currentTabIndex = index;
        //   });
        // },
      ),
    );
  }

  Widget _buildAnalyticsOrKpis({
    required bool newUser,
    required double height,
    required double width,
    required List<Widget> tabPages,
    required List<int> realColors,
    required List<charts.Series<Kpi, String>> seriesData,
    required double alpha,
    required double beta,
    required double credit,
    required double debt,
    required double education,
    required double freedom,
    required double grand,
  }) {
    try {
      if (!newUser) {
        final average =
            (alpha + beta + credit + debt + education + freedom + grand) / 7;
        return Analytics(
          key: _pageStrKey2,
          height: height,
          newUserAnalytics: newUser,
          average: average,
          realColors: realColors,
          seriesData: seriesData,
          width: width,
          tabPages: tabPages,
        );
      } else {
        return Kpistab(
          tabPages: tabPages,
          height: height,
          width: width,
          contains: newUser,
        );
      }
    } catch (e) {
      // Fallback widget if something goes wrong
      return Center(
        child: Text(
          'Error loading content: ${e.toString()}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
  }
}

class ListClass1 extends StatefulWidget {
  const ListClass1({super.key});

  @override
  ListClass1State createState() => ListClass1State();
}

class ListClass1State extends State<ListClass1> {
  var pageStrKey1 = const PageStorageKey('view1');
  var pageStrkey2 = const PageStorageKey('view2');
  final PageStorageBucket _bucket2 = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    return PageStorage(
      bucket: _bucket2,
      child: Container(
        child: Column(
          children: [
            Container(
              width: 400,
              height: 140,
              color: Colors.green,
              child: ListView.builder(
                key: pageStrKey1,
                itemCount: 10,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListClass2 extends StatefulWidget {
  const ListClass2({super.key});

  @override
  ListClass2State createState() => ListClass2State();
}

class ListClass2State extends State<ListClass2> {
  final PageStorageBucket _bucket3 = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    return PageStorage(
      bucket: _bucket3,
      child: SizedBox(
        width: 400,
        height: 140,
        child: ListView.builder(
          itemExtent: 250.0,
          itemBuilder: (context, index) => Container(
            padding: const EdgeInsets.all(10.0),
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(5.0),
              color: index % 2 == 0 ? Colors.cyan : Colors.deepOrange,
              child: Center(child: Text(index.toString())),
            ),
          ),
        ),
      ),
    );
  }
}

class Data {
  final int id;
  bool expanded;
  final String title;
  Data(this.id, this.expanded, this.title);
}
