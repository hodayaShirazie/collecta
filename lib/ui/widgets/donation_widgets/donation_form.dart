import 'package:flutter/material.dart';

import '../personal_details/business_details_card.dart';
import '../personal_details/contact_details_card.dart';
import 'time_slots_card.dart';
import 'products_card.dart';
import 'donated_items_section.dart';

class DonationForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  final TextEditingController businessName;
  final TextEditingController address;
  final TextEditingController businessPhone;
  final TextEditingController crn;
  final TextEditingController contactName;
  final TextEditingController contactPhone;

  final List<String> timeSlots;
  final List<String> selectedTimeSlots;
  final Function(String) toggleTime;

  final List<Map<String, dynamic>> products;
  final List<String> selectedProducts;
  final Function(Map<String, dynamic>) toggleProduct;

  final List<Map<String, dynamic>> donatedItems;
  final bool Function(Map<String, dynamic>) isCategoryDisabled;
  final Function(int) onEditItem;
  final Function(int) onDeleteItem;

  final VoidCallback? onSubmit;
  final String buttonText;

  final Function(double, double) onLocationSelected;
  final VoidCallback? onLocationCleared;
  final bool isAddressConfirmed;
  final ButtonStyle buttonStyle;
  

  const DonationForm({
    super.key,
    required this.formKey,
    required this.businessName,
    required this.address,
    required this.businessPhone,
    required this.crn,
    required this.contactName,
    required this.contactPhone,
    required this.timeSlots,
    required this.selectedTimeSlots,
    required this.toggleTime,
    required this.products,
    required this.selectedProducts,
    required this.toggleProduct,
    required this.donatedItems,
    required this.isCategoryDisabled,
    required this.onEditItem,
    required this.onDeleteItem,
    this.onSubmit,
    required this.buttonText,
    required this.onLocationSelected,
    this.onLocationCleared,
    this.isAddressConfirmed = false,
    required this.buttonStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          BusinessDetailsCard(
            businessName: businessName,
            address: address,
            businessPhone: businessPhone,
            crn: crn,
            onLocationSelected: onLocationSelected,
            onLocationCleared: onLocationCleared,
            isAddressConfirmed: isAddressConfirmed,
          ),
          ContactDetailsCard(
            contactName: contactName,
            contactPhone: contactPhone,
          ),
          TimeSlotsCard(
            timeSlots: timeSlots,
            selectedTimeSlots: selectedTimeSlots,
            toggleTime: toggleTime,
          ),
          ProductsCard(
            products: products,
            selectedProducts: selectedProducts,
            toggleProduct: toggleProduct,
            isCategoryDisabled: isCategoryDisabled,
          ),
          const SizedBox(height: 30),
          DonatedItemsSection(
            donatedItems: donatedItems,
            onEdit: onEditItem,
            onDelete: onDeleteItem,
          ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed: onSubmit,
                style: buttonStyle,
                child: Text(buttonText),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}