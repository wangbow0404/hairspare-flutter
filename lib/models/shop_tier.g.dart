// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_tier.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$ShopTierInfoToJson(ShopTierInfo instance) =>
    <String, dynamic>{
      'currentTier': _shopTierInfoTierToJson(instance.currentTier),
      'completedSchedules': instance.completedSchedules,
      'thumbsUpReceived': instance.thumbsUpReceived,
      'maxJobPosts': instance.maxJobPosts,
      'tierUpdatedAt': instance.tierUpdatedAt?.toIso8601String(),
      'progressToNextTier': instance.progressToNextTier,
      'requiredSchedulesForNextTier': instance.requiredSchedulesForNextTier,
      'requiredThumbsUpForNextTier': instance.requiredThumbsUpForNextTier,
    };
