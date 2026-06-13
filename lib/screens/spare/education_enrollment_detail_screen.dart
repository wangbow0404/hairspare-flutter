import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:hairspare/models/education_enrollment.dart';
import 'package:hairspare/services/education_service.dart';
import 'package:hairspare/theme/app_theme.dart';
import 'package:hairspare/utils/error_handler.dart';
import 'package:hairspare/widgets/common/shared_app_bar.dart';
import 'package:hairspare/widgets/education/education_ui_kit.dart';
import 'package:hairspare/widgets/education/enrollment_materials_section.dart';
import 'package:hairspare/widgets/education/enrollment_online_section.dart';
import 'package:hairspare/widgets/education/enrollment_venue_section.dart';

/// 신청 완료 교육 상세 — 자료·장소·접속.
class EducationEnrollmentDetailScreen extends StatefulWidget {
  const EducationEnrollmentDetailScreen({
    super.key,
    required this.enrollmentId,
  });

  final String enrollmentId;

  @override
  State<EducationEnrollmentDetailScreen> createState() =>
      _EducationEnrollmentDetailScreenState();
}

class _EducationEnrollmentDetailScreenState
    extends State<EducationEnrollmentDetailScreen> {
  final EducationService _educationService = EducationService();
  EducationEnrollment? _enrollment;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      _enrollment =
          await _educationService.getEnrollment(widget.enrollmentId);
    } catch (e) {
      ErrorHandler.handleException(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final enrollment = _enrollment;
    if (enrollment == null) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        appBar: SharedAppBar(title: '신청 내역'),
        body: Center(child: Text('신청 내역을 불러올 수 없습니다.')),
      );
    }

    final dateFmt = DateFormat('yyyy년 M월 d일', 'ko_KR');
    final scheduleText = enrollment.startDate != null
        ? (enrollment.endDate != null &&
                enrollment.endDate != enrollment.startDate
            ? '${dateFmt.format(enrollment.startDate!)} ~ ${DateFormat('M월 d일', 'ko_KR').format(enrollment.endDate!)}'
            : dateFmt.format(enrollment.startDate!))
        : dateFmt.format(enrollment.enrolledAt);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SharedAppBar(title: '신청 완료'),
      body: EducationFlowBackground(
        child: SingleChildScrollView(
          padding: AppTheme.spacing(AppTheme.spacing4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EducationEnrollmentSuccessHero(
                title: enrollment.title,
                scheduleText: scheduleText,
                energyPaid: enrollment.energyPaid,
                isOnline: enrollment.isOnline,
              ),
              const SizedBox(height: AppTheme.spacing5),
              EducationPremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '신청 정보',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    EducationDetailInfoTile(
                      icon: Icons.calendar_month_rounded,
                      label: '교육 일정',
                      value: scheduleText,
                      tint: AppTheme.primaryBlue,
                    ),
                    const SizedBox(height: AppTheme.spacing3),
                    EducationDetailInfoTile(
                      icon: Icons.flash_on_rounded,
                      label: '결제 에너지',
                      value: '에너지 ${enrollment.energyPaid}개',
                      tint: AppTheme.orange500,
                    ),
                    const SizedBox(height: AppTheme.spacing3),
                    EducationDetailInfoTile(
                      icon: enrollment.isOnline
                          ? Icons.videocam_rounded
                          : Icons.location_on_rounded,
                      label: '진행 방식',
                      value: enrollment.isOnline ? '온라인 교육' : '오프라인 교육',
                      tint: AppTheme.primaryPurple,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacing2),
              EnrollmentMaterialsSection(materials: enrollment.materials),
              if (!enrollment.isOnline)
                EnrollmentVenueSection(enrollment: enrollment)
              else
                EnrollmentOnlineSection(enrollment: enrollment),
              const SizedBox(height: AppTheme.spacing4),
              const EducationInfoNoticeCard(
                title: '일정 안내',
                body: '교육 일정은 스케줄표에 자동으로 표시됩니다. '
                    '교육 전 자료를 미리 확인하고, 오프라인 교육은 장소를 체크해 주세요.',
              ),
              const SizedBox(height: AppTheme.spacing8),
            ],
          ),
        ),
      ),
    );
  }
}
