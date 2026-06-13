import 'package:flutter/material.dart';

import '../models/shop_command_search_item.dart';

/// 샵 기능 키워드 검색 목록.
abstract final class ShopCommandSearchCatalog {
  static const List<ShopCommandSearchItem> all = [
    ShopCommandSearchItem(
      title: '내 공고',
      subtitle: '등록한 공고 목록·상태 확인',
      keywords: ['내공고', '공고', '공고확인', '구인', '목록', '마감', '지난공고'],
      destination: ShopCommandDestination.jobsList,
      icon: Icons.work_outline,
    ),
    ShopCommandSearchItem(
      title: '공고 올리기',
      subtitle: '새 구인 공고 등록',
      keywords: ['공고올리기', '공고', '등록', '새공고', '구인등록', '급구', '채용'],
      destination: ShopCommandDestination.jobNew,
      icon: Icons.add_circle_outline,
    ),
    ShopCommandSearchItem(
      title: '스페어 찾기',
      subtitle: '인력 목록 검색',
      keywords: ['스페어', '인력', '인력별', '디자이너', '스텝', '구하기'],
      destination: ShopCommandDestination.sparesList,
      icon: Icons.people_outline,
    ),
    ShopCommandSearchItem(
      title: '스케줄표',
      subtitle: '근무 일정 확인',
      keywords: ['스케줄', '일정', '근무표', '스케줄표', '캘린더'],
      destination: ShopCommandDestination.schedule,
      icon: Icons.calendar_today_outlined,
    ),
    ShopCommandSearchItem(
      title: '지원자 관리',
      subtitle: '공고별 지원자 확인·승인',
      keywords: ['지원자', '지원', '승인', '합격', '면접'],
      destination: ShopCommandDestination.jobsList,
      icon: Icons.how_to_reg_outlined,
    ),
    ShopCommandSearchItem(
      title: '메시지',
      subtitle: '채팅 목록',
      keywords: ['메시지', '채팅', '쪽지', '대화'],
      destination: ShopCommandDestination.messages,
      icon: Icons.chat_bubble_outline,
    ),
    ShopCommandSearchItem(
      title: '알림',
      subtitle: '알림 목록',
      keywords: ['알림', '공지', '푸시'],
      destination: ShopCommandDestination.notifications,
      icon: Icons.notifications_outlined,
    ),
    ShopCommandSearchItem(
      title: '포인트',
      subtitle: '포인트·충전',
      keywords: ['포인트', '충전', '적립'],
      destination: ShopCommandDestination.points,
      icon: Icons.monetization_on_outlined,
    ),
    ShopCommandSearchItem(
      title: '결제',
      subtitle: '결제 내역·관리',
      keywords: ['결제', '카드', '영수증', '청구'],
      destination: ShopCommandDestination.paymentTab,
      icon: Icons.payment_outlined,
    ),
    ShopCommandSearchItem(
      title: '교육',
      subtitle: '교육 콘텐츠',
      keywords: ['교육', '강의', '학습'],
      destination: ShopCommandDestination.education,
      icon: Icons.school_outlined,
    ),
    ShopCommandSearchItem(
      title: '공간 대여',
      subtitle: '내 공간·예약 관리',
      keywords: ['공간', '대여', '임대', '부스'],
      destination: ShopCommandDestination.spaces,
      icon: Icons.storefront_outlined,
    ),
    ShopCommandSearchItem(
      title: '찜',
      subtitle: '찜한 스페어·공고',
      keywords: ['찜', '즐겨찾기', '관심'],
      destination: ShopCommandDestination.favoritesTab,
      icon: Icons.favorite_border,
    ),
    ShopCommandSearchItem(
      title: '챌린지',
      subtitle: '챌린지 참여',
      keywords: ['챌린지', '참여', '이벤트'],
      destination: ShopCommandDestination.challenge,
      icon: Icons.emoji_events_outlined,
    ),
  ];

  static String _normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'\s+'), '');

  /// 입력 키워드와 매칭되는 항목 (빈 쿼리면 빈 목록).
  static List<ShopCommandSearchItem> match(String query) {
    final q = _normalize(query.trim());
    if (q.isEmpty) return const [];

    final scored = <({ShopCommandSearchItem item, int score})>[];

    for (final item in all) {
      final score = _scoreItem(item, q);
      if (score > 0) {
        scored.add((item: item, score: score));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((e) => e.item).toList();
  }

  static int _scoreItem(ShopCommandSearchItem item, String q) {
    var best = 0;
    final title = _normalize(item.title);

    if (title == q) best = 100;
    if (title.startsWith(q)) best = best > 80 ? best : 80;
    if (title.contains(q)) best = best > 60 ? best : 60;

    for (final keyword in item.keywords) {
      final k = _normalize(keyword);
      if (k == q) {
        best = best > 90 ? best : 90;
      } else if (k.startsWith(q)) {
        best = best > 70 ? best : 70;
      } else if (k.contains(q)) {
        best = best > 50 ? best : 50;
      } else if (q.contains(k) && k.length >= 2) {
        best = best > 40 ? best : 40;
      }
    }

    return best;
  }

  /// 빈 입력 시 탭 가능한 예시 키워드.
  static const List<String> exampleKeywords = [
    '공고',
    '스페어',
    '스케줄',
    '메시지',
  ];
}
