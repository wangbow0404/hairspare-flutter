import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/job_provider.dart';
import '../../services/location_region_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../../utils/region_helper.dart';
import '../design_system/hs_primary_button.dart';
import '../spare_signup/spare_signup_region_picker.dart';

/// 스페어 홈 — 지역 선택 (LBS + 수동).
class SpareRegionSelectSheet extends StatefulWidget {
  const SpareRegionSelectSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SpareRegionSelectSheet(),
    );
  }

  @override
  State<SpareRegionSelectSheet> createState() => _SpareRegionSelectSheetState();
}

class _SpareRegionSelectSheetState extends State<SpareRegionSelectSheet> {
  final _locationService = LocationRegionService();
  bool _showManualPicker = false;
  bool _isDetecting = false;
  String? _manualProvinceId;
  String? _manualDistrictId;

  Future<void> _useMyLocation() async {
    if (_isDetecting) return;

    final consented = await _locationService.requestLbsConsent(context);
    if (!consented || !mounted) return;

    setState(() => _isDetecting = true);
    try {
      final detected = await _locationService.detectCurrentRegion();
      if (!mounted) return;

      await _locationService.saveLocationRegion(
        districtId: detected.districtId,
        displayLabel: detected.displayLabel,
      );

      if (!mounted) return;
      final jobProvider = context.read<JobProvider>();
      jobProvider.setLocationRegion(
        districtId: detected.districtId,
        displayLabel: detected.displayLabel,
      );
      await jobProvider.refreshJobs();

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${detected.displayLabel} 주변 공고를 불러왔습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on LocationRegionException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('위치를 가져오지 못했습니다. 잠시 후 다시 시도해 주세요.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isDetecting = false);
    }
  }

  Future<void> _applyManualRegion() async {
    final districtId = _manualDistrictId;
    if (districtId == null || districtId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('시/군/구를 선택해 주세요.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final displayLabel = RegionHelper.formatRegionLabel(
      provinceId: _manualProvinceId,
      districtId: districtId,
    );

    await _locationService.saveManualRegion(
      districtId: districtId,
      displayLabel: displayLabel,
    );

    if (!mounted) return;
    final jobProvider = context.read<JobProvider>();
    jobProvider.setManualRegion(
      districtId: districtId,
      displayLabel: displayLabel,
    );
    await jobProvider.refreshJobs();

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: HairSpareColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusXl),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacing5,
              AppTheme.spacing3,
              AppTheme.spacing5,
              AppTheme.spacing5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: HairSpareColors.borderStrong,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing4),
                const Text(
                  '지역 선택',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: HairSpareColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing2),
                const Text(
                  '내 위치 주변 공고를 바로 볼 수 있어요.',
                  style: TextStyle(
                    fontSize: 14,
                    color: HairSpareColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing5),
                HsPrimaryButton(
                  label: '내 위치로 보기',
                  isLoading: _isDetecting,
                  onPressed: _isDetecting ? null : _useMyLocation,
                ),
                const SizedBox(height: AppTheme.spacing3),
                OutlinedButton(
                  onPressed: () {
                    setState(() => _showManualPicker = !_showManualPicker);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: HairSpareColors.textPrimary,
                    side: const BorderSide(color: HairSpareColors.borderStrong),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacing4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    ),
                  ),
                  child: Text(
                    _showManualPicker ? '직접 선택 접기' : '지역 직접 선택',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_showManualPicker) ...[
                  const SizedBox(height: AppTheme.spacing4),
                  SpareSignupRegionPicker(
                    provinceId: _manualProvinceId,
                    districtId: _manualDistrictId,
                    label: '활동 지역',
                    onChanged: ({
                      required provinceId,
                      required districtId,
                      required displayLabel,
                    }) {
                      setState(() {
                        _manualProvinceId = provinceId;
                        _manualDistrictId = districtId;
                      });
                    },
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  HsPrimaryButton(
                    label: '선택 완료',
                    onPressed: _applyManualRegion,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
