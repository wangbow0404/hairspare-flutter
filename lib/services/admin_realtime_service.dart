import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../core/network/api_client.dart';
import '../utils/api_config.dart';

/// 관리자 화면 실시간 이벤트(WebSocket).
///
/// 여러 화면이 동시에 구독해도 물리 연결은 하나만 유지한다.
class AdminRealtimeService {
  AdminRealtimeService._();

  static final AdminRealtimeService instance = AdminRealtimeService._();

  final StreamController<String> _events = StreamController<String>.broadcast();
  final ValueNotifier<bool> isConnected = ValueNotifier(false);

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  int _listenerCount = 0;
  bool _connecting = false;

  Stream<String> get events => _events.stream;

  void addListener() {
    _listenerCount++;
    if (_listenerCount == 1) {
      _connect();
    }
  }

  void removeListener() {
    if (_listenerCount <= 0) return;
    _listenerCount--;
    if (_listenerCount == 0) {
      _disconnect();
    }
  }

  /// 로그인 직후 등 토큰이 갱신됐을 때 WS를 다시 연다.
  void reconnect() {
    _disconnect();
    if (_listenerCount > 0) {
      unawaited(_connect());
    }
  }

  String _wsUrl() {
    final base = ApiConfig.getBaseUrl();
    final uri = Uri.parse(base);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    return Uri(
      scheme: scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      path: '/ws/admin',
    ).toString();
  }

  Future<void> _connect() async {
    if (_connecting || _channel != null) return;
    if (ApiConfig.useMockData) {
      isConnected.value = false;
      return;
    }

    _connecting = true;
    _reconnectTimer?.cancel();

    try {
      await _ensureFreshAccessToken();
      final token = await ApiClient().getAuthToken();
      if (token == null || token.isEmpty) {
        if (kDebugMode) {
          debugPrint('[AdminRealtime] JWT 없음 — WS 연결 보류');
        }
        _scheduleReconnect();
        return;
      }

      final channel = WebSocketChannel.connect(Uri.parse(_wsUrl()));
      // 웹/네이티브 모두 소켓이 열린 뒤 인증 메시지를 보내야 서버가 토큰을 받는다.
      await channel.ready.timeout(const Duration(seconds: 10));
      channel.sink.add(jsonEncode({'token': token}));

      _channel = channel;
      _subscription = channel.stream.listen(
        _onMessage,
        onError: (Object error) {
          if (kDebugMode) {
            debugPrint('[AdminRealtime] WS error: $error');
          }
          _handleDisconnect();
        },
        onDone: () {
          if (kDebugMode) {
            debugPrint('[AdminRealtime] WS closed');
          }
          _handleDisconnect();
        },
        cancelOnError: true,
      );
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('[AdminRealtime] WS open timeout');
      }
      _handleDisconnect();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[AdminRealtime] connect failed: $error');
      }
      _handleDisconnect();
    } finally {
      _connecting = false;
    }
  }

  /// REST 인터셉터가 만료 토큰을 refresh한 뒤 WS에 최신 JWT를 쓰게 한다.
  Future<void> _ensureFreshAccessToken() async {
    try {
      await ApiClient().dio.get(
        '/api/auth/me',
        options: Options(
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
    } catch (_) {
      // 토큰이 없거나 refresh 실패 — 아래 getAuthToken()에서 재시도/재연결
    }
  }

  void _onMessage(dynamic raw) {
    try {
      final decoded = jsonDecode(raw as String);
      if (decoded is! Map) return;

      final type = decoded['type']?.toString();
      if (type == null || type.isEmpty) return;

      if (type == 'connected') {
        isConnected.value = true;
        return;
      }

      if (!_events.isClosed) {
        _events.add(type);
      }
    } catch (_) {
      // malformed frame — ignore
    }
  }

  void _handleDisconnect() {
    isConnected.value = false;
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;

    if (_listenerCount > 0) {
      _scheduleReconnect();
    }
  }

  void _disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    isConnected.value = false;
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    _connecting = false;
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (_listenerCount > 0) {
        _connect();
      }
    });
  }
}
