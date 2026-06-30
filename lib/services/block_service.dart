import 'package:dio/dio.dart';

import '../core/di/service_locator.dart';
import '../utils/error_handler.dart';

class BlockService {
  final Dio _dio = sl<Dio>();

  Future<void> blockUser(String userId) async {
    try {
      await _dio.post('/api/users/$userId/block');
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      await _dio.delete('/api/users/$userId/block');
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<List<String>> getBlockedUserIds() async {
    try {
      final response = await _dio.get('/api/users/blocked');
      final data = response.data['data'] ?? response.data;
      final list = data['blockedUserIds'] as List<dynamic>? ?? [];
      return list.cast<String>();
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}
