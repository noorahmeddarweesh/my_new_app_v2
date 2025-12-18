import 'package:flutter/material.dart';

class CategoriesListWidget extends StatelessWidget {
  final List<Map<String, String>> categories;
  final String selectedCategory;
  final Function(String) onCategoryTap;

  const CategoriesListWidget({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          CategoryButtonWidget(
            value: "all",
            label: "All",
            isActive: selectedCategory == "all",
            onTap: onCategoryTap,
          ),
          ...categories.map((c) => CategoryButtonWidget(
                value: c['slug']!,
                label: c['label']!,
                isActive: selectedCategory == c['slug'],
                onTap: onCategoryTap,
              )),
        ],
      ),
    );
  }
}

class CategoryButtonWidget extends StatelessWidget {
  final String value;
  final String label;
  final bool isActive;
  final Function(String) onTap;

  const CategoryButtonWidget({
    super.key,
    required this.value,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}