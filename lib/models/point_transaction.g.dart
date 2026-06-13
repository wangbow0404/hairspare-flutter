// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'point_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PointTransaction _$PointTransactionFromJson(Map<String, dynamic> json) =>
    PointTransaction(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'earn',
      amount: const LooseIntAsZeroConverter().fromJson(json['amount']),
      description: json['description'] as String? ?? '',
      createdAt: const IsoDateTimeOrNowConverter().fromJson(json['createdAt']),
      relatedId: json['relatedId'] as String?,
    );

Map<String, dynamic> _$PointTransactionToJson(PointTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'amount': const LooseIntAsZeroConverter().toJson(instance.amount),
      'description': instance.description,
      'createdAt': const IsoDateTimeOrNowConverter().toJson(instance.createdAt),
      'relatedId': instance.relatedId,
    };
