import 'address_model.dart';
import 'product_model.dart';

class PickupTime {
  final String from;
  final String to;

  PickupTime({
    required this.from,
    required this.to,
  });

  factory PickupTime.fromApi(Map<String, dynamic> json) {
    return PickupTime(
      from: json['from'] as String,
      to: json['to'] as String,
    );
  }
    Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
    };
  }
}

class DonationModel {
  final String id;
  final String status;
  final String receipt;
  final String cancelingReason;
  final String organizationId;

  final AddressModel businessAddress;
  final String donorId;
  final String driverId;

  final String businessName;
  final String businessPhone;
  final String crn;
  final String contactName;
  final String contactPhone;
  final DateTime createdAt;

  final List<PickupTime> pickupTimes;
  final List<ProductModel> products;  

  DonationModel({
    required this.id,
    required this.status,
    required this.receipt,
    required this.cancelingReason,
    required this.organizationId,
    required this.businessAddress,
    required this.donorId,
    required this.driverId,
    required this.businessName,
    required this.businessPhone,
    required this.crn,
    required this.contactName,
    required this.contactPhone,
    required this.createdAt,
    required this.pickupTimes,
    required this.products,
  });

  factory DonationModel.fromApi(Map<String, dynamic> json) {

  return DonationModel(
    id: json['id'] ?? 'MISSING_ID',
    status: json['status'] ?? 'UNKNOWN',
    receipt: json['recipe'] ?? json['receipt'] ?? '',
    cancelingReason: json['canceling_reason'] ?? '',
    organizationId: json['organization_id'] ?? '',
    donorId: json['donor_id'] ?? '',
    driverId: json['driver_id'] ?? '',
    businessName: json['businessName'] ?? '',
    businessPhone: json['businessPhone'] ?? '',
    crn: json['crn'] ?? '',
    contactName: json['contactName'] ?? '',
    contactPhone: json['contactPhone'] ?? '',
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : DateTime.now(),
    businessAddress: json['businessAddress'] != null
        ? AddressModel.fromApi(json['businessAddress'])
        : AddressModel(id: 'MISSING', lat: 0, lng: 0, name: 'MISSING'),
    pickupTimes: (json['pickupTimes'] as List?)?.map((e) => PickupTime.fromApi(e)).toList() ?? [],
    products: (json['products'] as List?)?.map((e) => ProductModel.fromApi(e)).toList() ?? [],
  );
}


   Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'receipt': receipt,
      'canceling_reason': cancelingReason,
      'organization_id': organizationId,
      'donor_id': donorId,
      'driver_id': driverId,
      'businessName': businessName,
      'businessPhone': businessPhone,
      'crn': crn,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'created_at': createdAt.toIso8601String(), // תאריך בפורמט ISO
      'businessAddress': businessAddress.toJson(), // ממיר ל־Map
      'pickupTimes': pickupTimes.map((e) => e.toJson()).toList(),
      'products': products.map((e) => e.toJson()).toList(),
    };
  }

  DonationModel copyWith({
    String? id,
    String? status,
    String? receipt,
    String? cancelingReason,
    String? organizationId,
    AddressModel? businessAddress,
    String? donorId,
    String? driverId,
    String? businessName,
    String? businessPhone,
    String? crn,
    String? contactName,
    String? contactPhone,
    DateTime? createdAt,
    List<PickupTime>? pickupTimes,
    List<ProductModel>? products,
  }) {
    return DonationModel(
      id: id ?? this.id,
      status: status ?? this.status,
      receipt: receipt ?? this.receipt,
      cancelingReason: cancelingReason ?? this.cancelingReason,
      organizationId: organizationId ?? this.organizationId,
      businessAddress: businessAddress ?? this.businessAddress,
      donorId: donorId ?? this.donorId,
      driverId: driverId ?? this.driverId,
      businessName: businessName ?? this.businessName,
      businessPhone: businessPhone ?? this.businessPhone,
      crn: crn ?? this.crn,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      createdAt: createdAt ?? this.createdAt,
      pickupTimes: pickupTimes ?? this.pickupTimes,
      products: products ?? this.products,
    );
  }
}