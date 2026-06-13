import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/di/service_locator.dart';
import '../core/services/global_messenger_service.dart';
import '../providers/chat_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/job_provider.dart';
import '../providers/notification_provider.dart';

/// 스페어 홈: 초기 데이터 병렬 로드 + 10초 주기 알림·채팅 목록 갱신.
class SpareHomeViewModel extends ChangeNotifier {
  SpareHomeViewModel({
    required JobProvider jobProvider,
    required FavoriteProvider favoriteProvider,
    required NotificationProvider notificationProvider,
    required ChatProvider chatProvider,
  })  : _jobProvider = jobProvider,
        _favoriteProvider = favoriteProvider,
        _notificationProvider = notificationProvider,
        _chatProvider = chatProvider;

  final JobProvider _jobProvider;
  final FavoriteProvider _favoriteProvider;
  final NotificationProvider _notificationProvider;
  final ChatProvider _chatProvider;

  GlobalMessengerService get _m => sl<GlobalMessengerService>();

  Timer? _pollTimer;

  /// 공고·찜·알림·채팅을 한 번에 불러옵니다.
  Future<void> loadInitial() async {
    try {
      await Future.wait<void>([
        _jobProvider.loadJobs(),
        _favoriteProvider.loadFavorites(),
        _notificationProvider.loadNotifications(audience: 'spare'),
        _chatProvider.loadChats(viewerRole: 'spare'),
      ]);
    } catch (e, st) {
      debugPrint('SpareHomeViewModel.loadInitial: $e\n$st');
      _m.showError('일부 데이터를 불러오지 못했습니다.');
    }
  }

  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _notificationProvider.refreshNotifications();
      _chatProvider.refreshChats(viewerRole: 'spare');
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
