import 'package:dio/dio.dart';
import '../utils/api_config.dart';
import '../utils/energy_purchase_pricing.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';
import '../mocks/mock_spare_data.dart';
import '../core/di/service_locator.dart';

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
  final Dio _dio = sl<Dio>();

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
      final response = await _dio.get('/api/energy/wallet');

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

  /// 에너지 사용 (교육 신청 등). 서버가 잔액 검증.
  Future<void> spendEnergy(
    int amount, {
    required String description,
    required String referenceId,
  }) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.mockSpendEnergy(
        amount,
        description: description,
        referenceId: referenceId,
      );
    }
    try {
      final response = await _dio.post(
        '/api/energy/spend',
        data: {
          'amount': amount,
          'description': description,
          'referenceId': referenceId,
        },
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          '에너지 사용 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 에너지 구매
  Future<void> purchaseEnergy(
    int amount, {
    String paymentMethod = 'CARD',
    int? cashPrice,
    int? pointCost,
  }) async {
    if (ApiConfig.useMockData) {
      assertValidEnergyPurchaseAmount(amount);
      return MockSpareData.mockPurchaseEnergy(
        energyAmount: amount,
        paymentMethod: paymentMethod,
        cashPrice: cashPrice,
        pointCost: pointCost,
      );
    }
    try {
      final response = await _dio.post(
        '/api/energy/purchase',
        data: {
          'amount': amount,
          'paymentMethod': paymentMethod,
          if (cashPrice != null) 'cashPrice': cashPrice,
          if (pointCost != null) 'pointCost': pointCost,
        },
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
