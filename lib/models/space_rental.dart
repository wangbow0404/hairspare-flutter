/// 공간대여 모델
/// 미용실이 공간을 시간 단위로 대여할 수 있도록 하는 시스템
library;

import 'package:json_annotation/json_annotation.dart';

import 'json_converters.dart';
import 'space_operating_schedule.dart';

part 'space_rental.g.dart';

SpaceOperatingSchedule? _operatingScheduleFromJson(Object? json) {
  if (json == null) return null;
  if (json is Map<String, dynamic>) {
    return SpaceOperatingSchedule.fromJson(json);
  }
  return SpaceOperatingSchedule.fromJson(Map<String, dynamic>.from(json as Map));
}

Object? _operatingScheduleToJson(SpaceOperatingSchedule? schedule) =>
    schedule?.toJson();

Object? _readShopDisplayName(Map json, String key) =>
    json['shopName'] ?? json['shopId'] ?? '미용실';

SpaceStatus _spaceStatusFromJson(Object? json) {
  if (json == null) return SpaceStatus.available;
  final statusStr = json.toString().toLowerCase();
  switch (statusStr) {
    case 'available':
    case 'active':
      return SpaceStatus.available;
    case 'booked':
      return SpaceStatus.booked;
    case 'unavailable':
      return SpaceStatus.unavailable;
    default:
      return SpaceStatus.available;
  }
}

Object _spaceStatusToJson(SpaceStatus s) => s.name;

List<TimeSlot> _timeSlotsFromJson(Object? json) {
  if (json is! List) return [];
  return json
      .map((e) => TimeSlot.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
}

List<String> _facilitiesFromJson(Object? json) {
  if (json is! List) return [];
  return json.map((e) => e.toString()).toList();
}

List<String>? _imageUrlsFromJson(Object? json) {
  if (json == null) return null;
  if (json is! List) return null;
  return json.map((e) => e.toString()).toList();
}

List<SpaceRentalReview>? _reviewsFromJson(Object? json) {
  if (json == null) return null;
  if (json is! List) return null;
  return json
      .map((e) =>
          SpaceRentalReview.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
}

String? _nullableStringFromAny(Object? json) => json?.toString();

BookingStatus _bookingStatusFromJson(Object? json) {
  if (json == null) return BookingStatus.pending;
  final statusStr = json.toString().toLowerCase();
  switch (statusStr) {
    case 'pending':
      return BookingStatus.pending;
    case 'confirmed':
      return BookingStatus.confirmed;
    case 'in_progress':
      return BookingStatus.inProgress;
    case 'completed':
      return BookingStatus.completed;
    case 'cancelled':
      return BookingStatus.cancelled;
    default:
      return BookingStatus.pending;
  }
}

Object _bookingStatusToJson(BookingStatus s) => s.name;

SpaceRental? _nestedSpaceRentalFromJson(Object? json) {
  if (json == null) return null;
  if (json is Map<String, dynamic>) {
    return SpaceRental.fromJson(json);
  }
  return SpaceRental.fromJson(Map<String, dynamic>.from(json as Map));
}

/// 공간대여 리뷰
@JsonSerializable()
class SpaceRentalReview {
  const SpaceRentalReview({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory SpaceRentalReview.fromJson(Map<String, dynamic> json) =>
      _$SpaceRentalReviewFromJson(json);

  @JsonKey(defaultValue: '')
  final String userName;
  @LooseIntAsZeroConverter()
  final int rating;
  @JsonKey(defaultValue: '')
  final String comment;
  @IsoDateTimeOrNowConverter()
  final DateTime createdAt;

  Map<String, dynamic> toJson() => _$SpaceRentalReviewToJson(this);
}

enum SpaceStatus {
  available,
  booked,
  unavailable,
}

/// 시간대 슬롯
@JsonSerializable()
class TimeSlot {
  const TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.bookedBy,
    this.bookingId,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) =>
      _$TimeSlotFromJson(json);

  @IsoDateTimeOrNowConverter()
  final DateTime startTime;
  @IsoDateTimeOrNowConverter()
  final DateTime endTime;
  @JsonKey(defaultValue: true)
  final bool isAvailable;
  @JsonKey(fromJson: _nullableStringFromAny)
  final String? bookedBy;
  @JsonKey(fromJson: _nullableStringFromAny)
  final String? bookingId;

  Map<String, dynamic> toJson() => _$TimeSlotToJson(this);

  int get durationInMinutes => endTime.difference(startTime).inMinutes;

  double get durationInHours => durationInMinutes / 60.0;
}

/// 공간대여 모델
@JsonSerializable(explicitToJson: true)
class SpaceRental {
  const SpaceRental({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.address,
    this.detailAddress,
    required this.regionId,
    this.regionName,
    required this.availableSlots,
    required this.pricePerHour,
    required this.facilities,
    this.imageUrls,
    required this.status,
    this.description,
    required this.createdAt,
    this.updatedAt,
    this.contactPhone,
    this.subwayInfo,
    this.isPremium = false,
    this.usageNotes,
    this.averageRating,
    this.reviewCount,
    this.reviews,
    this.minHours = 1,
    this.isHidden = false,
    this.operatingSchedule,
  });

  factory SpaceRental.fromJson(Map<String, dynamic> json) =>
      _$SpaceRentalFromJson(json);

  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(defaultValue: '')
  final String shopId;
  @JsonKey(readValue: _readShopDisplayName, defaultValue: '')
  final String shopName;
  @JsonKey(defaultValue: '')
  final String address;
  final String? detailAddress;
  @JsonKey(defaultValue: '')
  final String regionId;
  final String? regionName;
  @JsonKey(fromJson: _timeSlotsFromJson, defaultValue: [])
  final List<TimeSlot> availableSlots;
  @LooseIntAsZeroConverter()
  final int pricePerHour;
  @JsonKey(fromJson: _facilitiesFromJson, defaultValue: [])
  final List<String> facilities;
  @JsonKey(fromJson: _imageUrlsFromJson)
  final List<String>? imageUrls;
  @JsonKey(fromJson: _spaceStatusFromJson, toJson: _spaceStatusToJson)
  final SpaceStatus status;
  final String? description;
  @IsoDateTimeOrNowConverter()
  final DateTime createdAt;
  @IsoDateTimeNullableConverter()
  final DateTime? updatedAt;
  final String? contactPhone;
  final String? subwayInfo;
  @JsonKey(defaultValue: false)
  final bool isPremium;
  final String? usageNotes;
  @LooseDoubleNullableConverter()
  final double? averageRating;
  @LooseIntNullableConverter()
  final int? reviewCount;
  @JsonKey(fromJson: _reviewsFromJson)
  final List<SpaceRentalReview>? reviews;
  @LooseIntAsOneConverter()
  final int minHours;
  @JsonKey(defaultValue: false)
  final bool isHidden;
  @JsonKey(fromJson: _operatingScheduleFromJson, toJson: _operatingScheduleToJson)
  final SpaceOperatingSchedule? operatingSchedule;

  Map<String, dynamic> toJson() => _$SpaceRentalToJson(this);

  SpaceOperatingSchedule get effectiveOperatingSchedule =>
      operatingSchedule ?? SpaceOperatingSchedule.defaultEveryDay();

  SpaceRental copyWith({
    SpaceStatus? status,
    bool? isHidden,
    SpaceOperatingSchedule? operatingSchedule,
    List<TimeSlot>? availableSlots,
    int? minHours,
    String? usageNotes,
    String? contactPhone,
    String? subwayInfo,
  }) {
    return SpaceRental(
      id: id,
      shopId: shopId,
      shopName: shopName,
      address: address,
      detailAddress: detailAddress,
      regionId: regionId,
      regionName: regionName,
      availableSlots: availableSlots ?? this.availableSlots,
      pricePerHour: pricePerHour,
      facilities: facilities,
      imageUrls: imageUrls,
      status: status ?? this.status,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      contactPhone: contactPhone ?? this.contactPhone,
      subwayInfo: subwayInfo ?? this.subwayInfo,
      isPremium: isPremium,
      usageNotes: usageNotes ?? this.usageNotes,
      averageRating: averageRating,
      reviewCount: reviewCount,
      reviews: reviews,
      minHours: minHours ?? this.minHours,
      isHidden: isHidden ?? this.isHidden,
      operatingSchedule: operatingSchedule ?? this.operatingSchedule,
    );
  }

  List<TimeSlot> getAvailableSlotsForDate(DateTime date) {
    return availableSlots.where((slot) {
      final slotDate = DateTime(
        slot.startTime.year,
        slot.startTime.month,
        slot.startTime.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);
      return slotDate.isAtSameMomentAs(targetDate) && slot.isAvailable;
    }).toList();
  }

  bool isSlotAvailable(DateTime startTime, DateTime endTime) {
    return availableSlots.any((slot) {
      return slot.startTime.isAtSameMomentAs(startTime) &&
          slot.endTime.isAtSameMomentAs(endTime) &&
          slot.isAvailable;
    });
  }

  String get fullAddress {
    if (detailAddress != null && detailAddress!.isNotEmpty) {
      return '$address $detailAddress';
    }
    return address;
  }
}

/// 공간대여 예약 모델
@JsonSerializable(explicitToJson: true)
class SpaceBooking {
  const SpaceBooking({
    required this.id,
    required this.spaceRentalId,
    required this.spareId,
    required this.spareName,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.spaceRental,
  });

  factory SpaceBooking.fromJson(Map<String, dynamic> json) =>
      _$SpaceBookingFromJson(json);

  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(defaultValue: '')
  final String spaceRentalId;
  @JsonKey(defaultValue: '')
  final String spareId;
  @JsonKey(defaultValue: '')
  final String spareName;
  @IsoDateTimeOrNowConverter()
  final DateTime startTime;
  @IsoDateTimeOrNowConverter()
  final DateTime endTime;
  @LooseIntAsZeroConverter()
  final int totalPrice;
  @JsonKey(fromJson: _bookingStatusFromJson, toJson: _bookingStatusToJson)
  final BookingStatus status;
  @IsoDateTimeOrNowConverter()
  final DateTime createdAt;
  @JsonKey(fromJson: _nestedSpaceRentalFromJson)
  final SpaceRental? spaceRental;

  Map<String, dynamic> toJson() => _$SpaceBookingToJson(this);

  int get durationInMinutes => endTime.difference(startTime).inMinutes;

  double get durationInHours => durationInMinutes / 60.0;

  bool get isInProgress {
    final now = DateTime.now();
    return status == BookingStatus.inProgress ||
        (status == BookingStatus.confirmed &&
            now.isAfter(startTime) &&
            now.isBefore(endTime));
  }

  bool get canCancel {
    if (status == BookingStatus.cancelled ||
        status == BookingStatus.completed) {
      return false;
    }
    final now = DateTime.now();
    final hoursUntilStart = startTime.difference(now).inHours;
    return hoursUntilStart >= 24;
  }
}

enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
}
