import 'package:dio/dio.dart';
import '../utils/api_client.dart';
import '../utils/api_config.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';
import '../mocks/mock_spare_data.dart';

class EnergyTransaction {
  final String id;
  final String type;
  final int amount;
  final String description;
  final DateTime timestamp;

  EnergyTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
  });

  factory EnergyTransaction.fromJson(Map<String, dynamic> json) {
    return EnergyTransaction(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? json['state']?.toString() ?? '',
      amount: json['amount'] is int
          ? json['amount']
          : int.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      description: json['description']?.toString() ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'].toString())
          : (json['createdAt'] != null
              ? DateTime.parse(json['createdAt'].toString())
              : DateTime.now()),
    );
  }
}

class EnergyService {
  final ApiClient _apiClient = ApiClient();

  /// 에너지 지갑 정보 조회
  Future<Map<String, dynamic>> getWallet() async {
    if (ApiConfig.useMockData) {
      final data = await MockSpareData.getWallet();
      return {
        'balance': data['balance'],
        'transactions': (data['transactions'] as List)
            .map((t) => EnergyTransaction.fromJson(t as Map<String, dynamic>))
            .toList(),
      };
    }
    try {
      final response = await _apiClient.dio.get('/api/energy/wallet');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return {
          'balance': data['balance'] ?? 0,
          'transactions': (data['transactions'] as List?)
                  ?.map((t) => EnergyTransaction.fromJson(t))
                  .toList() ??
              [],
        };
      } else {
        throw ServerException(
          '에너지 지갑 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 에너지 잔액 조회
  Future<int> getBalance() async {
    try {
      final wallet = await getWallet();
      return wallet['balance'] as int? ?? 0;
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 에너지 구매
  Future<void> purchaseEnergy(int amount) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/energy/purchase',
        data: {'amount': amount},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          '에너지 구매 실패: ${response.statusMessage}',
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
