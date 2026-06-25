import 'package:dio/dio.dart';

import '../core/di/service_locator.dart';
import '../mocks/mock_admin_data.dart';
import '../utils/api_config.dart';
import '../utils/error_handler.dart';

class ReportService {
  final Dio _dio = sl<Dio>();

  /// 신고 제출
  ///
  /// [category]: noshow | contact | abuse | payment | other
  /// [summary]: 신고 사유 상세
  /// [reportedUserId]: 신고 대상 사용자 ID (없으면 null)
  /// [referenceId]: 관련 리소스 ID (공고·스케줄·챌린지 ID 등)
  /// [referenceType]: 관련 리소스 타입 ('job' | 'schedule' | 'challenge' | 'chat')
  Future<void> submitReport({
    required String category,
    required String summary,
    String? reportedUserId,
    String? referenceId,
    String? referenceType,
  }) async {
    if (ApiConfig.useMockData) {
      await MockAdminData.addReport(
        category: category,
        summary: summary,
        reportedUserId: reportedUserId,
        referenceId: referenceId,
        referenceType: referenceType,
      );
      return;
    }
    try {
      await _dio.post('/api/reports', data: {
        'category': category,
        'summary': summary,
        if (reportedUserId != null) 'reportedUserId': reportedUserId,
        if (referenceId != null) 'referenceId': referenceId,
        if (referenceType != null) 'referenceType': referenceType,
      });
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}
