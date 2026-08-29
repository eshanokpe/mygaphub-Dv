import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProtectionCategory {
  final String title;
  final String imagePath;

  const ProtectionCategory({required this.title, required this.imagePath});
}

class CategoryOfProtectionScreen extends StatelessWidget {
  const CategoryOfProtectionScreen({super.key});

  static const List<ProtectionCategory> _categories = [
    ProtectionCategory(
      title: 'Life Insurance',
      imagePath: 'assets/wheel_segments/life_insurance.png',
    ),
    ProtectionCategory(
      title: 'Home Insurance',
      imagePath: 'assets/wheel_segments/home_insurance.png',
    ),
    ProtectionCategory(
      title: 'Car Insurance',
      imagePath: 'assets/wheel_segments/car_insurance.png',
    ),
    ProtectionCategory(
      title: 'Critical Illness Cover',
      imagePath: 'assets/wheel_segments/critical_illness_cover.png',
    ),
    ProtectionCategory(
      title: 'Income Protection',
      imagePath: 'assets/wheel_segments/income_protection.png',
    ),
    ProtectionCategory(
      title: 'Gadget/Device Protection',
      imagePath: 'assets/wheel_segments/gadget_device_protection.png',
    ),
    ProtectionCategory(
      title: 'Health Insurance',
      imagePath: 'assets/wheel_segments/health_insurance.png',
    ),
    ProtectionCategory(
      title: 'Others',
      imagePath: 'assets/wheel_segments/others.png',
    ),
  ];

  Future<bool> _handleWillPop(BuildContext context) async {
    Navigator.pop(context);
    Navigator.pop(context);
    return false; // Prevent default back navigation
  }

  @override
  Widget build(BuildContext context) {
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
                      'Category of Protection',
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
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    thickness: 0.8,
                    indent: 20,
                    endIndent: 20,
                    color: Color(0xFFEEEEEE),
                  ),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
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
  final ProtectionCategory category;

  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Handle tap
        // Navigator.push(context,
        //   MaterialPageRoute(
        //     builder: (context) =>
        //         AddProtectionScreen(
        //           title:  category.title,
        //           imagePath:  category.imagePath,
        //         ),
        //   ),
        // );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        child: Row(
          children: [
            // imagePath icon in a circle
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  category.imagePath,
                  width: 30.w,
                  height: 28.h,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Category name
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

            // Chevron
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
