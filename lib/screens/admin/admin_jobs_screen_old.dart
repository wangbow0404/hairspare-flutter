import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/admin_service.dart';
import '../../utils/error_handler.dart';

/// 관리자 공고 관리 화면
class AdminJobsScreen extends StatefulWidget {
  const AdminJobsScreen({super.key});

  @override
  State<AdminJobsScreen> createState() => _AdminJobsScreenState();
}

class _AdminJobsScreenState extends State<AdminJobsScreen> {
  final AdminService _adminService = AdminService();
  List<dynamic> _jobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _adminService.getJobs();
      if (mounted) {
        setState(() {
          _jobs = result['jobs'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('공고 목록 조회 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: AppBar(
        title: const Text('공고 관리'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _jobs.isEmpty
              ? const Center(child: Text('공고가 없습니다'))
              : ListView.builder(
                  itemCount: _jobs.length,
                  itemBuilder: (context, index) {
                    final job = _jobs[index];
                    return Card(
                      margin: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing3,
                        vertical: AppTheme.spacing1,
                      ),
                      child: ListTile(
                        title: Text(job['title'] ?? '제목 없음'),
                        subtitle: Text(
                          '${job['shop']?['name'] ?? ''} | ${job['status'] ?? ''}',
                        ),
                        trailing: Text(
                          '지원: ${job['_count']?['applications'] ?? 0}',
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
