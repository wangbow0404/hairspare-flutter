/// 포인트 거래 내역 (적립/사용)
class PointTransaction {
  final String id;
  final String type; // 'earn' | 'spend'
  final int amount;
  final String description;
  final DateTime createdAt;
  final String? relatedId; // 미션 ID, 결제 ID 등

  PointTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
    this.relatedId,
  });

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'earn',
      amount: json['amount'] is int
          ? json['amount']
          : int.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      description: json['description']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      relatedId: json['relatedId']?.toString(),
    );
  }
}
