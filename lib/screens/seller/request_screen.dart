import 'package:e/models/request_model.dart';
import 'package:e/screens/seller/shop_setup_screen.dart';
import 'package:e/screens/seller/seller_dashboard_screen.dart';
import 'package:e/services/firestore_service.dart';
import 'package:e/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestScreen extends StatefulWidget {
  static const String routeName = '/request';

  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  RequestModel? _request;

  @override
  void initState() {
    super.initState();
    _checkRequestStatus();
  }

  reset() {
    setState(() {
      _checkRequestStatus();
    });
  }

  Future<void> _checkRequestStatus() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Check if user has a shop
        final userData = await _firestoreService.getUserData(user.uid);
        if (userData != null &&
            userData['shopId'] != null &&
            userData['shopId'].isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(
                context, SellerDashboardScreen.routeName);
          });
          return;
        }
        // Check request status if no shop exists
        final request = await _firestoreService.getSellerRequest(user.uid);
        setState(() {
          _request = request;
        });
        if (request != null && request.status == 'approved') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, ShopSetupScreen.routeName);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${e.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: kErrorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitRequest() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firestoreService.createSellerRequest(user.uid);
        setState(() {
          _request = RequestModel(
            id: user.uid,
            sellerId: user.uid,
            status: 'pending',
            createdAt: Timestamp.now(),
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request submitted successfully!'),
            backgroundColor: kPrimaryColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to submit request: ${e.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: kErrorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                reset();
              },
              icon: Icon(Icons.restart_alt))
        ],
        title: Text(
          'Seller Request',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Colors.white,
              ),
        ),
        backgroundColor: kPrimaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              const Icon(
                Icons.store,
                size: 80,
                color: kPrimaryColor,
              ),
              const SizedBox(height: kSmallPadding),
              Text(
                'Become a Seller',
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: kLargePadding),
              // Status or Request Button
              if (_isLoading)
                const CircularProgressIndicator(color: kPrimaryColor)
              else if (_request == null)
                Column(
                  children: [
                    Text(
                      'Submit a request to start selling!',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: kTextColorSecondary,
                            height: 1.5,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: kLargePadding),
                    ElevatedButton(
                      onPressed: _submitRequest,
                      child: const Text('Submit Request'),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Text(
                      'Request Status: ${_request!.status.capitalize()}',
                      style:
                          Theme.of(context).textTheme.headlineMedium!.copyWith(
                                color: _request!.status == 'approved'
                                    ? kPrimaryColor
                                    : kTextColor,
                              ),
                    ),
                    const SizedBox(height: kDefaultPadding),
                    Text(
                      _request!.status == 'pending'
                          ? 'Your request is awaiting admin approval.'
                          : _request!.status == 'approved'
                              ? 'Your request has been approved! Set up your shop.'
                              : 'Your request was rejected. Please contact support.',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: kTextColorSecondary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    if (_request!.status == 'approved')
                      Padding(
                        padding: const EdgeInsets.only(top: kDefaultPadding),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              ShopSetupScreen.routeName,
                            );
                          },
                          child: const Text('Set Up Shop'),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
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
