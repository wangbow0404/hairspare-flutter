import 'package:json_annotation/json_annotation.dart';

import 'json_converters.dart';

part 'point_transaction.g.dart';

/// 포인트 거래 내역 (적립/사용)
@JsonSerializable()
class PointTransaction {
  const PointTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
    this.relatedId,
  });

  factory PointTransaction.fromJson(Map<String, dynamic> json) =>
      _$PointTransactionFromJson(json);

  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(defaultValue: 'earn')
  final String type;
  @LooseIntAsZeroConverter()
  final int amount;
  @JsonKey(defaultValue: '')
  final String description;
  @IsoDateTimeOrNowConverter()
  final DateTime createdAt;
  final String? relatedId;

  Map<String, dynamic> toJson() => _$PointTransactionToJson(this);
}
