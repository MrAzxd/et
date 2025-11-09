import 'package:e/screens/buyer/product_list_screen.dart';
import 'package:e/utils/constants.dart';
import 'package:flutter/material.dart';

class CategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const CategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      color: kBackgroundColor,
      child: DropdownButtonFormField<String>(
        value: selectedCategory,
        decoration: const InputDecoration(
          labelText: 'Select Category',
          prefixIcon: Icon(Icons.category, color: kPrimaryColor),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(kDefaultBorderRadius)),
          ),
        ),
        items: kProductCategories
            .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            onCategoryChanged(value);
            Navigator.pushNamed(
              context,
              ProductListScreen.routeName,
              arguments: value,
            );
          }
        },
      ),
    );
  }
}
