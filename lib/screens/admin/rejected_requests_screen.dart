import 'package:e/models/request_model.dart';
import 'package:e/services/firestore_service.dart';
import 'package:e/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RejectedRequestsScreen extends StatefulWidget {
  static const String routeName = '/rejected-requests';

  const RejectedRequestsScreen({super.key});

  @override
  State<RejectedRequestsScreen> createState() => _RejectedRequestsScreenState();
}

class _RejectedRequestsScreenState extends State<RejectedRequestsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _updateRequestStatus(String requestId, String status) async {
    if (status == 'rejected') {
      // Show rejection reason dialog
      final reason = await _showRejectionDialog();
      if (reason != null) {
        await _firestoreService.updateRequestStatus(requestId, status, rejectionReason: reason);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request rejected successfully!'),
            backgroundColor: kPrimaryColor,
          ),
        );
      }
    } else {
      // For approval, no reason needed
      try {
        await _firestoreService.updateRequestStatus(requestId, status);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request ${status.toLowerCase()} successfully!'),
            backgroundColor: kPrimaryColor,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update request: ${e.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: kErrorColor,
          ),
        );
      }
    }
  }

  Future<String?> _showRejectionDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejection Reason'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter reason for rejection',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rejected Requests',
          style: TextStyle(fontSize: 18.sp),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getAllRequests(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          }

          final requests = snapshot.data!.docs
              .map((doc) => RequestModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .where((request) => request.status == 'rejected') // Only show rejected requests
              .toList();

          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 80,
                    color: kPrimaryColor,
                  ),
                  const SizedBox(height: kDefaultPadding),
                  Text(
                    'No rejected requests',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: kTextColorSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(kDefaultPadding),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return FutureBuilder<Map<String, dynamic>?>(
                future: _firestoreService.getUserData(request.sellerId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Card(
                      margin: EdgeInsets.only(bottom: kDefaultPadding),
                      child: Padding(
                        padding: EdgeInsets.all(kDefaultPadding),
                        child: CircularProgressIndicator(color: kPrimaryColor),
                      ),
                    );
                  }

                  final userData = userSnapshot.data;
                  return Card(
                    margin: const EdgeInsets.only(bottom: kDefaultPadding),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kDefaultBorderRadius),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(kDefaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Shop Name
                          Row(
                            children: [
                              const Icon(Icons.store, color: kPrimaryColor),
                              const SizedBox(width: kSmallPadding),
                              Expanded(
                                child: Text(
                                  userData?['shopName'] ?? '-',
                                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: kTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: kSmallPadding),

                          // Shop Details
                          _buildDetailRow('Owner', userData?['name'] ?? '-'),
                          _buildDetailRow('Email', userData?['email'] ?? '-'),
                          _buildDetailRow('City', userData?['city'] ?? '-'),
                          _buildDetailRow('Address', userData?['shopAddress'] ?? '-'),
                          _buildDetailRow('Category', userData?['shopCategory'] ?? '-'),
                          _buildDetailRow('CNIC', userData?['cnic'] ?? '-'),
                          _buildDetailRow('Description', userData?['shopDescription'] ?? '-', maxLines: 2),

                          const SizedBox(height: kDefaultPadding),

                          // Rejection Reason
                          Container(
                            padding: const EdgeInsets.all(kDefaultPadding),
                            decoration: BoxDecoration(
                              color: kErrorColor.withOpacity(0.1),
                              border: Border.all(color: kErrorColor.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(kDefaultBorderRadius),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rejection Reason:',
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: kErrorColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: kSmallPadding),
                                Text(
                                  request.rejectionReason ?? 'No reason provided',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: kTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: kDefaultPadding),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _updateRequestStatus(request.id, 'approved'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimaryColor,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text('Approve'),
                                ),
                              ),
                              const SizedBox(width: kDefaultPadding),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _updateRequestStatus(request.id, 'rejected'),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: kErrorColor),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text(
                                    'Reject Again',
                                    style: TextStyle(color: kErrorColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w600,
                color: kTextColorSecondary,
              ),
            ),
          ),
          const SizedBox(width: kSmallPadding),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: kTextColor,
              ),
              maxLines: maxLines,
              overflow: maxLines > 1 ? TextOverflow.ellipsis : null,
            ),
          ),
        ],
      ),
    );
  }
}