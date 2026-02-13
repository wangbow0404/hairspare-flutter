import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Android 에뮬레이터는 10.0.2.2를 사용해야 localhost에 접근 가능
  // iOS 시뮬레이터와 웹은 localhost 사용 가능
  // 실제 디바이스는 컴퓨터의 로컬 IP 주소 사용 필요
  
  static String getBaseUrl() {
    // FastAPI 백엔드 API Gateway 포트: 8000
    // 웹 환경에서는 window.location을 사용하거나 localhost 사용
    if (kIsWeb) {
      // 웹에서는 현재 호스트를 사용하거나 localhost 사용
      // 개발 환경: localhost:8000 (FastAPI Gateway)
      // 프로덕션: 실제 도메인
      return 'http://localhost:8000';
    }
    
    // 모바일 환경
    if (Platform.isAndroid) {
      // Android 에뮬레이터는 10.0.2.2 사용
      return 'http://10.0.2.2:8000';
    } else if (Platform.isIOS) {
      // iOS 시뮬레이터는 localhost 사용 가능
      return 'http://localhost:8000';
    }
    
    // 기본값
    return 'http://localhost:8000';
  }
}
