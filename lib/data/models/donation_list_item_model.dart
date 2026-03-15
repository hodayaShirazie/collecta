class DonationListItemModel {
  final String id;
  final String status;
  final DateTime createdAt;

  DonationListItemModel({
    required this.id,
    required this.status,
    required this.createdAt,
  });

  factory DonationListItemModel.fromApi(Map<String, dynamic> json) {
    return DonationListItemModel(
      id: json['id'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}