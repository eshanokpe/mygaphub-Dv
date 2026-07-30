import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../add_pension.dart';

class CategoryOfPensionModel {
  final String title;
  final String imagePath;

  const CategoryOfPensionModel({required this.title, required this.imagePath});
}

class CategoryOfPensionScreen extends StatefulWidget {
  const CategoryOfPensionScreen({super.key});

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
    // Decode every category image ONCE, right when the screen mounts,
    // instead of letting each Image.asset decode lazily the first time
    // its tile lays out. That lazy first-decode of a full-res PNG is
    // what produces the multi-second delay before the icon appears.
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
    return false; // Prevent default back navigation
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
              // Back button
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

              // Title section
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

              // Category list
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
                    return _CategoryTile(category: category);
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

  const _CategoryTile({required this.category});

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
                  // Decode the bitmap at (roughly) the size it's actually
                  // rendered at instead of at full asset resolution, then
                  // let it scale to logical px. This is usually the bulk
                  // of the delay if the source PNGs are large — decoding
                  // a big PNG on the UI/raster thread just to shrink it
                  // to 30px is expensive and blocks the first frame.
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
