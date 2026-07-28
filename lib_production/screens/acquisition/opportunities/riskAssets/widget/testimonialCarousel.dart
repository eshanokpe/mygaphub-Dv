import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TestimonialCarousel extends StatefulWidget {
  const TestimonialCarousel({super.key});

  @override
  _TestimonialCarouselState createState() => _TestimonialCarouselState();
}

class _TestimonialCarouselState extends State<TestimonialCarousel> {
  final List<Map<String, String>> testimonials = [
    {
      "image": "https://randomuser.me/api/portraits/men/32.jpg",
      "name": "1 Lorem ipsum",
      "text":
          "Lorem ipsum dolor sit amet consectetuer. Vel pretium semper lectus adipiscing vitae elementum ultrices commodo.",
    },
    {
      "image": "https://randomuser.me/api/portraits/women/45.jpg",
      "name": "2 Lorem ipsum",
      "text":
          "Lorem ipsum dolor sit amet consectetuer. Vel pretium semper lectus adipiscing vitae elementum ultrices commodo.",
    },
    {
      "image": "https://randomuser.me/api/portraits/men/12.jpg",
      "name": "2 Lorem ipsum",
      "text":
          "Lorem ipsum dolor sit amet consectetuer. Vel pretium semper lectus adipiscing vitae elementum ultrices commodo.",
    },
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CarouselSlider.builder(
          itemCount: testimonials.length,
          options: CarouselOptions(
            height: 230.h,
            enlargeCenterPage: true,
            autoPlay: true,
            viewportFraction: 0.9,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          itemBuilder: (context, index, realIndex) {
            final testimonial = testimonials[index];

            return Container(
              padding:  EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xffE8E8E8),
                    Color(0xffF1F1F1)
                  ], // light grey gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Quote icons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/images/acquisition/forwardQuote.png',
                          height: 15.h),
                      Image.asset(
                        'assets/images/acquisition/backQuote.png',
                        height: 15.h,
                      ),
                    ],
                  ),
                  // Avatar
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: NetworkImage(testimonial['image']!),
                  ),
                  const SizedBox(height: 12),
                  // Name
                  Text(
                    testimonial['name']!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Description
                  Text(
                    testimonial['text']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(testimonials.length, (index) {
            return Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == index ? Colors.black : Colors.black26,
              ),
            );
          }),
        ),
      ],
    );
  }
}
