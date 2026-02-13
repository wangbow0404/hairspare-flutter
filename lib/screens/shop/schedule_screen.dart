import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../models/schedule.dart';
import '../../models/shop_tier.dart';
import '../../services/schedule_service.dart';
import '../../services/spare_service.dart';
import '../../utils/error_handler.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

/// Shop용 스케줄 화면 (Spare 근무체크 화면 디자인 기반)
class ShopScheduleScreen extends StatefulWidget {
  const ShopScheduleScreen({super.key});

  @override
  State<ShopScheduleScreen> createState() => _ShopScheduleScreenState();
}

class _ShopScheduleScreenState extends State<ShopScheduleScreen> {
  int _currentNavIndex = 0;
  List<Schedule> _schedules = [];
  bool _isLoading = true;
  Schedule? _selectedSchedule;
  bool _showThumbsUpModal = false;
  ShopTierInfo? _tierInfo;
  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  Set<String> _completedDates = {}; // 완료된 날짜들
  final ScheduleService _scheduleService = ScheduleService();
  final SpareService _spareService = SpareService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Future.wait([
        _loadSchedules(),
        _loadTierInfo(),
      ]);
    } catch (error) {
      if (mounted) {
        final appException = ErrorHandler.handleException(error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getUserFriendlyMessage(appException)),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadTierInfo() async {
    // TODO: 실제 API에서 등급 정보 가져오기
    final completedSchedules = _schedules.where((s) => s.status == 'completed').length;
    final thumbsUpReceived = (completedSchedules * 0.8).round();
    
    if (mounted) {
      setState(() {
        _tierInfo = ShopTierInfo(
          currentTier: ShopTierInfo.calculateTier(completedSchedules, thumbsUpReceived),
          completedSchedules: completedSchedules,
          thumbsUpReceived: thumbsUpReceived,
          maxJobPosts: ShopTierInfo.calculateMaxJobPosts(
            ShopTierInfo.calculateTier(completedSchedules, thumbsUpReceived),
          ),
        );
      });
    }
  }

  Future<void> _loadSchedules() async {
    try {
      final schedules = await _scheduleService.getSchedules(ownerId: 'me');
      setState(() {
        _schedules = schedules;
        // 완료된 날짜 추출
        _completedDates = schedules
            .where((s) => s.status == 'completed')
            .map((s) => s.date)
            .toSet();
      });
      await _loadTierInfo();
    } catch (error) {
      print('스케줄 로드 오류: $error');
    }
  }

  // 등급에 따른 헤더 제목
  Map<String, dynamic> _getTierTitle() {
    if (_tierInfo == null) {
      return {
        'title': '등급 시스템 시작하기',
        'subtitle': '2026년 등급을 올려보세요!',
        'emoji': '🏆',
      };
    }

    final tier = _tierInfo!.currentTier;
    final completed = _tierInfo!.completedSchedules;
    final nextTier = tier.getNextTier();

    if (nextTier == null) {
      return {
        'title': '최고 등급 달성!',
        'subtitle': 'VIP 등급을 유지하고 계세요!',
        'emoji': tier.emoji,
      };
    }

    if (completed == 0) {
      return {
        'title': '등급 시스템 시작하기',
        'subtitle': '2026년 등급을 올려보세요!',
        'emoji': '🏆',
      };
    } else if (completed < 5) {
      return {
        'title': '시작이 반!',
        'subtitle': '${completed}개 완료! 계속 노력해보세요!',
        'emoji': tier.emoji,
      };
    } else if (completed < 20) {
      return {
        'title': '열심히 하는 중!',
        'subtitle': '${completed}개 완료! 다음 등급까지!',
        'emoji': tier.emoji,
      };
    } else {
      return {
        'title': '프로 미용실!',
        'subtitle': '${completed}개 완료! ${nextTier.name} 등급까지!',
        'emoji': tier.emoji,
      };
    }
  }

  // 현재 월의 날짜 배열 생성
  List<DateTime> _getDaysInMonth(DateTime month) {
    final year = month.year;
    final monthValue = month.month;
    final firstDay = DateTime(year, monthValue, 1);
    final lastDay = DateTime(year, monthValue + 1, 0);
    final days = <DateTime>[];
    
    final startDayOfWeek = firstDay.weekday % 7;
    for (int i = 0; i < startDayOfWeek; i++) {
      days.add(DateTime(year, monthValue, -i));
    }
    
    for (int day = 1; day <= lastDay.day; day++) {
      days.add(DateTime(year, monthValue, day));
    }
    
    return days;
  }

  // 특정 날짜에 스케줄이 있는지 확인
  bool _hasScheduledWork(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return _schedules.any((s) => 
      s.date == dateStr && 
      (s.status == 'scheduled' || s.status == 'completed')
    );
  }

  // 날짜가 완료되었는지 확인
  bool _isCompleted(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return _completedDates.contains(dateStr);
  }

  // 선택된 날짜의 스케줄 목록 가져오기
  List<Schedule> _getSchedulesForDate(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return _schedules.where((s) => 
      s.date == dateStr && s.status == 'scheduled'
    ).toList();
  }

  void _handleScheduleClick(Schedule schedule) {
    setState(() {
      _selectedSchedule = schedule;
    });
  }

  void _handleConfirmWork(String scheduleId) {
    final schedule = _schedules.firstWhere((s) => s.id == scheduleId);
    setState(() {
      _selectedSchedule = schedule;
      _showThumbsUpModal = true;
    });
  }

  Future<void> _handleThumbsUpConfirm(bool giveThumbsUp) async {
    if (_selectedSchedule == null) return;

    try {
      final result = await _scheduleService.confirmWork(
        scheduleId: _selectedSchedule!.id,
        thumbsUp: giveThumbsUp,
      );

      if (giveThumbsUp) {
        try {
          await _spareService.giveThumbsUpToSpare(_selectedSchedule!.spareId);
        } catch (e) {
          print('따봉 전송 실패: $e');
        }
      }

      if (mounted) {
        final message = giveThumbsUp
            ? '정산이 완료되었습니다.\n정산 금액: ${NumberFormat('#,###').format(result['amount'])}원\n\n👍 따봉을 보냈습니다!\n\n등급이 업데이트되었습니다.'
            : '정산이 완료되었습니다.\n정산 금액: ${NumberFormat('#,###').format(result['amount'])}원\n\n등급이 업데이트되었습니다.';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppTheme.primaryGreen,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      setState(() {
        _showThumbsUpModal = false;
        _selectedSchedule = null;
      });
      
      await _loadSchedules();
      await _loadTierInfo();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(error))),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final titleInfo = _getTierTitle();
    final daysInMonth = _getDaysInMonth(_currentMonth);
    final selectedDateSchedules = _getSchedulesForDate(_selectedDate);
    final isDateCompleted = _isCompleted(_selectedDate);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Sticky 헤더
              SliverAppBar(
                pinned: true,
                backgroundColor: AppTheme.backgroundWhite,
                elevation: 0,
                leading: IconButton(
                  icon: IconMapper.icon('chevronleft', size: 24, color: AppTheme.textSecondary) ??
                      const Icon(Icons.arrow_back_ios, color: AppTheme.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Row(
                  children: [
                    Text(
                      '스케줄',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (_tierInfo != null) ...[
                      SizedBox(width: AppTheme.spacing2),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing2,
                          vertical: AppTheme.spacing1,
                        ),
                        decoration: BoxDecoration(
                          color: Color(_tierInfo!.currentTier.colorValue).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          border: Border.all(
                            color: Color(_tierInfo!.currentTier.colorValue),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _tierInfo!.currentTier.emoji,
                              style: const TextStyle(fontSize: 12),
                            ),
                            SizedBox(width: AppTheme.spacing1),
                            Text(
                              _tierInfo!.currentTier.name,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Color(_tierInfo!.currentTier.colorValue),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                centerTitle: false,
              ),

              // 메인 콘텐츠
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Hero Banner
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: AppTheme.spacing8,
                        horizontal: AppTheme.spacing4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryBlueDark,
                            AppTheme.primaryPurple,
                            AppTheme.primaryPink,
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Positioned(
                                top: AppTheme.spacing4,
                                left: AppTheme.spacing4,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: AppTheme.spacing8,
                                right: AppTheme.spacing8,
                                child: Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryPurple500.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    titleInfo['emoji'] as String,
                                    style: const TextStyle(fontSize: 60),
                                  ),
                                  SizedBox(height: AppTheme.spacing3),
                                  Text(
                                    titleInfo['title'] as String,
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: AppTheme.spacing2),
                                  Text(
                                    titleInfo['subtitle'] as String,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: AppTheme.spacing4),
                                  Container(
                                    padding: AppTheme.spacingSymmetric(
                                      horizontal: AppTheme.spacing5,
                                      vertical: AppTheme.spacing2 + AppTheme.spacing1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '현재 등급',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(width: AppTheme.spacing2),
                                        Text(
                                          _tierInfo?.currentTier.name ?? '브론즈',
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 등급 혜택 섹션
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundWhite,
                      ),
                      padding: AppTheme.spacingSymmetric(
                        horizontal: AppTheme.spacing4,
                        vertical: AppTheme.spacing6,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '등급 혜택',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: AppTheme.spacing2),
                          Text(
                            _tierInfo?.currentTier.getNextTier() != null
                                ? '완료 스케줄 ${_tierInfo!.currentTier.getNextTier()!.minCompletedSchedules}개 또는 따봉 ${_tierInfo!.currentTier.getNextTier()!.minThumbsUp}개를 달성하면 다음 등급으로 올라가요!'
                                : '최고 등급입니다!',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          SizedBox(height: AppTheme.spacing4),
                          Container(
                            padding: AppTheme.spacing(AppTheme.spacing4),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundGray,
                              borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '등급 진행률',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textGray700,
                                      ),
                                    ),
                                    if (_tierInfo != null && _tierInfo!.currentTier.getNextTier() != null)
                                      Text(
                                        '${_tierInfo!.completedSchedules} / ${_tierInfo!.currentTier.getNextTier()!.minCompletedSchedules}개',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryBlue,
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: AppTheme.spacing4),
                                // 등급 진행률 게이지
                                if (_tierInfo != null && _tierInfo!.currentTier.getNextTier() != null)
                                  Stack(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF0F3),
                                          borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                        ),
                                        child: Row(
                                          children: [
                                            ...List.generate(9, (index) {
                                              return Expanded(
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                    right: index < 8 ? 0 : 0,
                                                  ),
                                                  child: Align(
                                                    alignment: Alignment.centerRight,
                                                    child: Container(
                                                      width: 3,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        color: AppTheme.borderGray300,
                                                        borderRadius: BorderRadius.circular(2),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                          ],
                                        ),
                                      ),
                                      if (_tierInfo!.progressToNextTier > 0)
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            width: _tierInfo!.progressToNextTier * MediaQuery.of(context).size.width * 0.9,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(_tierInfo!.currentTier.colorValue),
                                                  Color(_tierInfo!.currentTier.getNextTier()!.colorValue),
                                                ],
                                              ),
                                              borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                            ),
                                          ),
                                        ),
                                      if (_tierInfo!.progressToNextTier > 0)
                                        Positioned(
                                          left: _tierInfo!.progressToNextTier * MediaQuery.of(context).size.width * 0.9 - 32,
                                          top: 0,
                                          child: Container(
                                            width: 64,
                                            height: 64,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color(_tierInfo!.currentTier.colorValue),
                                                  Color(_tierInfo!.currentTier.getNextTier()!.colorValue),
                                                ],
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.2),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                _tierInfo!.currentTier.getNextTier()!.emoji,
                                                style: const TextStyle(fontSize: 24),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                SizedBox(height: AppTheme.spacing4),
                                Row(
                                  children: [
                                    Text(
                                      '현재 등급:',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 14,
                                        color: AppTheme.textGray700,
                                      ),
                                    ),
                                    SizedBox(width: AppTheme.spacing2),
                                    Text(
                                      '${_tierInfo?.currentTier.emoji ?? '🥉'} ${_tierInfo?.currentTier.name ?? '브론즈'}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 14,
                                        color: AppTheme.primaryBlue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 스케줄 현황 - 달력
                    Container(
                      width: double.infinity,
                      padding: AppTheme.spacingSymmetric(
                        horizontal: AppTheme.spacing4,
                        vertical: AppTheme.spacing6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundWhite,
                        border: Border(
                          top: BorderSide(
                            color: AppTheme.borderGray,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '스케줄 현황',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: AppTheme.spacing4),
                          // 달력 헤더
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _currentMonth = DateTime(
                                        _currentMonth.year,
                                        _currentMonth.month - 1,
                                      );
                                    });
                                  },
                                  borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                  child: Container(
                                    padding: EdgeInsets.all(AppTheme.spacing2),
                                    child: IconMapper.icon('chevronleft', size: 20, color: AppTheme.textSecondary) ??
                                        const Icon(Icons.chevron_left, size: 20, color: AppTheme.textSecondary),
                                  ),
                                ),
                              ),
                              Text(
                                '${_currentMonth.year}년 ${_currentMonth.month}월',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _currentMonth = DateTime(
                                        _currentMonth.year,
                                        _currentMonth.month + 1,
                                      );
                                    });
                                  },
                                  borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                  child: Container(
                                    padding: EdgeInsets.all(AppTheme.spacing2),
                                    child: IconMapper.icon('chevronright', size: 20, color: AppTheme.textSecondary) ??
                                        const Icon(Icons.chevron_right, size: 20, color: AppTheme.textSecondary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppTheme.spacing4),
                          // 요일 라벨
                          Row(
                            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) {
                              final isSunday = day == 'Sun';
                              final isSaturday = day == 'Sat';
                              return Expanded(
                                child: Center(
                                  child: Text(
                                    day,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSunday
                                          ? AppTheme.urgentRed
                                          : isSaturday
                                              ? AppTheme.primaryBlue
                                              : AppTheme.textGray700,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: AppTheme.spacing2),
                          // 달력 그리드
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              childAspectRatio: 1,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                            ),
                            itemCount: daysInMonth.length,
                            itemBuilder: (context, index) {
                              final date = daysInMonth[index];
                              final isCurrentMonth = date.month == _currentMonth.month;
                              final isToday = DateFormat('yyyy-MM-dd').format(date) == 
                                  DateFormat('yyyy-MM-dd').format(DateTime.now());
                              final hasWork = isCurrentMonth && _hasScheduledWork(date);
                              final isWorkCompleted = isCurrentMonth && _isCompleted(date);
                              final isSelectedDate = DateFormat('yyyy-MM-dd').format(date) == 
                                  DateFormat('yyyy-MM-dd').format(_selectedDate);
                              
                              final weekday = date.weekday % 7;
                              final isSunday = weekday == 0;
                              final isSaturday = weekday == 6;

                              if (!isCurrentMonth) {
                                return const SizedBox.shrink();
                              }

                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedDate = date;
                                    });
                                  },
                                  borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isToday 
                                          ? AppTheme.primaryBlue.withOpacity(0.1)
                                          : AppTheme.backgroundWhite,
                                      border: Border.all(
                                        color: isToday
                                            ? AppTheme.primaryBlue
                                            : hasWork
                                                ? AppTheme.primaryBlue
                                                : AppTheme.borderGray,
                                        width: isSelectedDate && hasWork ? 2 : 1,
                                      ),
                                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                                    ),
                                    padding: EdgeInsets.all(AppTheme.spacing2),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${date.day}',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                fontSize: 14,
                                                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                                                color: isToday
                                                    ? AppTheme.primaryBlue
                                                    : isSunday
                                                        ? AppTheme.urgentRed
                                                        : isSaturday
                                                            ? AppTheme.primaryBlue
                                                            : AppTheme.textGray700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (hasWork)
                                          Padding(
                                            padding: EdgeInsets.only(top: AppTheme.spacing1),
                                            child: isWorkCompleted
                                                ? Container(
                                                    width: 10,
                                                    height: 10,
                                                    decoration: BoxDecoration(
                                                      color: AppTheme.primaryBlue,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: IconMapper.icon('check', size: 6, color: Colors.white) ??
                                                        const Icon(Icons.check, size: 6, color: Colors.white),
                                                  )
                                                : Container(
                                                    width: 10,
                                                    height: 10,
                                                    decoration: BoxDecoration(
                                                      color: AppTheme.primaryPurple500,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: AppTheme.spacing4),
                          // 범례
                          Row(
                            children: [
                              SizedBox(width: AppTheme.spacing4),
                              Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryPurple500,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: AppTheme.spacing1),
                                  Text(
                                    '스케줄 예정',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: AppTheme.spacing4),
                              Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryBlue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconMapper.icon('check', size: 10, color: Colors.white) ??
                                        const Icon(Icons.check, size: 10, color: Colors.white),
                                  ),
                                  SizedBox(width: AppTheme.spacing1),
                                  Text(
                                    '정산 완료',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 선택된 날짜 스케줄 정보 카드
                    if (_hasScheduledWork(_selectedDate))
                      Container(
                        width: double.infinity,
                        padding: AppTheme.spacingSymmetric(
                          horizontal: AppTheme.spacing4,
                          vertical: AppTheme.spacing4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundWhite,
                          border: Border(
                            top: BorderSide(
                              color: AppTheme.borderGray,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          children: _schedules
                              .where((s) => s.date == DateFormat('yyyy-MM-dd').format(_selectedDate))
                              .map((schedule) {
                            final workTimeText = schedule.endTime != null
                                ? '${schedule.startTime}~${schedule.endTime}'
                                : schedule.startTime != null
                                    ? '${schedule.startTime}~'
                                    : '';
                            final isScheduleCompleted = schedule.status == 'completed';

                            return Container(
                              margin: EdgeInsets.only(bottom: AppTheme.spacing3),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: isScheduleCompleted
                                      ? null
                                      : () => _handleScheduleClick(schedule),
                                  borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                                  child: Container(
                                    padding: AppTheme.spacing(AppTheme.spacing4),
                                    decoration: BoxDecoration(
                                      color: _selectedSchedule?.id == schedule.id && !isScheduleCompleted
                                          ? AppTheme.primaryBlue.withOpacity(0.1)
                                          : AppTheme.backgroundWhite,
                                      border: Border.all(
                                        color: _selectedSchedule?.id == schedule.id && !isScheduleCompleted
                                            ? AppTheme.primaryBlue
                                            : AppTheme.borderGray,
                                        width: _selectedSchedule?.id == schedule.id && !isScheduleCompleted ? 2 : 1,
                                      ),
                                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
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
                                                workTimeText,
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  fontSize: 14,
                                                  color: AppTheme.textSecondary,
                                                ),
                                              ),
                                              SizedBox(height: AppTheme.spacing1),
                                              Text(
                                                '${schedule.spare?.name ?? schedule.spareId} | ${NumberFormat('#,###').format(schedule.job?.amount ?? 0)}원',
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  fontSize: 12,
                                                  color: AppTheme.textTertiary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isScheduleCompleted)
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryBlue,
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconMapper.icon('check', size: 20, color: Colors.white) ??
                                                const Icon(Icons.check, size: 20, color: Colors.white),
                                          )
                                        else
                                          Container(
                                            padding: AppTheme.spacingSymmetric(
                                              horizontal: AppTheme.spacing3,
                                              vertical: AppTheme.spacing1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.purple100,
                                              borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                            ),
                                            child: Text(
                                              '정산 대기',
                                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: AppTheme.purple700,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    // 정산 버튼
                    Container(
                      width: double.infinity,
                      padding: AppTheme.spacingSymmetric(
                        horizontal: AppTheme.spacing4,
                        vertical: AppTheme.spacing6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundWhite,
                        border: Border(
                          top: BorderSide(
                            color: AppTheme.borderGray,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: (_selectedSchedule == null ||
                                      isDateCompleted ||
                                      selectedDateSchedules.isEmpty)
                                  ? null
                                  : () => _handleConfirmWork(_selectedSchedule!.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBlue,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppTheme.borderGray300,
                                disabledForegroundColor: AppTheme.textSecondary,
                                padding: AppTheme.spacingSymmetric(
                                  horizontal: AppTheme.spacing4,
                                  vertical: AppTheme.spacing4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '정산하기',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: AppTheme.spacing2),
                                  IconMapper.icon('chevronright', size: 20, color: Colors.white) ??
                                      const Icon(Icons.chevron_right, size: 20, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 등급 보너스 팁
                    Container(
                      width: double.infinity,
                      padding: AppTheme.spacingSymmetric(
                        horizontal: AppTheme.spacing4,
                        vertical: AppTheme.spacing6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundWhite,
                        border: Border(
                          top: BorderSide(
                            color: AppTheme.borderGray,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Container(
                        padding: AppTheme.spacing(AppTheme.spacing4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.backgroundGradientStart,
                              AppTheme.backgroundGradientMiddle,
                              AppTheme.backgroundGradientEnd,
                            ],
                          ),
                          borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('💡', style: TextStyle(fontSize: 24)),
                                SizedBox(width: AppTheme.spacing3),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '등급 보너스 팁',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: AppTheme.spacing1),
                                      Text(
                                        '정산을 완료하고 따봉을 보내면 등급이 올라가요!',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontSize: 14,
                                          color: AppTheme.textGray700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppTheme.spacing3),
                            Container(
                              padding: AppTheme.spacing(AppTheme.spacing3),
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundWhite,
                                borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                              ),
                              child: Row(
                                children: [
                                  const Text('🏆', style: TextStyle(fontSize: 24)),
                                  SizedBox(width: AppTheme.spacing3),
                                  Expanded(
                                    child: Text(
                                      _tierInfo?.currentTier.getNextTier() != null
                                          ? '${_tierInfo!.currentTier.getNextTier()!.name} 등급까지 ${_tierInfo!.requiredSchedulesForNextTier ?? 0}개 완료 또는 ${_tierInfo!.requiredThumbsUpForNextTier ?? 0}개 따봉이 필요해요!'
                                          : '최고 등급입니다! 계속 유지해보세요!',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 14,
                                        color: AppTheme.textGray700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 등급 안내사항
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(
                        top: AppTheme.spacing6,
                        bottom: AppTheme.spacing2,
                        left: AppTheme.spacing4,
                        right: AppTheme.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundWhite,
                        border: Border(
                          top: BorderSide(
                            color: AppTheme.borderGray,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '등급 안내사항',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: AppTheme.spacing4),
                          _buildInfoItem('정산은 완료된 스케줄에만 가능합니다. 스케줄 완료 후 정산해주세요.'),
                          SizedBox(height: AppTheme.spacing3),
                          _buildInfoItem('완료 스케줄 수 또는 받은 따봉 수가 기준을 충족하면 등급이 올라갑니다.'),
                          SizedBox(height: AppTheme.spacing3),
                          _buildInfoItem('등급이 올라가면 공고 등록 수, 노출 우선순위 등 다양한 혜택을 받을 수 있습니다.'),
                          SizedBox(height: AppTheme.spacing3),
                          _buildInfoItem('등급은 실시간으로 업데이트됩니다.'),
                        ],
                      ),
                    ),

                    // 하단 여백
                    SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
          // 스케줄 상세 모달
          if (_selectedSchedule != null && !_showThumbsUpModal)
            _ScheduleDetailModal(
              schedule: _selectedSchedule!,
              onClose: () {
                setState(() {
                  _selectedSchedule = null;
                });
              },
              onConfirmWork: _handleConfirmWork,
            ),
          // 따봉 모달
          if (_showThumbsUpModal && _selectedSchedule != null)
            _ThumbsUpModal(
              schedule: _selectedSchedule!,
              onConfirm: _handleThumbsUpConfirm,
              onCancel: () {
                setState(() {
                  _showThumbsUpModal = false;
                  _selectedSchedule = null;
                });
              },
            ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ShopHomeScreen()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ShopPaymentScreen()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ShopFavoritesScreen()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ShopProfileScreen()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '•',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 14,
            color: AppTheme.primaryBlue,
          ),
        ),
        SizedBox(width: AppTheme.spacing2),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  void _showTierBenefits(BuildContext context) {
    if (_tierInfo == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(
              _tierInfo!.currentTier.emoji,
              style: const TextStyle(fontSize: 24),
            ),
            SizedBox(width: AppTheme.spacing2),
            Text(
              '${_tierInfo!.currentTier.name} 등급 혜택',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Color(_tierInfo!.currentTier.colorValue),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(AppTheme.spacing3),
                decoration: BoxDecoration(
                  color: Color(_tierInfo!.currentTier.colorValue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '현재 등급',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing2),
                    Text(
                      '완료 스케줄: ${_tierInfo!.completedSchedules}개',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '받은 따봉: ${_tierInfo!.thumbsUpReceived}개',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '최대 공고 등록: ${_tierInfo!.maxJobPosts == 999 ? "무제한" : "${_tierInfo!.maxJobPosts}개"}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppTheme.spacing4),
              Text(
                '현재 혜택',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppTheme.spacing2),
              ..._tierInfo!.currentTier.benefits.map((benefit) {
                return Padding(
                  padding: EdgeInsets.only(bottom: AppTheme.spacing1),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Color(_tierInfo!.currentTier.colorValue),
                      ),
                      SizedBox(width: AppTheme.spacing2),
                      Expanded(
                        child: Text(
                          benefit,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if (_tierInfo!.currentTier.getNextTier() != null) ...[
                SizedBox(height: AppTheme.spacing4),
                const Divider(),
                SizedBox(height: AppTheme.spacing4),
                Text(
                  '다음 등급: ${_tierInfo!.currentTier.getNextTier()!.emoji} ${_tierInfo!.currentTier.getNextTier()!.name}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Color(_tierInfo!.currentTier.getNextTier()!.colorValue),
                  ),
                ),
                SizedBox(height: AppTheme.spacing2),
                Text(
                  '필요 조건:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: AppTheme.spacing1),
                Text(
                  '• 완료 스케줄 ${_tierInfo!.currentTier.getNextTier()!.minCompletedSchedules}개 이상',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '• 또는 따봉 ${_tierInfo!.currentTier.getNextTier()!.minThumbsUp}개 이상',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: AppTheme.spacing2),
                Text(
                  '다음 등급 혜택:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: AppTheme.spacing1),
                ..._tierInfo!.currentTier.getNextTier()!.benefits.map((benefit) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: AppTheme.spacing1),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.star_outline,
                          size: 16,
                          color: Color(_tierInfo!.currentTier.getNextTier()!.colorValue),
                        ),
                        SizedBox(width: AppTheme.spacing2),
                        Expanded(
                          child: Text(
                            benefit,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

class _ScheduleDetailModal extends StatefulWidget {
  final Schedule schedule;
  final VoidCallback onClose;
  final ValueChanged<String> onConfirmWork;

  const _ScheduleDetailModal({
    required this.schedule,
    required this.onClose,
    required this.onConfirmWork,
  });

  @override
  State<_ScheduleDetailModal> createState() => _ScheduleDetailModalState();
}

class _ScheduleDetailModalState extends State<_ScheduleDetailModal> {
  @override
  Widget build(BuildContext context) {
    final scheduleDate = DateTime.parse(widget.schedule.date);
    final isPast = scheduleDate.isBefore(DateTime.now());
    final canConfirm = widget.schedule.status == 'completed';

    return Material(
      color: Colors.black.withOpacity(0.5),
      child: GestureDetector(
        onTap: widget.onClose,
        child: Center(
          child: GestureDetector(
            onTap: () {},
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
                            widget.schedule.spare?.name ?? widget.schedule.spareId,
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
                          if (canConfirm)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  widget.onConfirmWork(widget.schedule.id);
                                  widget.onClose();
                                },
                                icon: const Icon(Icons.check, size: 20),
                                label: const Text('근무 확인 및 정산'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryBlue,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: AppTheme.spacing3,
                                  ),
                                ),
                              ),
                            ),
                          if (isPast && !canConfirm)
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

class _ThumbsUpModal extends StatelessWidget {
  final Schedule schedule;
  final ValueChanged<bool> onConfirm;
  final VoidCallback onCancel;

  const _ThumbsUpModal({
    required this.schedule,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: GestureDetector(
        onTap: onCancel,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: EdgeInsets.all(AppTheme.spacing4),
              padding: EdgeInsets.all(AppTheme.spacing6),
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '근무 확인 및 정산',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  Text(
                    '근무 확인 후 정산이 진행됩니다.\n스페어에게 따봉을 보내시겠습니까?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppTheme.spacing6),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => onConfirm(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.borderGray300,
                            foregroundColor: AppTheme.textGray700,
                            padding: EdgeInsets.symmetric(
                              vertical: AppTheme.spacing3,
                            ),
                          ),
                          child: const Text('정산만 하기'),
                        ),
                      ),
                      SizedBox(width: AppTheme.spacing3),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => onConfirm(true),
                          icon: const Icon(Icons.thumb_up, size: 20),
                          label: const Text('따봉 보내기'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryPurple,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: AppTheme.spacing3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacing2),
                  TextButton(
                    onPressed: onCancel,
                    child: Text(
                      '취소',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
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
}
