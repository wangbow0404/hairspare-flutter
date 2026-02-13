import 'package:dio/dio.dart';
import '../utils/api_client.dart';

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
  final ApiClient _apiClient = ApiClient();

  /// 결제 내역 조회
  Future<List<Payment>> getPayments() async {
    try {
      final response = await _apiClient.dio.get('/api/payments');

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
    try {
      final response = await _apiClient.dio.post(
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
