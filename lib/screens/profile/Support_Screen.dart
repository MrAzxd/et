import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitFeedback() async {
    final feedbackText = _feedbackController.text.trim();
    if (feedbackText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write some feedback!')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You must be logged in to submit feedback!')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('feedbacks').add({
        'feedback': feedbackText,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': currentUser.uid, // <-- Save user ID here
      });

      _feedbackController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit feedback: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil
    ScreenUtil.init(context, designSize: const Size(375, 812));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Help & Support",
          style: TextStyle(fontSize: 20.sp),
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: ListView(
          children: [
            Text(
              "How can we help you?",
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),

            // FAQs Section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ExpansionTile(
                leading: Icon(Icons.question_answer,
                    color: Colors.green, size: 28.sp),
                title: Text(
                  "Frequently Asked Questions",
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
                children: [
                  ListTile(
                    title: Text("How do I place an order?",
                        style: TextStyle(fontSize: 14.sp)),
                    subtitle: Text(
                      "Go to the vegetables section, add items to your cart, and proceed to checkout.",
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ),
                  ListTile(
                    title: Text("What payment methods are accepted?",
                        style: TextStyle(fontSize: 14.sp)),
                    subtitle: Text(
                      "We accept Cash on Delivery and Credit/Debit Cards.",
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ),
                  ListTile(
                    title: Text("Can I cancel an order?",
                        style: TextStyle(fontSize: 14.sp)),
                    subtitle: Text(
                      "Yes, you can cancel your order before it is packed.",
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Contact Options
            Text(
              "Contact Us",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            Card(
              child: ListTile(
                leading: Icon(Icons.phone, color: Colors.blue, size: 28.sp),
                title: Text("Call Us", style: TextStyle(fontSize: 16.sp)),
                subtitle:
                    Text("+92 300 1234567", style: TextStyle(fontSize: 14.sp)),
                onTap: () {},
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.email, color: Colors.red, size: 28.sp),
                title: Text("Email Us", style: TextStyle(fontSize: 16.sp)),
                subtitle: Text("support@freshcart.com",
                    style: TextStyle(fontSize: 14.sp)),
                onTap: () {},
              ),
            ),
            SizedBox(height: 20.h),

            // Feedback
            Text(
              "Send Feedback",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Write your feedback here...",
                hintStyle: TextStyle(fontSize: 14.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
              ),
            ),
            SizedBox(height: 12.h),

            // Responsive Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: _isSubmitting ? null : _submitFeedback,
                icon: _isSubmitting
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(Icons.send, size: 20.sp),
                label: _isSubmitting
                    ? Text(
                        "Submitting...",
                        style: TextStyle(fontSize: 16.sp),
                      )
                    : Text(
                        "Submit",
                        style: TextStyle(fontSize: 16.sp),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
