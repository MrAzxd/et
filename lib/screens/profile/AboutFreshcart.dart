import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:e/utils/constants.dart';

class AboutFreshCartScreen extends StatelessWidget {
  const AboutFreshCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "About FreshCart",
          style: TextStyle(fontSize: 20.sp),
        ),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: ListView(
          children: [
            // App Logo / Icon
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_cart,
                    size: 80.sp,
                    color: kPrimaryColor,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "FreshCart",
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    "Your Daily Fresh Grocery Partner",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30.h),

            // About Section
            Text(
              "About Us",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "FreshCart is a modern e-commerce grocery shopping application that focuses mainly on providing fresh vegetables to customers. Our mission is to make grocery shopping easy, fast and reliable by delivering fresh products directly to your doorstep.",
              style: TextStyle(fontSize: 14.sp, height: 1.5),
            ),

            SizedBox(height: 20.h),

            // What we offer
            Text(
              "What We Offer",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            _buildPoint("🥬 Fresh Vegetables"),
            _buildPoint("🍎 Fresh Fruits"),
            _buildPoint("🥖 Grocery & Daily Essentials"),
            _buildPoint("🥛 Dairy Products"),
            _buildPoint("🍗 Meat & Frozen Items"),

            SizedBox(height: 20.h),

            // Vision
            Text(
              "Our Vision",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "We aim to create a smart and reliable grocery shopping experience by connecting customers with quality sellers and ensuring fast, safe and affordable deliveries.",
              style: TextStyle(fontSize: 14.sp, height: 1.5),
            ),

            SizedBox(height: 20.h),

            // Version info
            Center(
              child: Text(
                "Version 1.0.0",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget
  Widget _buildPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: kPrimaryColor, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}
