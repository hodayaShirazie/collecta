import 'package:flutter/material.dart';
import '../../widgets/donation_widgets/section_title.dart';
import '../../widgets/donation_widgets/card.dart';
import '../../widgets/donation_widgets/product_chip.dart';

class ProductsCard extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final List<String> selectedProducts;
  final Function(Map<String, dynamic>) toggleProduct;

  const ProductsCard({
    required this.products,
    required this.selectedProducts,
    required this.toggleProduct,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitleWidget(text: "מוצרים לתרומה"),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: products.sublist(0, 4).map((product) {
                  return ProductChipWidget(
                    label: product["name"],
                    selected: selectedProducts.contains(product["name"]),
                    iconPath: product["icon"],
                    onTap: () => toggleProduct(product),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: products.sublist(4).map((product) {
                  return ProductChipWidget(
                    label: product["name"],
                    selected: selectedProducts.contains(product["name"]),
                    iconPath: product["icon"],
                    onTap: () => toggleProduct(product),
                  );
                }).toList(),
              ),
            ],
          )
        ],
      ),
    );
  }
}