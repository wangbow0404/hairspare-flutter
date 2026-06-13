import 'package:dio/dio.dart';
import '../utils/api_config.dart';
import '../utils/space_booking_rules.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';
import '../models/space_operating_schedule.dart';
import '../models/space_rental.dart';
import '../utils/space_slot_builder.dart';
import '../mocks/mock_spare_data.dart';
import '../core/di/service_locator.dart';

/// 공간대여 서비스
class SpaceRentalService {
  final Dio _dio = sl<Dio>();

  /// 공간 검색
  /// 
  /// [regionId] 지역 ID (선택)
  /// [date] 검색할 날짜 (선택)
  /// [startTime] 시작 시간 (선택)
  /// [endTime] 종료 시간 (선택)
  /// [minPrice] 최소 가격 (선택)
  /// [maxPrice] 최대 가격 (선택)
  /// [facilities] 시설 필터 (선택)
  Future<List<SpaceRental>> getSpaceRentals({
    String? regionId,
    String? date, // YYYY-MM-DD 형식
    String? startTime, // ISO string
    String? endTime, // ISO string
    int? minPrice,
    int? maxPrice,
    List<String>? facilities,
  }) async {
    if (ApiConfig.useMockData) return await MockSpareData.getSpaceRentals();
    try {
      final queryParams = <String, dynamic>{};
      
      if (regionId != null) {
        queryParams['regionId'] = regionId;
      }
      if (date != null) {
        queryParams['date'] = date; // 이미 YYYY-MM-DD 형식
      }
      if (startTime != null) {
        queryParams['startTime'] = startTime; // 이미 ISO string
      }
      if (endTime != null) {
        queryParams['endTime'] = endTime; // 이미 ISO string
      }
      if (minPrice != null) {
        queryParams['minPrice'] = minPrice;
      }
      if (maxPrice != null) {
        queryParams['maxPrice'] = maxPrice;
      }
      if (facilities != null && facilities.isNotEmpty) {
        queryParams['facilities'] = facilities.join(',');
      }

      final response = await _dio.get(
        '/api/space-rentals',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> rentalsJson = data is List
            ? data
            : (data is Map && data['rentals'] != null
                ? (data['rentals'] as List)
                : []);
        return rentalsJson
            .whereType<Map<String, dynamic>>()
            .map((json) => SpaceRental.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          '공간 검색 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 공간 상세 조회
  Future<SpaceRental> getSpaceRentalById(String id) async {
    if (ApiConfig.useMockData) return await MockSpareData.getSpaceRentalById(id);
    try {
      final response = await _dio.get('/api/space-rentals/$id');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return SpaceRental.fromJson(data as Map<String, dynamic>);
      } else {
        throw ServerException(
          '공간 상세 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 공간 예약
  /// 
  /// [spaceId] 공간 ID
  /// [startTime] 시작 시간
  /// [endTime] 종료 시간
  Future<SpaceBooking> bookSpace({
    required String spaceId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    if (ApiConfig.useMockData) {
      final duration = endTime.difference(startTime).inHours;
      final space = await MockSpareData.getSpaceRentalById(spaceId);
      if (!SpaceBookingRules.meetsMinHours(
        selectedHours: duration,
        minHours: space.minHours,
      )) {
        throw ValidationException(
          SpaceBookingRules.belowMinHoursMessage(space.minHours),
        );
      }
      final totalPrice = duration * space.pricePerHour;
      final booking = SpaceBooking(
        id: 'booking-mock-${DateTime.now().millisecondsSinceEpoch}',
        spaceRentalId: spaceId,
        spareId: 'mock-spare-1',
        spareName: '김디자이너',
        startTime: startTime,
        endTime: endTime,
        totalPrice: totalPrice,
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
        spaceRental: space,
      );
      return MockSpareData.submitSpaceBookingRequest(booking);
    }
    try {
      final response = await _dio.post(
        '/api/space-rentals/$spaceId/book',
        data: {
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return SpaceBooking.fromJson(data as Map<String, dynamic>);
      } else {
        throw ServerException(
          '공간 예약 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 예약 취소
  Future<void> cancelBooking(String bookingId) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.cancelSpaceBooking(bookingId);
    }
    try {
      final response = await _dio.delete(
        '/api/space-rentals/bookings/$bookingId',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          '예약 취소 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 내 예약 내역 조회
  Future<List<SpaceBooking>> getMyBookings({
    BookingStatus? status,
  }) async {
    if (ApiConfig.useMockData) return await MockSpareData.getMySpaceBookings();
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) {
        queryParams['status'] = status.name;
      }

      final response = await _dio.get(
        '/api/space-rentals/my-bookings',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> bookingsJson = data is List
            ? data
            : (data is Map && data['bookings'] != null
                ? (data['bookings'] as List)
                : []);
        return bookingsJson
            .whereType<Map<String, dynamic>>()
            .map((json) => SpaceBooking.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          '예약 내역 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 예약 상세 조회
  Future<SpaceBooking> getBookingById(String bookingId) async {
    try {
      final response = await _dio.get(
        '/api/space-rentals/bookings/$bookingId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return SpaceBooking.fromJson(data as Map<String, dynamic>);
      } else {
        throw ServerException(
          '예약 상세 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  // ========== Shop 역할 전용 메서드 ==========

  /// 공간 등록 (Shop)
  /// 
  /// [address] 주소
  /// [detailAddress] 상세 주소 (선택)
  /// [regionId] 지역 ID
  /// [pricePerHour] 시간당 가격
  /// [facilities] 시설 목록
  /// [imageUrls] 공간 사진 URL 목록 (선택)
  /// [description] 공간 설명 (선택)
  /// [availableSlots] 예약 가능한 시간대 목록
  Future<SpaceRental> createSpaceRental({
    required String address,
    String? detailAddress,
    required String regionId,
    required int pricePerHour,
    required List<String> facilities,
    required SpaceOperatingSchedule operatingSchedule,
    required int minHours,
    List<String>? imageUrls,
    String? description,
    String? usageNotes,
    String? contactPhone,
    String? subwayInfo,
    List<TimeSlot>? availableSlots,
  }) async {
    final slots = availableSlots ??
        SpaceSlotBuilder.build(schedule: operatingSchedule);
    if (ApiConfig.useMockData) {
      return MockSpareData.createShopSpaceRental(
        address: address,
        detailAddress: detailAddress,
        regionId: regionId,
        pricePerHour: pricePerHour,
        facilities: facilities,
        imageUrls: imageUrls,
        description: description,
        operatingSchedule: operatingSchedule,
        minHours: minHours,
        usageNotes: usageNotes,
        contactPhone: contactPhone,
        subwayInfo: subwayInfo,
        availableSlots: slots,
      );
    }
    try {
      final response = await _dio.post(
        '/api/space-rentals',
        data: {
          'address': address,
          'detailAddress': detailAddress,
          'regionId': regionId,
          'pricePerHour': pricePerHour,
          'facilities': facilities,
          'imageUrls': imageUrls,
          'description': description,
          'operatingSchedule': operatingSchedule.toJson(),
          'minHours': minHours,
          'usageNotes': usageNotes,
          'contactPhone': contactPhone,
          'subwayInfo': subwayInfo,
          'availableSlots': slots.map((slot) => slot.toJson()).toList(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return SpaceRental.fromJson(data as Map<String, dynamic>);
      } else {
        throw ServerException(
          '공간 등록 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 공간 수정 (Shop)
  /// 
  /// [spaceId] 공간 ID
  /// [address] 주소 (선택)
  /// [detailAddress] 상세 주소 (선택)
  /// [regionId] 지역 ID (선택)
  /// [pricePerHour] 시간당 가격 (선택)
  /// [facilities] 시설 목록 (선택)
  /// [imageUrls] 공간 사진 URL 목록 (선택)
  /// [description] 공간 설명 (선택)
  /// [availableSlots] 예약 가능한 시간대 목록 (선택)
  /// [status] 공간 상태 (선택)
  Future<SpaceRental> updateSpaceRental({
    required String spaceId,
    String? address,
    String? detailAddress,
    String? regionId,
    int? pricePerHour,
    List<String>? facilities,
    List<String>? imageUrls,
    String? description,
    List<TimeSlot>? availableSlots,
    SpaceOperatingSchedule? operatingSchedule,
    int? minHours,
    String? usageNotes,
    String? contactPhone,
    String? subwayInfo,
    SpaceStatus? status,
  }) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.updateShopSpaceRental(
        spaceId: spaceId,
        address: address,
        detailAddress: detailAddress,
        regionId: regionId,
        pricePerHour: pricePerHour,
        facilities: facilities,
        imageUrls: imageUrls,
        description: description,
        availableSlots: availableSlots,
        operatingSchedule: operatingSchedule,
        minHours: minHours,
        usageNotes: usageNotes,
        contactPhone: contactPhone,
        subwayInfo: subwayInfo,
        status: status,
      );
    }
    try {
      final data = <String, dynamic>{};
      if (address != null) data['address'] = address;
      if (detailAddress != null) data['detailAddress'] = detailAddress;
      if (regionId != null) data['regionId'] = regionId;
      if (pricePerHour != null) data['pricePerHour'] = pricePerHour;
      if (facilities != null) data['facilities'] = facilities;
      if (imageUrls != null) data['imageUrls'] = imageUrls;
      if (description != null) data['description'] = description;
      if (operatingSchedule != null) {
        data['operatingSchedule'] = operatingSchedule.toJson();
      }
      if (minHours != null) data['minHours'] = minHours;
      if (usageNotes != null) data['usageNotes'] = usageNotes;
      if (contactPhone != null) data['contactPhone'] = contactPhone;
      if (subwayInfo != null) data['subwayInfo'] = subwayInfo;
      if (availableSlots != null) {
        data['availableSlots'] = availableSlots.map((slot) => slot.toJson()).toList();
      }
      if (status != null) data['status'] = status.name;

      final response = await _dio.put(
        '/api/space-rentals/$spaceId',
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data['data'] ?? response.data;
        return SpaceRental.fromJson(responseData as Map<String, dynamic>);
      } else {
        throw ServerException(
          '공간 수정 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 공간 숨김 (Shop) — 스페어 검색·목록에서 제외.
  Future<SpaceRental> hideSpaceRental(String spaceId) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.hideShopSpaceRental(spaceId);
    }
    try {
      final response = await _dio.post(
        '/api/space-rentals/$spaceId/hide',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return SpaceRental.fromJson(data as Map<String, dynamic>);
      }
      throw ServerException(
        '공간 숨김 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 공간 숨김 해제 (Shop)
  Future<SpaceRental> unhideSpaceRental(String spaceId) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.unhideShopSpaceRental(spaceId);
    }
    try {
      final response = await _dio.post(
        '/api/space-rentals/$spaceId/unhide',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return SpaceRental.fromJson(data as Map<String, dynamic>);
      }
      throw ServerException(
        '공간 숨김 해제 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 공간 삭제 (Shop)
  Future<void> deleteSpaceRental(String spaceId) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.deleteShopSpaceRental(spaceId);
    }
    try {
      final response = await _dio.delete(
        '/api/space-rentals/$spaceId',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          '공간 삭제 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 내가 등록한 공간 목록 조회 (Shop)
  Future<List<SpaceRental>> getMySpaceRentals({
    SpaceStatus? status,
  }) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.getMySpaceRentals(status: status);
    }
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) {
        queryParams['status'] = status.name;
      }

      final response = await _dio.get(
        '/api/space-rentals/my-spaces',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // FastAPI 응답 형식 처리: {"success": True, "data": {"rentals": [...], "total": ...}}
        List<dynamic> rentalsJson = [];
        
        if (responseData is Map) {
          // success/data/rentals 형식 (FastAPI Gateway)
          if (responseData['success'] == true && responseData['data'] != null) {
            final data = responseData['data'];
            if (data is Map && data['rentals'] != null) {
              rentalsJson = data['rentals'] as List;
            } else if (data is List) {
              rentalsJson = data;
            }
          }
          // data/rentals 형식
          else if (responseData['data'] != null) {
            final data = responseData['data'];
            if (data is Map && data['rentals'] != null) {
              rentalsJson = data['rentals'] as List;
            } else if (data is List) {
              rentalsJson = data;
            }
          }
          // 직접 rentals 형식
          else if (responseData['rentals'] != null) {
            rentalsJson = responseData['rentals'] as List;
          }
        } else if (responseData is List) {
          rentalsJson = responseData;
        }
        
        return rentalsJson
            .whereType<Map<String, dynamic>>()
            .map((json) => SpaceRental.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          '내 공간 목록 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 내 공간의 예약 목록 조회 (Shop)
  /// 
  /// [spaceId] 공간 ID (선택, null이면 모든 공간의 예약 조회)
  /// [status] 예약 상태 필터 (선택)
  Future<List<SpaceBooking>> getSpaceBookings({
    String? spaceId,
    BookingStatus? status,
  }) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.getShopSpaceBookings(
        spaceId: spaceId,
        status: status,
      );
    }
    try {
      final queryParams = <String, dynamic>{};
      if (spaceId != null) {
        queryParams['spaceId'] = spaceId;
      }
      if (status != null) {
        queryParams['status'] = status.name;
      }

      final response = await _dio.get(
        '/api/space-rentals/my-bookings',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> bookingsJson = data is List
            ? data
            : (data is Map && data['bookings'] != null
                ? (data['bookings'] as List)
                : []);
        return bookingsJson
            .whereType<Map<String, dynamic>>()
            .map((json) => SpaceBooking.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          '예약 목록 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 예약 승인 (Shop)
  Future<void> approveBooking(String bookingId) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.approveShopBooking(bookingId);
    }
    try {
      final response = await _dio.post(
        '/api/space-rentals/bookings/$bookingId/approve',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          '예약 승인 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 예약 거절 (Shop)
  Future<void> rejectBooking(String bookingId, {String? reason}) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.rejectShopBooking(bookingId);
    }
    try {
      final response = await _dio.post(
        '/api/space-rentals/bookings/$bookingId/reject',
        data: reason != null ? {'reason': reason} : null,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          '예약 거절 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}
