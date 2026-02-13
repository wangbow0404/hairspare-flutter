import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../models/schedule.dart';
import '../../services/schedule_service.dart';
import '../../utils/error_handler.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

/// Next.js와 동일한 스케줄 화면
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _currentNavIndex = 0;
  List<Schedule> _schedules = [];
  bool _isLoading = true;
  Schedule? _selectedSchedule;
  final ScheduleService _scheduleService = ScheduleService();

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final schedules = await _scheduleService.getSchedules();
      setState(() {
        _schedules = schedules;
        _isLoading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        final errorMessage = error.toString().contains('connection errored') ||
                error.toString().contains('XMLHttpRequest')
            ? '서버에 연결할 수 없습니다. Next.js 서버가 실행 중인지 확인해주세요.'
            : '스케줄을 불러오는 중 오류가 발생했습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.urgentRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _handleScheduleClick(Schedule schedule) {
    setState(() {
      _selectedSchedule = schedule;
    });
  }

  Future<void> _handleCancelSchedule(String scheduleId) async {
    try {
      await _scheduleService.cancelSchedule(scheduleId);
      setState(() {
        _schedules.removeWhere((s) => s.id == scheduleId);
        _selectedSchedule = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('스케줄이 취소되었습니다.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('스케줄 취소 중 오류가 발생했습니다: $error')),
        );
      }
    }
  }

  Map<String, List<Schedule>> _groupSchedulesByDate() {
    final grouped = <String, List<Schedule>>{};
    for (final schedule in _schedules) {
      if (!grouped.containsKey(schedule.date)) {
        grouped[schedule.date] = [];
      }
      grouped[schedule.date]!.add(schedule);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final schedulesByDate = _groupSchedulesByDate();
    final sortedDates = schedulesByDate.keys.toList()..sort();

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: IconMapper.icon('chevronleft', size: 24, color: AppTheme.textSecondary) ??
              const Icon(Icons.arrow_back_ios, color: AppTheme.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '스케줄',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          sortedDates.isEmpty
              ? Center(
                  child: Text(
                    '확정된 일정이 없습니다.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: AppTheme.spacing(AppTheme.spacing4),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, index) {
                    final date = sortedDates[index];
                    final schedules = schedulesByDate[date]!;
                    final dateTime = DateTime.parse(date);
                    final isPast = dateTime.isBefore(DateTime.now());

                    return Container(
                      margin: EdgeInsets.only(bottom: AppTheme.spacing6),
                      padding: AppTheme.spacing(AppTheme.spacing4),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundWhite,
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                        border: Border.all(color: AppTheme.borderGray),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(dateTime),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: AppTheme.spacing3),
                          ...schedules.map((schedule) {
                            final scheduleDate = DateTime.parse(schedule.date);
                            final scheduleIsPast = scheduleDate.isBefore(DateTime.now());

                            return GestureDetector(
                              onTap: () => _handleScheduleClick(schedule),
                              child: Container(
                                margin: EdgeInsets.only(bottom: AppTheme.spacing3),
                                padding: AppTheme.spacing(AppTheme.spacing3),
                                decoration: BoxDecoration(
                                  color: scheduleIsPast
                                      ? AppTheme.backgroundGray
                                      : AppTheme.primaryBlue.withOpacity(0.1),
                                  borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                                  border: Border(
                                    left: BorderSide(
                                      color: scheduleIsPast
                                          ? AppTheme.textTertiary
                                          : AppTheme.primaryBlue,
                                      width: 4,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      schedule.job?.title ?? '공고 제목 없음',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: AppTheme.spacing1),
                                    Text(
                                      '${schedule.job?.shopName ?? '매장명 없음'} | ${schedule.startTime}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    SizedBox(height: AppTheme.spacing1),
                                    Text(
                                      '금액: ${NumberFormat('#,###').format(schedule.job?.amount ?? 0)}원',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    if (scheduleIsPast) ...[
                                      SizedBox(height: AppTheme.spacing2),
                                      Container(
                                        padding: AppTheme.spacingSymmetric(
                                          horizontal: AppTheme.spacing2,
                                          vertical: AppTheme.spacing1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.textTertiary.withOpacity(0.2),
                                          borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
                                        ),
                                        child: Text(
                                          '완료됨',
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
          // 스케줄 상세 모달
          if (_selectedSchedule != null)
            _ScheduleDetailModal(
              schedule: _selectedSchedule!,
              onClose: () {
                setState(() {
                  _selectedSchedule = null;
                });
              },
              onCancel: _handleCancelSchedule,
            ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          
          // 네비게이션 처리
          switch (index) {
            case 0:
              // 홈으로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SpareHomeScreen()),
              );
              break;
            case 1:
              // 결제로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PaymentScreen()),
              );
              break;
            case 2:
              // 찜으로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FavoritesScreen()),
              );
              break;
            case 3:
              // 마이(프로필)로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
              break;
          }
        },
      ),
    );
  }
}

class _ScheduleDetailModal extends StatefulWidget {
  final Schedule schedule;
  final VoidCallback onClose;
  final ValueChanged<String> onCancel;

  const _ScheduleDetailModal({
    required this.schedule,
    required this.onClose,
    required this.onCancel,
  });

  @override
  State<_ScheduleDetailModal> createState() => _ScheduleDetailModalState();
}

class _ScheduleDetailModalState extends State<_ScheduleDetailModal> {
  bool _showCancelConfirm = false;
  bool _isCancelling = false;

  Future<void> _handleCancel() async {
    if (!_showCancelConfirm) {
      setState(() {
        _showCancelConfirm = true;
      });
      return;
    }

    setState(() {
      _isCancelling = true;
    });

    try {
      // API 호출하여 스케줄 취소 (onCancel에서 처리)
      widget.onCancel(widget.schedule.id);
      widget.onClose();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('스케줄 취소 중 오류가 발생했습니다: $e')),
        );
      }
    } finally {
      setState(() {
        _isCancelling = false;
        _showCancelConfirm = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleDate = DateTime.parse(widget.schedule.date);
    final isPast = scheduleDate.isBefore(DateTime.now());
    final canCancel = !isPast;

    return Material(
      color: Colors.black.withOpacity(0.5),
      child: GestureDetector(
        onTap: widget.onClose,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // 모달 내부 클릭 시 닫히지 않도록
            child: Container(
              margin: AppTheme.spacing(AppTheme.spacing4),
              constraints: const BoxConstraints(maxWidth: 448),
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 헤더
                  Container(
                    padding: AppTheme.spacing(AppTheme.spacing4),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppTheme.borderGray),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '스케줄 상세',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: IconMapper.icon('x', size: 24, color: AppTheme.textTertiary) ??
                              const Icon(Icons.close, color: AppTheme.textTertiary),
                          onPressed: widget.onClose,
                        ),
                      ],
                    ),
                  ),
                  // 내용
                  Flexible(
                    child: SingleChildScrollView(
                      padding: AppTheme.spacing(AppTheme.spacing4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.schedule.job?.title ?? '공고 제목 없음',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: AppTheme.spacing2),
                          Text(
                            widget.schedule.job?.shopName ?? '매장명 없음',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          SizedBox(height: AppTheme.spacing4),
                          _buildInfoRow(
                            IconMapper.icon('calendar', size: 20, color: AppTheme.textTertiary) ??
                                const Icon(Icons.calendar_today, size: 20, color: AppTheme.textTertiary),
                            DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(scheduleDate),
                          ),
                          SizedBox(height: AppTheme.spacing2),
                          _buildInfoRow(
                            IconMapper.icon('clock', size: 20, color: AppTheme.textTertiary) ??
                                const Icon(Icons.access_time, size: 20, color: AppTheme.textTertiary),
                            '${widget.schedule.startTime}${widget.schedule.endTime != null ? ' ~ ${widget.schedule.endTime}' : ''}',
                          ),
                          SizedBox(height: AppTheme.spacing2),
                          _buildInfoRow(
                            IconMapper.icon('dollarsign', size: 20, color: AppTheme.textTertiary) ??
                                const Icon(Icons.attach_money, size: 20, color: AppTheme.textTertiary),
                            '${NumberFormat('#,###').format(widget.schedule.job?.amount ?? 0)}원',
                          ),
                          SizedBox(height: AppTheme.spacing2),
                          _buildInfoRow(
                            IconMapper.icon('users', size: 20, color: AppTheme.textTertiary) ??
                                const Icon(Icons.people, size: 20, color: AppTheme.textTertiary),
                            '필요 인원: ${widget.schedule.job?.requiredCount ?? 0}명',
                          ),
                          SizedBox(height: AppTheme.spacing4),
                          if (_showCancelConfirm)
                            Container(
                              padding: AppTheme.spacing(AppTheme.spacing4),
                              decoration: BoxDecoration(
                                color: AppTheme.urgentRedLight,
                                borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                                border: Border.all(color: AppTheme.urgentRed.withOpacity(0.2)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '정말 취소하시겠습니까?',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.urgentRed,
                                    ),
                                  ),
                                  SizedBox(height: AppTheme.spacing2),
                                  Text(
                                    '취소 시 예약금(에너지)이 반환됩니다.',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 14,
                                      color: AppTheme.urgentRed.withOpacity(0.8),
                                    ),
                                  ),
                                  SizedBox(height: AppTheme.spacing4),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: _isCancelling ? null : _handleCancel,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.urgentRed,
                                            foregroundColor: Colors.white,
                                            padding: AppTheme.spacing(AppTheme.spacing2),
                                          ),
                                          child: Text(_isCancelling ? '취소 중...' : '확인'),
                                        ),
                                      ),
                                      SizedBox(width: AppTheme.spacing2),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _showCancelConfirm = false;
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.borderGray300,
                                            foregroundColor: AppTheme.textGray700,
                                            padding: AppTheme.spacing(AppTheme.spacing2),
                                          ),
                                          child: const Text('돌아가기'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          else if (canCancel)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _handleCancel,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.urgentRed,
                                  foregroundColor: Colors.white,
                                  padding: AppTheme.spacing(AppTheme.spacing3),
                                ),
                                child: const Text('스케줄 취소'),
                              ),
                            ),
                          if (isPast)
                            Padding(
                              padding: EdgeInsets.only(top: AppTheme.spacing2),
                              child: Text(
                                '이미 지난 스케줄입니다',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(Widget icon, String text) {
    return Row(
      children: [
        icon,
        SizedBox(width: AppTheme.spacing2),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            color: AppTheme.textGray700,
          ),
        ),
      ],
    );
  }
}
