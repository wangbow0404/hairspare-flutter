import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../theme/hairspare_colors.dart';
import '../utils/region_helper.dart';
import '../widgets/design_system/hs_primary_button.dart';

/// 저장된 지역 (수동·위치 기반).
class SavedSpareRegion {
  const SavedSpareRegion({
    required this.districtId,
    required this.displayLabel,
    required this.isLocationBased,
  });

  final String districtId;
  final String displayLabel;
  final bool isLocationBased;
}

/// 위치 기반 지역 감지 결과.
class DetectedSpareRegion {
  const DetectedSpareRegion({
    required this.districtId,
    required this.displayLabel,
  });

  final String districtId;
  final String displayLabel;
}

/// LBS 동의·권한·역지오코딩·지역 저장.
class LocationRegionService {
  static const _keyConsent = 'lbs_consent_granted';
  static const _keyRegionId = 'spare_selected_region_id';
  static const _keyRegionLabel = 'spare_selected_region_label';
  static const _keyLocationBased = 'spare_location_based';

  Future<bool> hasLbsConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyConsent) ?? false;
  }

  Future<void> grantLbsConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyConsent, true);
  }

  Future<SavedSpareRegion?> loadSavedRegion() async {
    final prefs = await SharedPreferences.getInstance();
    final districtId = prefs.getString(_keyRegionId);
    if (districtId == null || districtId.isEmpty) return null;

    return SavedSpareRegion(
      districtId: districtId,
      displayLabel: prefs.getString(_keyRegionLabel) ??
          RegionHelper.districtShortName(districtId),
      isLocationBased: prefs.getBool(_keyLocationBased) ?? false,
    );
  }

  Future<void> saveManualRegion({
    required String districtId,
    required String displayLabel,
  }) async {
    await _persistRegion(
      districtId: districtId,
      displayLabel: displayLabel,
      locationBased: false,
    );
  }

  Future<void> saveLocationRegion({
    required String districtId,
    required String displayLabel,
  }) async {
    await grantLbsConsent();
    await _persistRegion(
      districtId: districtId,
      displayLabel: displayLabel,
      locationBased: true,
    );
  }

  Future<void> _persistRegion({
    required String districtId,
    required String displayLabel,
    required bool locationBased,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRegionId, districtId);
    await prefs.setString(_keyRegionLabel, displayLabel);
    await prefs.setBool(_keyLocationBased, locationBased);
  }

  /// 위치기반서비스 이용 동의 다이얼로그. 승인 시 true.
  Future<bool> requestLbsConsent(BuildContext context) async {
    if (await hasLbsConsent()) return true;
    if (!context.mounted) return false;

    final approved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: const Text(
          '위치기반서비스 이용 동의',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: HairSpareColors.textPrimary,
          ),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'HairSpare는 내 주변 공고를 보여드리기 위해 '
            '현재 위치 정보를 수집·이용합니다.\n\n'
            '• 수집 항목: GPS 기반 현재 위치(동·구·시 단위)\n'
            '• 이용 목적: 근처 공고 필터링\n'
            '• 보관 기간: 앱 내 설정 변경 또는 삭제 시까지\n\n'
            '동의하지 않으셔도 지역을 직접 선택해 이용하실 수 있습니다.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: HairSpareColors.textStrong,
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
          AppTheme.spacing4,
          0,
          AppTheme.spacing4,
          AppTheme.spacing4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('거부'),
          ),
          HsPrimaryButton(
            expand: false,
            label: '동의',
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (approved == true) {
      await grantLbsConsent();
      return true;
    }
    return false;
  }

  /// GPS 권한 확인·요청 후 현재 행정구역을 반환.
  Future<DetectedSpareRegion> detectCurrentRegion() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationRegionException('기기의 위치 서비스를 켜 주세요.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw LocationRegionException('위치 권한이 필요합니다.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw LocationRegionException(
        '설정에서 위치 권한을 허용해 주세요.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 12),
      ),
    );

    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (placemarks.isEmpty) {
      throw LocationRegionException('현재 위치를 확인하지 못했습니다.');
    }

    final place = placemarks.first;
    final districtId = RegionHelper.resolveDistrictIdFromPlacemark(
      administrativeArea: place.administrativeArea,
      locality: place.locality,
      subAdministrativeArea: place.subAdministrativeArea,
      subLocality: place.subLocality,
    );

    if (districtId == null) {
      throw LocationRegionException('지원하지 않는 지역입니다.');
    }

    final displayLabel = RegionHelper.locationDisplayLabel(
      districtId: districtId,
      subLocality: place.subLocality,
      locality: place.locality,
    );

    return DetectedSpareRegion(
      districtId: districtId,
      displayLabel: displayLabel,
    );
  }
}

class LocationRegionException implements Exception {
  LocationRegionException(this.message);

  final String message;

  @override
  String toString() => message;
}
