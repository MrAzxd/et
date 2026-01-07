import 'package:e/models/request_model.dart';
import 'package:e/screens/auth/login_screen.dart';
import 'package:e/services/firestore_service.dart';
import 'package:e/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestApprovalScreen extends StatefulWidget {
  static const String routeName = '/request-approval';

  const RequestApprovalScreen({super.key});

  @override
  State<RequestApprovalScreen> createState() => _RequestApprovalScreenState();
}

class _RequestApprovalScreenState extends State<RequestApprovalScreen> {
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
    final TextEditingController reasonController = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reject Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please provide a reason for rejection:'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Enter rejection reason...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final reason = reasonController.text.trim();
                if (reason.isNotEmpty) {
                  Navigator.of(context).pop(reason);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a rejection reason'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Seller Requests',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Colors.white,
              ),
        ),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, LoginScreen.routeName);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getPendingRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: kPrimaryColor));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: kErrorColor),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No pending requests',
                style: TextStyle(color: kTextColorSecondary),
              ),
            );
          }

          final requests = snapshot.data!.docs
              .map((doc) => RequestModel.fromSnapshot(doc))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(kDefaultPadding),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return FutureBuilder<Map<String, dynamic>?>(
                future: _firestoreService.getUserData(request.sellerId),
                builder: (context, userSnapshot) {
                  String name = 'Loading...';
                  String email = 'Loading...';
                  if (userSnapshot.connectionState == ConnectionState.done) {
                    if (userSnapshot.hasData && userSnapshot.data != null) {
                      name = userSnapshot.data!['name'] ?? '-';
                      email = userSnapshot.data!['email'] ?? '-';
                    } else {
                      name = '-';
                      email = '-';
                    }
                  }
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kDefaultBorderRadius),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: kSmallPadding),
                    child: Padding(
                      padding: const EdgeInsets.all(kDefaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name: ${name ?? "-"}',
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      color: kTextColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          const SizedBox(height: kSmallPadding),
                          Text(
                            'Email: ${email ?? "-"}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: kTextColorSecondary,
                                ),
                          ),
                          const SizedBox(height: kSmallPadding),
                          Text(
                            'Shop Name: ${userSnapshot.data?['shopName'] ?? "-"}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: kTextColorSecondary,
                                ),
                          ),
                          const SizedBox(height: kSmallPadding),
                          Text(
                            'City: ${userSnapshot.data?['city'] ?? "-"}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: kTextColorSecondary,
                                ),
                          ),
                          const SizedBox(height: kSmallPadding),
                          Text(
                            'Shop Address: ${userSnapshot.data?['shopAddress'] ?? "-"}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: kTextColorSecondary,
                                ),
                          ),
                          const SizedBox(height: kSmallPadding),
                          Text(
                            'Shop Category: ${userSnapshot.data?['shopCategory'] ?? "-"}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: kTextColorSecondary,
                                ),
                          ),
                          const SizedBox(height: kSmallPadding),
                          Text(
                            'CNIC: ${userSnapshot.data?['cnic'] ?? "-"}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: kTextColorSecondary,
                                ),
                          ),
                          const SizedBox(height: kSmallPadding),
                          Text(
                            'Shop Description: ${userSnapshot.data?['shopDescription'] ?? "-"}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: kTextColorSecondary,
                                ),
                          ),
                          const SizedBox(height: kSmallPadding),
                          Text(
                            'Status: ${request.status.capitalize()}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: kTextColorSecondary,
                                ),
                          ),
                          if (request.rejectionReason != null && request.rejectionReason!.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: kSmallPadding),
                                Text(
                                  'Rejection Reason: ${request.rejectionReason}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: kErrorColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          Text(
                            'Created: ${request.createdAt.toDate().toString().substring(0, 16)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: kTextColorSecondary,
                                ),
                          ),
                          const SizedBox(height: kDefaultPadding),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => _updateRequestStatus(
                                    request.id, 'approved'),
                                child: const Text(
                                  'Approve',
                                  style: TextStyle(color: kPrimaryColor),
                                ),
                              ),
                              TextButton(
                                onPressed: () => _updateRequestStatus(
                                    request.id, 'rejected'),
                                child: const Text(
                                  'Reject',
                                  style: TextStyle(color: kErrorColor),
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
}

// Extension to capitalize string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
