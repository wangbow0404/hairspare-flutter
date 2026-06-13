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

  static int pending(Iterable<Application> applications) =>
      applications
          .where(
            (a) => ApplicationStatusUtils.normalize(a.status) == 'pending',
          )
          .length;

  static int approved(Iterable<Application> applications) =>
      applications
          .where(
            (a) => ApplicationStatusUtils.normalize(a.status) == 'approved',
          )
          .length;
}
