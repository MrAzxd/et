import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeImageSlider extends StatefulWidget {
  const HomeImageSlider({super.key});

  @override
  State<HomeImageSlider> createState() => _HomeImageSliderState();
}

class _HomeImageSliderState extends State<HomeImageSlider> {
  int _currentIndex = 0;

 final List<String> _images = [
  'https://cdn.pixabay.com/photo/2016/03/05/19/02/vegetables-1238252_1280.jpg', // fresh vegetables
  'https://cdn.pixabay.com/photo/2016/03/05/19/02/vegetables-1238252_1280.jpg',    // assorted vegetables
  'https://cdn.pixabay.com/photo/2016/03/05/19/02/vegetables-1238252_1280.jpg',  // colorful vegetables
    // basket of vegetables
];


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          items: _images.map((image) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(15.r),
              child: Image.network(
                image,
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 50, color: Colors.red),
              ),
            );
          }).toList(),
          options: CarouselOptions(
            height: 180.h,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 2),
            enlargeCenterPage: true,
            viewportFraction: 0.9,
            onPageChanged: (index, reason) {
              setState(() => _currentIndex = index);
            },
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _images.asMap().entries.map((entry) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              height: 6.h,
              width: _currentIndex == entry.key ? 18.w : 8.w,
              decoration: BoxDecoration(
                color: _currentIndex == entry.key
                    ? Colors.green
                    : Colors.green.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5.r),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
