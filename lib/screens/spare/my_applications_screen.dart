import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/spare_app_bar.dart';
import '../../models/application.dart';
import '../../services/application_service.dart';
import '../../utils/error_handler.dart';
import 'job_detail_screen.dart';

/// 내 지원 현황 화면
class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  final ApplicationService _applicationService = ApplicationService();
  List<Application> _applications = [];
  bool _isLoading = true;
  String? _error;
  String _activeStatus = 'all'; // 'all' | 'pending' | 'approved' | 'rejected'

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final list = await _applicationService.getMyApplications();
      if (mounted) {
        setState(() {
          _applications = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final appException = ErrorHandler.handleException(e);
        setState(() {
          _error = ErrorHandler.getUserFriendlyMessage(appException);
          _applications = [];
          _isLoading = false;
        });
      }
    }
  }

  List<Application> get _filteredApplications {
    if (_activeStatus == 'all') return _applications;
    return _applications.where((a) => a.status == _activeStatus).toList();
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return '대기중';
      case 'approved':
        return '승인됨';
      case 'rejected':
        return '거절됨';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return AppTheme.yellow400;
      case 'approved':
        return AppTheme.primaryGreen;
      case 'rejected':
        return AppTheme.urgentRed;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SpareAppBar(showBackButton: true),
      body: Column(
        children: [
          // 탭 필터
          Container(
            color: AppTheme.backgroundWhite,
            padding: AppTheme.spacingSymmetric(
              horizontal: AppTheme.spacing4,
              vertical: AppTheme.spacing2,
            ),
            child: Row(
              children: [
                _FilterChip(
                  label: '전체',
                  isActive: _activeStatus == 'all',
                  onTap: () => setState(() => _activeStatus = 'all'),
                ),
                SizedBox(width: AppTheme.spacing2),
                _FilterChip(
                  label: '대기중',
                  isActive: _activeStatus == 'pending',
                  onTap: () => setState(() => _activeStatus = 'pending'),
                ),
                SizedBox(width: AppTheme.spacing2),
                _FilterChip(
                  label: '승인됨',
                  isActive: _activeStatus == 'approved',
                  onTap: () => setState(() => _activeStatus = 'approved'),
                ),
                SizedBox(width: AppTheme.spacing2),
                _FilterChip(
                  label: '거절됨',
                  isActive: _activeStatus == 'rejected',
                  onTap: () => setState(() => _activeStatus = 'rejected'),
                ),
              ],
            ),
          ),
          // 리스트
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _error!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: AppTheme.spacing4),
                            ElevatedButton(
                              onPressed: _loadApplications,
                              child: const Text('다시 시도'),
                            ),
                          ],
                        ),
                      )
                    : _filteredApplications.isEmpty
                        ? Center(
                            child: Text(
                              '지원 내역이 없습니다',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadApplications,
                            child: ListView.builder(
                              padding: AppTheme.spacing(AppTheme.spacing4),
                              itemCount: _filteredApplications.length,
                              itemBuilder: (context, index) {
                                final app = _filteredApplications[index];
                                return _ApplicationCard(
                                  application: app,
                                  statusLabel: _statusLabel(app.status),
                                  statusColor: _statusColor(app.status),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => JobDetailScreen(jobId: app.job.id),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppTheme.spacingSymmetric(
          horizontal: AppTheme.spacing3,
          vertical: AppTheme.spacing2,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryBlue : AppTheme.backgroundGray,
          borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppTheme.textSecondary,
              ),
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final Application application;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback onTap;

  const _ApplicationCard({
    required this.application,
    required this.statusLabel,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final job = application.job;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppTheme.spacing3),
        padding: AppTheme.spacing(AppTheme.spacing4),
        decoration: BoxDecoration(
          color: AppTheme.backgroundWhite,
          borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
          border: Border.all(color: AppTheme.borderGray),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: AppTheme.spacingSymmetric(
                    horizontal: AppTheme.spacing2,
                    vertical: AppTheme.spacing1,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
                  ),
                  child: Text(
                    statusLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing2),
            Text(
              job.shopName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            SizedBox(height: AppTheme.spacing2),
            Row(
              children: [
                Text(
                  '${job.date} ${job.time}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                ),
                SizedBox(width: AppTheme.spacing3),
                Text(
                  '${NumberFormat('#,###').format(job.amount)}원',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing2),
            Text(
              '지원일: ${DateFormat('yyyy.M.d', 'ko_KR').format(application.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textTertiary,
                    fontSize: 12,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
