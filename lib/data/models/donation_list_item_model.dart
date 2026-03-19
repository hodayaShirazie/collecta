class DonationListItemModel {
  final String id;
  final String status;
  final DateTime createdAt;
  final String receipt;

  DonationListItemModel({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.receipt,
  });

  factory DonationListItemModel.fromApi(Map<String, dynamic> json) {
    return DonationListItemModel(
      id: json['id'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      receipt: json['receipt'] ?? json['recipe'] ?? '',
    );
  }
}