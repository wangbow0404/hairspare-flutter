import 'package:flutter/foundation.dart';
import '../models/job.dart';
import '../services/job_service.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';

class JobProvider with ChangeNotifier {
  final JobService _jobService = JobService();
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
      _jobs = await _jobService.getJobs(
        regionIds: regionIds,
        isUrgent: isUrgent,
        searchQuery: searchQuery,
      );

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
