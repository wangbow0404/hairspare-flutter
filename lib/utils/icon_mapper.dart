import 'package:flutter/material.dart';

/// Lucide React 아이콘을 Material Icons로 매핑하는 유틸리티 클래스
/// Next.js 웹 앱의 Lucide React 아이콘과 Flutter Material Icons 간의 매핑
class IconMapper {
  /// Lucide 아이콘 이름을 Material IconData로 변환
  static IconData? getIcon(String lucideIconName) {
    switch (lucideIconName.toLowerCase()) {
      // 네비게이션
      case 'home':
        return Icons.home;
      case 'creditcard':
      case 'credit-card':
        return Icons.credit_card;
      case 'heart':
        return Icons.favorite;
      case 'user':
        return Icons.person;
      
      // 알림 및 메시지
      case 'bell':
        return Icons.notifications;
      case 'messagecircle':
      case 'message-circle':
        return Icons.message;
      case 'search':
        return Icons.search;
      
      // 화살표
      case 'chevronleft':
      case 'chevron-left':
        return Icons.chevron_left;
      case 'chevronright':
      case 'chevron-right':
        return Icons.chevron_right;
      case 'chevrondown':
      case 'chevron-down':
        return Icons.keyboard_arrow_down;
      case 'chevronup':
      case 'chevron-up':
        return Icons.keyboard_arrow_up;
      
      // 위치 및 시간
      case 'mappin':
      case 'map-pin':
        return Icons.location_on;
      case 'clock':
        return Icons.access_time;
      
      // 금액 및 인원
      case 'dollarsign':
      case 'dollar-sign':
        return Icons.attach_money;
      case 'users':
        return Icons.people;
      
      // 에너지 및 상태
      case 'zap':
        return Icons.bolt;
      case 'checkcircle2':
      case 'check-circle-2':
      case 'checkcircle':
      case 'check-circle':
        return Icons.check_circle;
      case 'shield':
        return Icons.shield;
      case 'x':
        return Icons.close;
      
      // 공유 및 카메라
      case 'share2':
      case 'share-2':
        return Icons.share;
      case 'camera':
        return Icons.camera_alt;
      
      // 기타
      case 'calendar':
        return Icons.calendar_today;
      case 'star':
        return Icons.star;
      case 'info':
        return Icons.info;
      
      // 추가 아이콘들
      case 'mail':
        return Icons.mail;
      case 'messagesquare':
      case 'message-square':
        return Icons.message;
      case 'lock':
        return Icons.lock;
      case 'eye':
        return Icons.visibility;
      case 'eyeoff':
      case 'eye-off':
        return Icons.visibility_off;
      case 'send':
        return Icons.send;
      case 'settings':
        return Icons.settings;
      case 'trash2':
      case 'trash-2':
        return Icons.delete;
      case 'logout':
      case 'log-out':
        return Icons.logout;
      case 'phone':
        return Icons.phone;
      case 'alerttriangle':
      case 'alert-triangle':
        return Icons.warning;
      case 'alertcircle':
      case 'alert-circle':
        return Icons.error;
      case 'xcircle':
      case 'x-circle':
        return Icons.cancel;
      case 'copy':
        return Icons.copy;
      case 'arrowup':
      case 'arrow-up':
        return Icons.arrow_upward;
      case 'arrowdown':
      case 'arrow-down':
        return Icons.arrow_downward;
      case 'check':
        return Icons.check;
      
      default:
        return null;
    }
  }
  
  /// Lucide 아이콘 이름으로 Icon 위젯 생성
  static Widget? icon(String lucideIconName, {
    double? size,
    Color? color,
  }) {
    final iconData = getIcon(lucideIconName);
    if (iconData == null) return null;
    
    return Icon(
      iconData,
      size: size,
      color: color,
    );
  }
  
  /// Lucide 아이콘 이름으로 IconButton 위젯 생성
  static Widget? iconButton(
    String lucideIconName, {
    required VoidCallback onPressed,
    double? iconSize,
    Color? iconColor,
    String? tooltip,
  }) {
    final iconData = getIcon(lucideIconName);
    if (iconData == null) return null;
    
    return IconButton(
      icon: Icon(iconData),
      iconSize: iconSize,
      color: iconColor,
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}
