import 'package:flutter/material.dart';
import 'package:kpostal/kpostal.dart';

/// 카카오(다음) 우편번호 검색 — [KpostalView] 전체 화면.
class AddressSearchHelper {
  AddressSearchHelper._();

  /// 주소 검색 결과. `detailAddress`는 호출 시 넘긴 기존 상세주소를 그대로 유지합니다.
  static Future<Map<String, String>?> pickAddress(
    BuildContext context, {
    String? initialDetailAddress,
  }) async {
    // KpostalView는 선택 시 내부에서 navigator.pop()을 호출함.
    // callback에서 또 pop하면 공고 등록 화면까지 닫혀 홈으로 돌아감.
    final kpostal = await Navigator.of(context).push<Kpostal>(
      MaterialPageRoute<Kpostal>(
        builder: (_) => KpostalView(title: '주소 검색'),
      ),
    );
    if (kpostal == null || kpostal.address.trim().isEmpty) {
      return null;
    }

    return {
      'address': kpostal.address.trim(),
      'detailAddress': initialDetailAddress?.trim() ?? '',
      if (kpostal.postCode.isNotEmpty) 'zonecode': kpostal.postCode,
    };
  }
}
