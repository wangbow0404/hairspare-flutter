import '../models/application.dart';
import '../models/job.dart';
import 'application_status_utils.dart';

/// 샵 홈·내 공고·지원자 화면 공통 지원자 집계.
abstract final class ShopApplicantCounts {
  static int approvedForJob(
    String jobId,
    Iterable<Application> applications,
  ) =>
      applications
          .where(
            (a) =>
                a.job.id == jobId &&
                ApplicationStatusUtils.normalize(a.status) == 'approved',
          )
          .length;

  static int remainingApprovalSlots(
    Job job,
    Iterable<Application> applications,
  ) {
    final remaining = job.requiredCount - approvedForJob(job.id, applications);
    return remaining < 0 ? 0 : remaining;
  }

  static bool isApprovalFull(Job job, Iterable<Application> applications) =>
      remainingApprovalSlots(job, applications) <= 0;

  static bool canApproveApplication(
    Job job,
    Iterable<Application> applications,
  ) =>
      job.status == 'published' &&
      !job.isHidden &&
      !isApprovalFull(job, applications);

  static Map<String, int> perJobIds({
    required Iterable<String> jobIds,
    required Iterable<Application> applications,
  }) {
    return {
      for (final jobId in jobIds)
        jobId: applications.where((a) => a.job.id == jobId).length,
    };
  }

  static bool _isJobExpired(Application a) {
    try {
      final date = a.job.date;
      final parts = a.job.time.split(':');
      if (parts.length < 2) return false;
      final jobStart = DateTime(
        int.parse(date.substring(0, 4)),
        int.parse(date.substring(5, 7)),
        int.parse(date.substring(8, 10)),
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      return jobStart.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  static int pending(Iterable<Application> applications) =>
      applications
          .where(
            (a) =>
                ApplicationStatusUtils.normalize(a.status) == 'pending' &&
                !_isJobExpired(a),
          )
          .length;

  static int approved(Iterable<Application> applications) =>
      applications
          .where(
            (a) => ApplicationStatusUtils.normalize(a.status) == 'approved',
          )
          .length;
}
