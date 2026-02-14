/// 공간대여 모델
/// 미용실이 공간을 시간 단위로 대여할 수 있도록 하는 시스템

/// 공간대여 리뷰
class SpaceRentalReview {
  final String userName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  SpaceRentalReview({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory SpaceRentalReview.fromJson(Map<String, dynamic> json) {
    return SpaceRentalReview(
      userName: json['userName']?.toString() ?? '',
      rating: json['rating'] is int ? json['rating'] : int.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      comment: json['comment']?.toString() ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now(),
    );
  }
}

enum SpaceStatus {
  available, // 예약 가능
  booked, // 예약됨
  unavailable, // 사용 불가
}

/// 시간대 슬롯
class TimeSlot {
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final String? bookedBy; // 예약한 스페어 ID
  final String? bookingId; // 예약 ID

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.bookedBy,
    this.bookingId,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      isAvailable: json['isAvailable'] ?? true,
      bookedBy: json['bookedBy'],
      bookingId: json['bookingId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAvailable': isAvailable,
      'bookedBy': bookedBy,
      'bookingId': bookingId,
    };
  }

  /// 시간대의 시간(분) 계산
  int get durationInMinutes {
    return endTime.difference(startTime).inMinutes;
  }

  /// 시간대의 시간(시간) 계산
  double get durationInHours {
    return durationInMinutes / 60.0;
  }
}

/// 공간대여 모델
class SpaceRental {
  final String id;
  final String shopId;
  final String shopName;
  final String address; // 주소
  final String? detailAddress; // 상세 주소
  final String regionId; // 지역 ID
  final String? regionName; // 지역명
  final List<TimeSlot> availableSlots; // 예약 가능한 시간대
  final int pricePerHour; // 시간당 가격
  final List<String> facilities; // 시설 (의자, 세트, 샴푸대 등)
  final List<String>? imageUrls; // 공간 사진 (여러 장)
  final SpaceStatus status;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? contactPhone;
  final String? subwayInfo;
  final bool isPremium;
  final String? usageNotes;
  final double? averageRating;
  final int? reviewCount;
  final List<SpaceRentalReview>? reviews;
  final int minHours;

  SpaceRental({
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
  });

  factory SpaceRental.fromJson(Map<String, dynamic> json) {
    return SpaceRental(
      id: json['id']?.toString() ?? '',
      shopId: json['shopId']?.toString() ?? '',
      shopName: json['shopName']?.toString() ?? json['shopId']?.toString() ?? '미용실',
      address: json['address']?.toString() ?? '',
      detailAddress: json['detailAddress']?.toString(),
      regionId: json['regionId']?.toString() ?? '',
      regionName: json['regionName']?.toString(),
      availableSlots: (json['availableSlots'] as List<dynamic>?)
              ?.map((slot) => TimeSlot.fromJson(slot as Map<String, dynamic>))
              .toList() ??
          [],
      pricePerHour: json['pricePerHour'] is int
          ? json['pricePerHour']
          : int.tryParse(json['pricePerHour']?.toString() ?? '0') ?? 0,
      facilities: (json['facilities'] as List<dynamic>?)
              ?.map((f) => f.toString())
              .toList() ??
          [],
      imageUrls: (json['imageUrls'] as List<dynamic>?)
          ?.map((url) => url.toString())
          .toList(),
      status: _parseStatus(json['status']),
      description: json['description']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
      contactPhone: json['contactPhone']?.toString(),
      subwayInfo: json['subwayInfo']?.toString(),
      isPremium: json['isPremium'] == true,
      usageNotes: json['usageNotes']?.toString(),
      averageRating: (json['averageRating'] is num) ? (json['averageRating'] as num).toDouble() : null,
      reviewCount: json['reviewCount'] != null
          ? (json['reviewCount'] is int ? json['reviewCount'] as int : int.tryParse(json['reviewCount'].toString()))
          : null,
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((r) => SpaceRentalReview.fromJson(r as Map<String, dynamic>))
          .toList(),
      minHours: json['minHours'] is int ? json['minHours'] : int.tryParse(json['minHours']?.toString() ?? '1') ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'shopName': shopName,
      'address': address,
      'detailAddress': detailAddress,
      'regionId': regionId,
      'regionName': regionName,
      'availableSlots': availableSlots.map((slot) => slot.toJson()).toList(),
      'pricePerHour': pricePerHour,
      'facilities': facilities,
      'imageUrls': imageUrls,
      'status': status.name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static SpaceStatus _parseStatus(dynamic status) {
    if (status == null) return SpaceStatus.available;
    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'available':
      case 'active': // FastAPI에서 사용하는 "active" 상태를 "available"로 매핑
        return SpaceStatus.available;
      case 'booked':
        return SpaceStatus.booked;
      case 'unavailable':
        return SpaceStatus.unavailable;
      default:
        return SpaceStatus.available;
    }
  }

  /// 특정 날짜의 예약 가능한 시간대 필터링
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

  /// 특정 시간대가 예약 가능한지 확인
  bool isSlotAvailable(DateTime startTime, DateTime endTime) {
    return availableSlots.any((slot) {
      return slot.startTime.isAtSameMomentAs(startTime) &&
          slot.endTime.isAtSameMomentAs(endTime) &&
          slot.isAvailable;
    });
  }

  /// 전체 주소 (주소 + 상세주소)
  String get fullAddress {
    if (detailAddress != null && detailAddress!.isNotEmpty) {
      return '$address $detailAddress';
    }
    return address;
  }
}

/// 공간대여 예약 모델
class SpaceBooking {
  final String id;
  final String spaceRentalId;
  final String spareId; // 예약한 스페어 ID
  final String spareName; // 예약한 스페어 이름
  final DateTime startTime;
  final DateTime endTime;
  final int totalPrice; // 총 금액
  final BookingStatus status; // 예약 상태
  final DateTime createdAt;
  final SpaceRental? spaceRental; // 공간 정보 (상세 조회 시)

  SpaceBooking({
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

  factory SpaceBooking.fromJson(Map<String, dynamic> json) {
    return SpaceBooking(
      id: json['id']?.toString() ?? '',
      spaceRentalId: json['spaceRentalId']?.toString() ?? '',
      spareId: json['spareId']?.toString() ?? '',
      spareName: json['spareName']?.toString() ?? '',
      startTime: DateTime.parse(json['startTime'].toString()),
      endTime: DateTime.parse(json['endTime'].toString()),
      totalPrice: json['totalPrice'] is int
          ? json['totalPrice']
          : int.tryParse(json['totalPrice']?.toString() ?? '0') ?? 0,
      status: _parseBookingStatus(json['status']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      spaceRental: json['spaceRental'] != null
          ? SpaceRental.fromJson(json['spaceRental'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'spaceRentalId': spaceRentalId,
      'spareId': spareId,
      'spareName': spareName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'totalPrice': totalPrice,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static BookingStatus _parseBookingStatus(dynamic status) {
    if (status == null) return BookingStatus.pending;
    final statusStr = status.toString().toLowerCase();
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

  /// 예약 시간(분) 계산
  int get durationInMinutes {
    return endTime.difference(startTime).inMinutes;
  }

  /// 예약 시간(시간) 계산
  double get durationInHours {
    return durationInMinutes / 60.0;
  }

  /// 예약이 진행 중인지 확인
  bool get isInProgress {
    final now = DateTime.now();
    return status == BookingStatus.inProgress ||
        (status == BookingStatus.confirmed &&
            now.isAfter(startTime) &&
            now.isBefore(endTime));
  }

  /// 예약 취소 가능한지 확인 (24시간 전까지만)
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

/// 예약 상태
enum BookingStatus {
  pending, // 대기 중 (결제 전)
  confirmed, // 확정됨 (결제 완료)
  inProgress, // 진행 중
  completed, // 완료됨
  cancelled, // 취소됨
}
