import 'package:dio/dio.dart';
import '../utils/api_config.dart';
import '../mocks/mock_spare_data.dart';
import '../core/di/service_locator.dart';
import '../utils/error_handler.dart';

class Payment {
  final String id;
  final String type;
  final int amount;
  final String status;
  final DateTime createdAt;
  final String? description;

  Payment({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.description,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      amount: json['amount'] is int
          ? json['amount']
          : int.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      description: json['description']?.toString(),
    );
  }
}

class PaymentService {
  final Dio _dio = sl<Dio>();

  /// 결제 내역 조회
  Future<List<Payment>> getPayments() async {
    if (ApiConfig.useMockData) return await MockSpareData.getPayments();
    try {
      final response = await _dio.get('/api/payments');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> paymentsJson = data is List
            ? data
            : (data is Map && data['payments'] != null
                ? (data['payments'] as List)
                : []);
        return paymentsJson
            .whereType<Map<String, dynamic>>()
            .map((json) => Payment.fromJson(json))
            .toList();
      } else {
        throw Exception('결제 내역 조회 실패: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('결제 내역 조회 오류: ${e.message}');
    }
  }

  /// 결제 생성
  Future<Map<String, dynamic>> createPayment({
    required String type,
    required int amount,
    required String paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    if (ApiConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return {
        'payment': {
          'id': 'mock-pay-${DateTime.now().millisecondsSinceEpoch}',
          'type': type,
          'amount': amount,
          'status': 'completed',
          'paymentMethod': paymentMethod,
          if (metadata != null) 'metadata': metadata,
        },
        'paymentUrl': null,
      };
    }

    try {
      final response = await _dio.post(
        '/api/payments',
        data: {
          'type': type,
          'amount': amount,
          'paymentMethod': paymentMethod,
          if (metadata != null) 'metadata': metadata,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return {
          'payment': data['payment'] ?? data,
          'paymentUrl': data['paymentUrl'],
        };
      } else {
        throw Exception('결제 생성 실패: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('결제 생성 오류: ${e.message}');
    }
  }
}

/// 채팅 안에서 주고받는 결제 요청 — 모델↔디자이너(스페어/샵) 채팅 전용.
class PaymentRequest {
  final String id;
  final String chatId;
  final String payerId;
  final String payeeId;
  final int amount;
  final String? purpose;
  final String status; // requested | accepted | declined | paid | cancelled
  final String? scheduledDate; // YYYY-MM-DD, 모델 촬영/시술 확정 날짜
  final DateTime createdAt;

  PaymentRequest({
    required this.id,
    required this.chatId,
    required this.payerId,
    required this.payeeId,
    required this.amount,
    this.purpose,
    required this.status,
    this.scheduledDate,
    required this.createdAt,
  });

  factory PaymentRequest.fromJson(Map<String, dynamic> json) {
    return PaymentRequest(
      id: json['id']?.toString() ?? '',
      chatId: json['chatId']?.toString() ?? '',
      payerId: json['payerId']?.toString() ?? '',
      payeeId: json['payeeId']?.toString() ?? '',
      amount: json['amount'] is int
          ? json['amount']
          : int.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      purpose: json['purpose']?.toString(),
      status: json['status']?.toString() ?? 'requested',
      scheduledDate: json['scheduledDate']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class PaymentRequestService {
  final Dio _dio = sl<Dio>();

  Future<PaymentRequest> createPaymentRequest({
    required String chatId,
    required int amount,
    required String payerId,
    String? purpose,
    String? date,
  }) async {
    try {
      final response = await _dio.post(
        '/api/chats/$chatId/payments',
        data: {
          'amount': amount,
          'payerId': payerId,
          if (purpose != null) 'purpose': purpose,
          if (date != null) 'date': date,
        },
      );
      final data = response.data['data'] ?? response.data;
      return PaymentRequest.fromJson(
        Map<String, dynamic>.from(data['payment'] as Map),
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<PaymentRequest> _postAction(String paymentId, String action) async {
    try {
      final response = await _dio.post('/api/payments/$paymentId/$action');
      final data = response.data['data'] ?? response.data;
      return PaymentRequest.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<PaymentRequest> acceptPayment(String paymentId) =>
      _postAction(paymentId, 'accept');

  Future<PaymentRequest> declinePayment(String paymentId) =>
      _postAction(paymentId, 'decline');

  Future<PaymentRequest> cancelPayment(String paymentId) =>
      _postAction(paymentId, 'cancel');

  /// 결제 실행 — PG 연동 전까지는 즉시 결제완료로 처리된다(실제 이체 없음).
  Future<PaymentRequest> payPayment(String paymentId) =>
      _postAction(paymentId, 'pay');

  Future<PaymentRequest> getPaymentRequest(String paymentId) async {
    try {
      final response = await _dio.get('/api/payments/$paymentId');
      final data = response.data['data'] ?? response.data;
      return PaymentRequest.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 결제 완료(paid)되고 날짜가 지정된 내 결제 요청의 확정 날짜 목록 (YYYY-MM-DD).
  /// 스페어 근무 캘린더의 「모델매칭」 표시에 사용.
  Future<Set<String>> getConfirmedDates() async {
    try {
      final response = await _dio.get('/api/payments/confirmed-dates');
      final data = response.data['data'] ?? response.data;
      final dates = (data['dates'] as List?) ?? const [];
      return dates.map((d) => d.toString()).toSet();
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}
