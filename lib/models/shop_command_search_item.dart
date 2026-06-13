import 'package:flutter/material.dart';

/// 샵 홈 검색에서 선택 시 이동할 화면.
enum ShopCommandDestination {
  jobsList,
  jobNew,
  sparesList,
  schedule,
  messages,
  notifications,
  points,
  paymentTab,
  education,
  spaces,
  favoritesTab,
  challenge,
}

/// 키워드 검색 결과 한 줄 (기능 바로가기).
class ShopCommandSearchItem {
  const ShopCommandSearchItem({
    required this.title,
    required this.subtitle,
    required this.keywords,
    required this.destination,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final List<String> keywords;
  final ShopCommandDestination destination;
  final IconData icon;
}
