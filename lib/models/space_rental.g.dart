// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'space_rental.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpaceRentalReview _$SpaceRentalReviewFromJson(Map<String, dynamic> json) =>
    SpaceRentalReview(
      userName: json['userName'] as String? ?? '',
      rating: const LooseIntAsZeroConverter().fromJson(json['rating']),
      comment: json['comment'] as String? ?? '',
      createdAt: const IsoDateTimeOrNowConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$SpaceRentalReviewToJson(SpaceRentalReview instance) =>
    <String, dynamic>{
      'userName': instance.userName,
      'rating': const LooseIntAsZeroConverter().toJson(instance.rating),
      'comment': instance.comment,
      'createdAt': const IsoDateTimeOrNowConverter().toJson(instance.createdAt),
    };

TimeSlot _$TimeSlotFromJson(Map<String, dynamic> json) => TimeSlot(
  startTime: const IsoDateTimeOrNowConverter().fromJson(json['startTime']),
  endTime: const IsoDateTimeOrNowConverter().fromJson(json['endTime']),
  isAvailable: json['isAvailable'] as bool? ?? true,
  bookedBy: _nullableStringFromAny(json['bookedBy']),
  bookingId: _nullableStringFromAny(json['bookingId']),
);

Map<String, dynamic> _$TimeSlotToJson(TimeSlot instance) => <String, dynamic>{
  'startTime': const IsoDateTimeOrNowConverter().toJson(instance.startTime),
  'endTime': const IsoDateTimeOrNowConverter().toJson(instance.endTime),
  'isAvailable': instance.isAvailable,
  'bookedBy': instance.bookedBy,
  'bookingId': instance.bookingId,
};

SpaceRental _$SpaceRentalFromJson(Map<String, dynamic> json) => SpaceRental(
  id: json['id'] as String? ?? '',
  shopId: json['shopId'] as String? ?? '',
  shopName: _readShopDisplayName(json, 'shopName') as String? ?? '',
  address: json['address'] as String? ?? '',
  detailAddress: json['detailAddress'] as String?,
  regionId: json['regionId'] as String? ?? '',
  regionName: json['regionName'] as String?,
  availableSlots: json['availableSlots'] == null
      ? []
      : _timeSlotsFromJson(json['availableSlots']),
  pricePerHour: const LooseIntAsZeroConverter().fromJson(json['pricePerHour']),
  facilities: json['facilities'] == null
      ? []
      : _facilitiesFromJson(json['facilities']),
  imageUrls: _imageUrlsFromJson(json['imageUrls']),
  status: _spaceStatusFromJson(json['status']),
  description: json['description'] as String?,
  createdAt: const IsoDateTimeOrNowConverter().fromJson(json['createdAt']),
  updatedAt: const IsoDateTimeNullableConverter().fromJson(json['updatedAt']),
  contactPhone: json['contactPhone'] as String?,
  subwayInfo: json['subwayInfo'] as String?,
  isPremium: json['isPremium'] as bool? ?? false,
  usageNotes: json['usageNotes'] as String?,
  averageRating: const LooseDoubleNullableConverter().fromJson(
    json['averageRating'],
  ),
  reviewCount: const LooseIntNullableConverter().fromJson(json['reviewCount']),
  reviews: _reviewsFromJson(json['reviews']),
  minHours: json['minHours'] == null
      ? 1
      : const LooseIntAsOneConverter().fromJson(json['minHours']),
  isHidden: json['isHidden'] as bool? ?? false,
  operatingSchedule: _operatingScheduleFromJson(json['operatingSchedule']),
);

Map<String, dynamic> _$SpaceRentalToJson(
  SpaceRental instance,
) => <String, dynamic>{
  'id': instance.id,
  'shopId': instance.shopId,
  'shopName': instance.shopName,
  'address': instance.address,
  'detailAddress': instance.detailAddress,
  'regionId': instance.regionId,
  'regionName': instance.regionName,
  'availableSlots': instance.availableSlots.map((e) => e.toJson()).toList(),
  'pricePerHour': const LooseIntAsZeroConverter().toJson(instance.pricePerHour),
  'facilities': instance.facilities,
  'imageUrls': instance.imageUrls,
  'status': _spaceStatusToJson(instance.status),
  'description': instance.description,
  'createdAt': const IsoDateTimeOrNowConverter().toJson(instance.createdAt),
  'updatedAt': const IsoDateTimeNullableConverter().toJson(instance.updatedAt),
  'contactPhone': instance.contactPhone,
  'subwayInfo': instance.subwayInfo,
  'isPremium': instance.isPremium,
  'usageNotes': instance.usageNotes,
  'averageRating': const LooseDoubleNullableConverter().toJson(
    instance.averageRating,
  ),
  'reviewCount': const LooseIntNullableConverter().toJson(instance.reviewCount),
  'reviews': instance.reviews?.map((e) => e.toJson()).toList(),
  'minHours': const LooseIntAsOneConverter().toJson(instance.minHours),
  'isHidden': instance.isHidden,
  'operatingSchedule': _operatingScheduleToJson(instance.operatingSchedule),
};

SpaceBooking _$SpaceBookingFromJson(Map<String, dynamic> json) => SpaceBooking(
  id: json['id'] as String? ?? '',
  spaceRentalId: json['spaceRentalId'] as String? ?? '',
  spareId: json['spareId'] as String? ?? '',
  spareName: json['spareName'] as String? ?? '',
  startTime: const IsoDateTimeOrNowConverter().fromJson(json['startTime']),
  endTime: const IsoDateTimeOrNowConverter().fromJson(json['endTime']),
  totalPrice: const LooseIntAsZeroConverter().fromJson(json['totalPrice']),
  status: _bookingStatusFromJson(json['status']),
  createdAt: const IsoDateTimeOrNowConverter().fromJson(json['createdAt']),
  spaceRental: _nestedSpaceRentalFromJson(json['spaceRental']),
);

Map<String, dynamic> _$SpaceBookingToJson(SpaceBooking instance) =>
    <String, dynamic>{
      'id': instance.id,
      'spaceRentalId': instance.spaceRentalId,
      'spareId': instance.spareId,
      'spareName': instance.spareName,
      'startTime': const IsoDateTimeOrNowConverter().toJson(instance.startTime),
      'endTime': const IsoDateTimeOrNowConverter().toJson(instance.endTime),
      'totalPrice': const LooseIntAsZeroConverter().toJson(instance.totalPrice),
      'status': _bookingStatusToJson(instance.status),
      'createdAt': const IsoDateTimeOrNowConverter().toJson(instance.createdAt),
      'spaceRental': instance.spaceRental?.toJson(),
    };
