import 'package:GapHub/provider/acquisiProvider.dart';
import 'package:GapHub/provider/acquisitionProvider.dart';
import 'package:GapHub/models/propertyModel.dart';
import 'package:GapHub/screens/acquisition/reap/search/search.dart';
import 'package:GapHub/screens/acquisition/reap/search/search_category.dart';
import 'package:GapHub/widgets/avatarImage.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'widget/acquisition_list.dart';

class ReapList extends StatefulWidget {
  final String category;
  const ReapList({super.key, required this.category});

  @override
  State<ReapList> createState() => _ReapListState();
}

class _ReapListState extends State<ReapList> {
  List<PropertyModel> properties = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AcquisitionProvider>();
      provider.fetchProperties(widget.category); // Then fetch
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcquisitionProvider>();

    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
          actions: const [AvatarImage()],
        ),
        backgroundColor: const Color(0XFFF6F6F6),
        bottomNavigationBar: const BottomNav(2),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: width * .03),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Search(),
                  SizedBox(height: height * .01),
                  SearchCategory(),
                  SizedBox(height: height * .01),
                  Consumer<AcquisiProvider>(
                    builder: (context, provider, _) => Text(
                      '${provider.filteredPropertiesLength} properties match your specifications',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        color: const Color(0xff434343),
                      ),
                    ),
                  ),
                  SizedBox(height: height * .01),
                  AcquisitionList(category: widget.category),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
