import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../core/network/api_client.dart';
import '../utils/api_config.dart';
import 'chat_service.dart';

/// 채팅방 실시간 메시지 수신(WebSocket). `admin_realtime_service.dart`와 동일한
/// 연결·인증·재연결 패턴을 쓰되, 앱 전역 싱글턴이 아니라 화면(ChatRoomScreen)이
/// 진입 시 connect(), 나갈 때 dispose()로 직접 소유하는 인스턴스다 — 한 번에
/// 채팅방 하나만 열려있는 사용 패턴이라 ref-counting이 필요 없다.
class ChatRealtimeService {
  final StreamController<Message> _messages =
      StreamController<Message>.broadcast();
  Stream<Message> get messages => _messages.stream;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  bool _connecting = false;
  bool _disposed = false;

  String _wsUrl() {
    final base = ApiConfig.getBaseUrl();
    final uri = Uri.parse(base);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    return Uri(
      scheme: scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      path: '/ws/chat',
    ).toString();
  }

  Future<void> connect() async {
    if (_disposed || _connecting || _channel != null) return;
    if (ApiConfig.useMockData) return;

    _connecting = true;
    _reconnectTimer?.cancel();

    try {
      await _ensureFreshAccessToken();
      final token = await ApiClient().getAuthToken();
      if (token == null || token.isEmpty) {
        if (kDebugMode) {
          debugPrint('[ChatRealtime] JWT 없음 — WS 연결 보류');
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
            debugPrint('[ChatRealtime] WS error: $error');
          }
          _handleDisconnect();
        },
        onDone: () {
          if (kDebugMode) {
            debugPrint('[ChatRealtime] WS closed');
          }
          _handleDisconnect();
        },
        cancelOnError: true,
      );
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('[ChatRealtime] WS open timeout');
      }
      _handleDisconnect();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[ChatRealtime] connect failed: $error');
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
      if (type != 'new_message') return;

      final data = decoded['data'];
      if (data is! Map) return;

      final message = Message.fromJson(Map<String, dynamic>.from(data));
      if (!_messages.isClosed) {
        _messages.add(message);
      }
    } catch (_) {
      // malformed frame — ignore
    }
  }

  void _handleDisconnect() {
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;

    if (!_disposed) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_disposed) connect();
    });
  }

  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    _messages.close();
  }
}
