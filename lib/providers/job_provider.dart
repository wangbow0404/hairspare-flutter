import 'package:flutter/foundation.dart';
import '../models/job.dart';
import '../services/job_service.dart';
import '../utils/error_handler.dart';
class JobProvider with ChangeNotifier {
  JobProvider(this._jobService);

  final JobService _jobService;
  List<Job> _jobs = [];
  List<Job> _urgentJobs = [];
  List<Job> _normalJobs = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedRegionId;

  List<Job> get jobs => _jobs;
  List<Job> get urgentJobs => _urgentJobs;
  List<Job> get normalJobs => _normalJobs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedRegionId => _selectedRegionId;

  Future<void> loadJobs({
    List<String>? regionIds,
    bool? isUrgent,
    String? searchQuery,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final raw = await _jobService.getJobs(
        regionIds: regionIds,
        isUrgent: isUrgent,
        searchQuery: searchQuery,
      );

      final now = DateTime.now();
      bool notExpired(Job job) {
        try {
          final parts = job.time.split(':');
          if (parts.length < 2) return true;
          final start = DateTime(
            int.parse(job.date.substring(0, 4)),
            int.parse(job.date.substring(5, 7)),
            int.parse(job.date.substring(8, 10)),
            int.parse(parts[0]),
            int.parse(parts[1]),
          );
          return start.isAfter(now);
        } catch (_) {
          return true;
        }
      }

      _jobs = raw.where(notExpired).toList();

      // 급구와 일반 공고 분리
      _urgentJobs = _jobs.where((job) => job.isUrgent).toList();
      _normalJobs = _jobs.where((job) => !job.isUrgent).toList();

      _error = null;
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      _error = ErrorHandler.getUserFriendlyMessage(appException);
      _jobs = [];
      _urgentJobs = [];
      _normalJobs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedRegion(String? regionId) {
    _selectedRegionId = regionId;
    notifyListeners();
  }

  String? _searchQuery;

  String? get searchQuery => _searchQuery;

  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> refreshJobs() async {
    await loadJobs(
      regionIds: _selectedRegionId != null ? [_selectedRegionId!] : null,
      searchQuery: _searchQuery,
    );
  }
}
