import 'dart:convert';
// import 'package:collecta/data/models/address_model.dart';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import 'auth_headers.dart';
import '../../models/donation_model.dart';


class ApiSource {
  Future<List<Map<String, dynamic>>> getUsers() async {
    final headers = await AuthHeaders.build();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/getUsers'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch users');
    }

    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }

  Future<List<Map<String, dynamic>>> getOrganizations() async {
    final response =
        await http.get(Uri.parse('${ApiConfig.baseUrl}/getOrganizations'));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch organizations');
    }

    return List<Map<String, dynamic>>.from(
      json.decode(response.body),
    );
  }

  Future<String> syncUserWithRole({
    required String name,
    required String mail,
    required String img,
    required String role,
    required String organizationId,
  }) async {
    final headers = await AuthHeaders.build();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/syncUserWithRole'),
      headers: headers,
      body: json.encode({
        'name': name,
        'mail': mail,
        'img': img,
        'role': role,
        'organizationId': organizationId,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['error']);
    }

    return data['status'];
  }

  Future<Map<String, dynamic>> getMyProfile(String role) async {
    final headers = await AuthHeaders.build();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/getMyProfile?role=$role'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception(json.decode(response.body)['error']);
    }

    return Map<String, dynamic>.from(json.decode(response.body));
  }

  Future<String> updateDonorProfile({
    required String businessName,
    required String businessPhone,
    required String businessAddressId,
    required String contactName,
    required String contactPhone,
    required String crn,
  }) async {
    final headers = await AuthHeaders.build();

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/updateDonorProfile'),
      headers: headers,
      body: json.encode({
        'businessName': businessName,
        'businessPhone': businessPhone,
        'businessAddress_id': businessAddressId,
        'contactName': contactName,
        'contactPhone': contactPhone,
        'crn': crn,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['error']);
    }

    return data['status'];
  }

  // Future<String> reportDonation(DonationModel donation) async {
  //   final headers = await AuthHeaders.build();

  //   final response = await http.post(
  //     Uri.parse('${ApiConfig.baseUrl}/reportDonation'),
  //     headers: headers,
  //     body: json.encode({
  //       'addressId': donation.businessAddress.id,
  //       'cancelingReason': donation.cancelingReason,
  //       'contactName': donation.contactName,
  //       'contactPhone': donation.contactPhone,
  //       'donorId': donation.donorId,
  //       'driverId': donation.driverId,
  //       'organizationId': donation.organizationId,  
  //       'pickupTimes': donation.pickupTimes
  //           .map((pt) => {
  //                 'from': pt.from,
  //                 'to': pt.to,
  //               })
  //           .toList(),
  //       'products': donation.products
  //           .map((p) => {
  //                 'productTypeId': p.type.id,
  //                 'quantity': p.quantity,
  //               })
  //           .toList(),
  //       'receipt': donation.receipt,
  //       'status': donation.status,
  //       // 'createdAt': donation.createdAt.toIso8601String() //TODO: check if created at is here to do or elsewhere
  //     }),
  //   );

  //   final data = json.decode(response.body);

  //   if (response.statusCode != 200) {
  //     throw Exception(data['error']);
  //   }

  //   return data['status'];
  // }

  Future<String> updateUserProfile({
    required String name,
    // required String img,
  }) async {
    final headers = await AuthHeaders.build();

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/updateUserProfile'),
      headers: headers,
      body: json.encode({
        'name': name,
        // 'img': img,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['error']);
    }

    return data['status'];
  }

  Future<String> createAddress({
    required String name,
    required double lat,
    required double lng,
  }) async {
    final headers = await AuthHeaders.build();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/createAddress'),
      headers: headers,
      body: json.encode({
        'name': name,
        'lat': lat,
        'lng': lng,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['error']);
    }

    return data['addressId'];
  }

  Future<String> createProductType({
    required String name,
    required String description,
  }) async {
    final headers = await AuthHeaders.build();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/createProductType'),
      headers: headers,
      body: json.encode({
        'name': name,
        'description': description,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['error']);
    }

    return data['productTypeId'];
  }


  Future<String> createProduct({
    required String productTypeId,
    required int quantity,
  }) async {
    final headers = await AuthHeaders.build();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/createProduct'),
      headers: headers,
      body: json.encode({
        'productTypeId': productTypeId,
        'quantity': quantity
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['error']);
    }

    return data['productId'];
  }


  // NEW
  Future<String> reportDonationRaw(Map<String, dynamic> body) async {
  final headers = await AuthHeaders.build();

  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/reportDonation'),
    headers: headers,
    body: json.encode(body),
  );

  final data = json.decode(response.body);

  if (response.statusCode != 200) {
    throw Exception(data['error']);
  }

  return data['status'];
}

  // Future<String> updateDriverProfile({
  //   required String phone,
  //   required String area,
  //   required List<dynamic> destination,
  //   required List<dynamic> stops,
  // }) async {
  //   final headers = await AuthHeaders.build();

  //   final response = await http.put(
  //     Uri.parse('${ApiConfig.baseUrl}/updateDriverProfile'),
  //     headers: headers,
  //     body: json.encode({
  //       'phone': phone,
  //       'area': area,
  //       'destination': destination,
  //     }),
  //   );

  //   final data = json.decode(response.body);

  //   if (response.statusCode != 200) {
  //     throw Exception(data['error']);
  //   }

  //   return data['status'];
  // }

}
