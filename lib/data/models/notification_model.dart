import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String donationId;
  final String organizationId;
  final String businessName;
  final String contactName;
  final String contactPhone;
  final String cancelingReason;
  final DateTime createdAt;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.donationId,
    required this.organizationId,
    required this.businessName,
    required this.contactName,
    required this.contactPhone,
    required this.cancelingReason,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      donationId: data['donationId'] as String? ?? '',
      organizationId: data['organizationId'] as String? ?? '',
      businessName: data['businessName'] as String? ?? '',
      contactName: data['contactName'] as String? ?? '',
      contactPhone: data['contactPhone'] as String? ?? '',
      cancelingReason: data['cancelingReason'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
    );
  }
}
