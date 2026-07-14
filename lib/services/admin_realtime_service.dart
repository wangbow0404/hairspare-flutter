import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
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
    _connecting = true;
    _reconnectTimer?.cancel();

    try {
      final token = await ApiClient().getAuthToken();
      if (token == null || token.isEmpty) {
        _scheduleReconnect();
        return;
      }

      final channel = WebSocketChannel.connect(Uri.parse(_wsUrl()));
      channel.sink.add(jsonEncode({'token': token}));

      _channel = channel;
      _subscription = channel.stream.listen(
        _onMessage,
        onError: (_) => _handleDisconnect(),
        onDone: _handleDisconnect,
        cancelOnError: true,
      );
    } catch (_) {
      _handleDisconnect();
    } finally {
      _connecting = false;
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
