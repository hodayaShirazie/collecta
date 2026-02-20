// class DonationModel {
//   final String businessName;
//   final String businessAddress;
//   final String businessPhone;
//   final String businessId;
//   final String contactName;
//   final String contactPhone;
//   final List<Map<String, dynamic>> products;
//   final List<String> pickupTimes;

//   // שדות חדשים
//   final String driverId;
//   final String cancelingReason;
//   final String recipe;
//   final String organizationId;

//   DonationModel({
//     required this.businessName,
//     required this.businessAddress,
//     required this.businessPhone,
//     required this.businessId,
//     required this.contactName,
//     required this.contactPhone,
//     required this.products,
//     required this.pickupTimes,
//     this.driverId = "",
//     this.cancelingReason = "",
//     this.recipe = "",
//     required this.organizationId,
//   });

//   Map<String, dynamic> toJson() => {
//         "businessName": businessName,
//         "businessAddress": businessAddress,
//         "businessPhone": businessPhone,
//         "businessId": businessId,
//         "contactName": contactName,
//         "contactPhone": contactPhone,
//         "products": products,
//         "pickupTimes": pickupTimes,
//         "driver_id": driverId,
//         "canceling_reason": cancelingReason,
//         "recipe": recipe,
//         "organization_id": organizationId,
//       };
// }





class DonationModel {
  final String businessName;
  final String businessAddress;
  final double lat;
  final double lng;
  final String businessPhone;
  final String businessId;
  final String contactName;
  final String contactPhone;
  final List<Map<String, dynamic>> products;
  final List<String> pickupTimes;

  // שדות חדשים
  final String driverId;
  final String cancelingReason;
  final String recipe;
  final String organizationId;

  DonationModel({
    required this.businessName,
    required this.businessAddress,
    required this.lat,
    required this.lng,
    required this.businessPhone,
    required this.businessId,
    required this.contactName,
    required this.contactPhone,
    required this.products,
    required this.pickupTimes,
    this.driverId = "",
    this.cancelingReason = "",
    this.recipe = "",
    required this.organizationId,
  });

  Map<String, dynamic> toJson() => {
        "businessName": businessName,
        "businessAddress": businessAddress,
        "lat": lat,
        "lng": lng,
        "businessPhone": businessPhone,
        "businessId": businessId,
        "contactName": contactName,
        "contactPhone": contactPhone,
        "products": products,
        "pickupTimes": pickupTimes,
        "driver_id": driverId,
        "canceling_reason": cancelingReason,
        "recipe": recipe,
        "organization_id": organizationId,
      };
}




