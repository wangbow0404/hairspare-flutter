import 'package:flutter/material.dart';

/// 사용자 ID 기반 아바타 그라데이션 (기존 프로필 화면과 동일 알고리즘).
List<Color> spareProfileAvatarGradient(String userId) {
  final gradients = [
    [const Color(0xFF60A5FA), const Color(0xFFA855F7)],
    [const Color(0xFFC084FC), const Color(0xFFEC4899)],
    [const Color(0xFFF472B6), const Color(0xFFEF4444)],
    [const Color(0xFFFB7185), const Color(0xFFF97316)],
    [const Color(0xFFFB923C), const Color(0xFFEAB308)],
    [const Color(0xFFFACC15), const Color(0xFF22C55E)],
    [const Color(0xFF4ADE80), const Color(0xFF14B8A6)],
    [const Color(0xFF2DD4BF), const Color(0xFF06B6D4)],
    [const Color(0xFF22D3EE), const Color(0xFF3B82F6)],
    [const Color(0xFF818CF8), const Color(0xFFA855F7)],
  ];
  var hash = 0;
  for (var i = 0; i < userId.length; i++) {
    hash = userId.codeUnitAt(i) + ((hash << 5) - hash);
  }
  final index = hash.abs() % gradients.length;
  return gradients[index];
}
