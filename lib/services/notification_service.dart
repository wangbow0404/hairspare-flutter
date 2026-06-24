import 'package:dio/dio.dart';
import '../utils/api_config.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';
import '../models/notification.dart';
import '../mocks/mock_shop_data.dart';
import '../mocks/mock_spare_data.dart';
import '../mocks/mock_model_messaging_data.dart';
import '../core/di/service_locator.dart';

class NotificationSettings {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool jobAlerts;
  final bool messages;
  final bool scheduleReminders;
  final bool energyUpdates;
  final bool verificationStatus;
  final bool challengeNotifications; // 챌린지 알림 (구독한 크리에이터의 새 영상)

  NotificationSettings({
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.jobAlerts = true,
    this.messages = true,
    this.scheduleReminders = true,
    this.energyUpdates = true,
    this.verificationStatus = true,
    this.challengeNotifications = true,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushEnabled: json['pushEnabled'] as bool? ?? true,
      emailEnabled: json['emailEnabled'] as bool? ?? true,
      jobAlerts: json['jobAlerts'] as bool? ?? true,
      messages: json['messages'] as bool? ?? true,
      scheduleReminders: json['scheduleReminders'] as bool? ?? true,
      energyUpdates: json['energyUpdates'] as bool? ?? true,
      verificationStatus: json['verificationStatus'] as bool? ?? true,
      challengeNotifications: json['challengeNotifications'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'jobAlerts': jobAlerts,
      'messages': messages,
      'scheduleReminders': scheduleReminders,
      'energyUpdates': energyUpdates,
      'verificationStatus': verificationStatus,
      'challengeNotifications': challengeNotifications,
    };
  }
}

class NotificationService {
  final Dio _dio = sl<Dio>();

  /// 알림 설정 조회
  Future<NotificationSettings> getNotificationSettings() async {
    if (ApiConfig.useMockData) return await MockSpareData.getNotificationSettings();
    try {
      final response = await _dio.get('/api/notifications/settings');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return NotificationSettings.fromJson(data);
      } else {
        throw ServerException(
          '알림 설정 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 알림 설정 저장
  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    try {
      final response = await _dio.put(
        '/api/notifications/settings',
        data: settings.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          '알림 설정 저장 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 알림 목록 조회
  Future<List<AppNotification>> getNotifications({
    bool? isRead,
    String? type,
    int? limit,
    int? offset,
    String audience = 'spare',
  }) async {
    if (ApiConfig.useMockData) {
      if (audience == 'shop') {
        return MockShopData.getShopNotifications();
      }
      if (audience == 'model') {
        return MockSpareData.getModelNotifications();
      }
      return MockSpareData.getSpareNotifications();
    }
    try {
      final queryParams = <String, dynamic>{};
      if (isRead != null) queryParams['isRead'] = isRead.toString();
      if (type != null) queryParams['type'] = type;
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();

      final response = await _dio.get(
        '/api/notifications',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> notificationsJson = data is List
            ? data
            : (data is Map && data['notifications'] != null
                ? (data['notifications'] as List)
                : []);
        return notificationsJson
            .whereType<Map<String, dynamic>>()
            .map((json) => AppNotification.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          '알림 목록 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 알림 읽음 처리 (자세히 보기에서는 읽음 섹션으로 이동).
  Future<void> markAsRead(String notificationId, {String audience = 'spare'}) async {
    if (ApiConfig.useMockData) {
      if (audience == 'shop') {
        await MockShopData.dismissNotification(notificationId);
      } else if (audience == 'model') {
        await MockModelMessagingData.markNotificationRead(notificationId);
      } else {
        await MockSpareData.markNotificationRead(notificationId);
      }
      return;
    }
    try {
      final response = await _dio.post(
        '/api/notifications/$notificationId/read',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          '알림 읽음 처리 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 알림 삭제
  Future<void> deleteNotification(
    String notificationId, {
    String audience = 'spare',
  }) async {
    if (ApiConfig.useMockData) {
      if (audience == 'shop') {
        await MockShopData.dismissNotification(notificationId);
      } else if (audience == 'model') {
        await MockModelMessagingData.dismissNotification(notificationId);
      } else {
        await MockSpareData.dismissNotification(notificationId);
      }
      return;
    }
    try {
      final response = await _dio.delete(
        '/api/notifications/$notificationId',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          '알림 삭제 실패: ${response.statusMessage}',
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
