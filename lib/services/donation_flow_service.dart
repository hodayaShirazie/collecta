import '../services/address_service.dart';
import '../services/product_service.dart';
import '../services/product_type_service.dart';
import '../services/donation_service.dart';

const String kOrganizationId = 'xFKMWqidL2uZ5wnksdYX';

class DonationFlowService {

  Future<void> submitDonation({
    required String businessName,
    required String businessPhone,
    required String address,
    required String contactName,
    required String contactPhone,
    required String businessId,
    required List<Map<String, dynamic>> donatedItems,
    required List<String> selectedTimeSlots,
    double? lat,
    double? lng,
  }) async {

    final addressService = AddressService();

    final addressId = await addressService.createAddress(
      name: address,
      lat: lat ?? 30,
      lng: lng ?? 30,
    );

    final productService = ProductService();
    final productTypeService = ProductTypeService();

    List<String> productIds = [];

    for (var item in donatedItems) {

      String productTypeId;

      if (item["productTypeId"] == null) {

        final fullName = item["name"]?.toString() ?? "";
        final description = fullName.replaceFirst("אחר: ", "");

        productTypeId = await productTypeService.createProductType(
          name: "אחר",
          description: description,
        );

      } else {

        productTypeId = item["productTypeId"];

      }

      final qty = int.tryParse(item["quantity"].toString()) ?? 1;

      final id = await productService.createProduct(
        productTypeId: productTypeId,
        quantity: qty,
      );

      productIds.add(id);
    }

    final pickupTimes = selectedTimeSlots.map((slot) {
      final parts = slot.split('-');
      return {"from": parts[0], "to": parts[1]};
    }).toList();

    final body = {
      "businessName": businessName,
      "businessPhone": businessPhone,
      "contactName": contactName,
      "contactPhone": contactPhone,
      "businessId": businessId,
      "businessAddress": addressId,
      "organization_id": kOrganizationId,
      "products": productIds,
      "pickupTimes": pickupTimes,
      "driver_id": "",
      "canceling_reason": "",
      "recipe": "",
    };

    final donationService = DonationService();
    await donationService.reportDonationRaw(body);
  }
}