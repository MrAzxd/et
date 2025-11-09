import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e/models/product_model.dart';
import 'package:e/screens/buyer/product_detail_screen.dart';
import 'package:e/services/firestore_service.dart';
import 'package:e/utils/constants.dart';
import 'package:e/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ——————————— FULL-WIDTH SEARCH BAR ———————————
            Padding(
              padding: EdgeInsets.fromLTRB(
                kDefaultPadding,
                16.h,
                kDefaultPadding,
                8.h,
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: kTextColor,
                ),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(
                    color: kTextColorSecondary,
                    fontSize: 14.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: kPrimaryColor,
                    size: 24.sp,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: kTextColorSecondary,
                            size: 20.sp,
                          ),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16.h,
                    horizontal: 16.w,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(kDefaultBorderRadius),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(kDefaultBorderRadius),
                    borderSide:
                        BorderSide(color: kBorderColor.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(kDefaultBorderRadius),
                    borderSide:
                        const BorderSide(color: kPrimaryColor, width: 2),
                  ),
                ),
              ),
            ),

            // ——————————— CANCEL BUTTON (Below, Right-Aligned) ———————————
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: kDefaultPadding,
                  vertical: 4.h,
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // ——————————— DIVIDER LINE ———————————
            Divider(
              height: 1,
              thickness: 1,
              color: kBorderColor.withOpacity(0.3),
              indent: kDefaultPadding,
              endIndent: kDefaultPadding,
            ),

            SizedBox(height: 8.h),

            // ——————————— PRODUCT RESULTS ———————————
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestoreService.getProductsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: kPrimaryColor),
                    );
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
                        'No products available',
                        style: TextStyle(color: kTextColorSecondary),
                      ),
                    );
                  }

                  final allProducts = snapshot.data!.docs
                      .map((doc) => ProductModel.fromSnapshot(doc))
                      .toList();

                  final filtered = _query.isEmpty
                      ? allProducts
                      : allProducts.where((p) {
                          final nameMatch =
                              p.name.toLowerCase().contains(_query);
                          final descMatch = p.description != null
                              ? p.description!
                                  .toLowerCase()
                                  .contains(_query)
                              : false;
                          return nameMatch || descMatch;
                        }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64.sp,
                            color: kTextColorSecondary.withOpacity(0.5),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No products match your search',
                            style: TextStyle(
                              color: kTextColorSecondary,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return AnimationLimiter(
                    child: GridView.builder(
                      padding: EdgeInsets.all(kDefaultPadding),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: kDefaultPadding,
                        mainAxisSpacing: kDefaultPadding,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final product = filtered[index];
                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          columnCount: 2,
                          child: ScaleAnimation(
                            child: FadeInAnimation(
                              child: Hero(
                                tag: 'product_${product.id}',
                                child: ProductCard(
                                  product: product,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      ProductDetailScreen.routeName,
                                      arguments: product,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}