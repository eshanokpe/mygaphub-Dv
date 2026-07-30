import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../add_pension.dart';

class CategoryOfPensionModel {
  final String title;
  final String imagePath;
  const CategoryOfPensionModel({required this.title, required this.imagePath});
}

class CategoryOfPensionScreen extends StatefulWidget {
  final VoidCallback? onRefresh; // ✅ 1. Add this parameter

  const CategoryOfPensionScreen({
    super.key,
    this.onRefresh,
  }); // ✅ 2. Initialize it

  static const List<CategoryOfPensionModel> _categories = [
    CategoryOfPensionModel(
      title: 'Private Pension',
      imagePath: 'assets/wheel_segments/private_pension.png',
    ),
    CategoryOfPensionModel(
      title: 'State Pension',
      imagePath: 'assets/wheel_segments/state_pension.png',
    ),
    CategoryOfPensionModel(
      title: 'Employer Pension',
      imagePath: 'assets/wheel_segments/employer_pension.png',
    ),
    CategoryOfPensionModel(
      title: 'Others',
      imagePath: 'assets/wheel_segments/others_pension.png',
    ),
  ];

  @override
  State<CategoryOfPensionScreen> createState() =>
      _CategoryOfPensionScreenState();
}

class _CategoryOfPensionScreenState extends State<CategoryOfPensionScreen> {
  bool _imagesPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPrecached) {
      _imagesPrecached = true;
      for (final category in CategoryOfPensionScreen._categories) {
        precacheImage(AssetImage(category.imagePath), context);
      }
    }
  }

  Future<bool> _handleWillPop(BuildContext context) async {
    Navigator.pop(context);
    Navigator.pop(context);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    const categories = CategoryOfPensionScreen._categories;

    return WillPopScope(
      onWillPop: () => _handleWillPop(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 0.0, top: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.chevron_left, size: 28),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category of Pension',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select a Category',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: categories.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    thickness: 0.8,
                    indent: 20,
                    endIndent: 20,
                    color: Color(0xFFEEEEEE),
                  ),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _CategoryTile(
                      category: category,
                      onRefresh: widget.onRefresh, // ✅ 3. Pass it to the tile
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryOfPensionModel category;
  final VoidCallback? onRefresh; // ✅ 4. Add parameter here

  const _CategoryTile({required this.category, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddPensionScreen(
              title: category.title,
              imagePath: category.imagePath,
              onRefresh: onRefresh, // ✅ 5. Pass it to AddPensionScreen
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        child: Row(
          children: [
            Container(
              width: 46.w,
              height: 46.h,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  category.imagePath,
                  width: 30.w,
                  cacheWidth: (30.w * MediaQuery.of(context).devicePixelRatio)
                      .round(),
                  gaplessPlayback: true,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                category.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: const Color(0xffA6A6A6),
              size: 20.w,
            ),
          ],
        ),
      ),
    );
  }
}
