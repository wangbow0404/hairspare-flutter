import 'package:flutter/foundation.dart';

import 'package:hairspare/models/education_enrollment.dart';
import 'package:hairspare/screens/spare/education_screen.dart';
import 'package:hairspare/services/education_service.dart';

/// 교육 상세 — 신청 상태·CTA.
class EducationDetailViewModel extends ChangeNotifier {
  EducationDetailViewModel({
    required this.education,
    EducationService? educationService,
  }) : _educationService = educationService ?? EducationService();

  final Education education;
  final EducationService _educationService;

  EducationEnrollment? enrollment;
  bool isLoadingStatus = true;

  bool get isEnrolled => enrollment != null;

  bool get canApply {
    if (isEnrolled) return false;
    if (DateTime.now().isAfter(education.deadline)) return false;
    if (education.applicants >= education.maxApplicants) return false;
    return true;
  }

  String? get applyBlockReason {
    if (isEnrolled) return null;
    if (DateTime.now().isAfter(education.deadline)) {
      return '신청 마감된 교육입니다.';
    }
    if (education.applicants >= education.maxApplicants) {
      return '정원이 마감되었습니다.';
    }
    return null;
  }

  Future<void> loadEnrollmentStatus() async {
    isLoadingStatus = true;
    notifyListeners();
    try {
      enrollment =
          await _educationService.getEnrollmentByEducationId(education.id);
    } catch (e) {
      debugPrint('교육 신청 상태 조회 오류: $e');
    } finally {
      isLoadingStatus = false;
      notifyListeners();
    }
  }

  void setEnrollment(EducationEnrollment value) {
    enrollment = value;
    notifyListeners();
  }
}
