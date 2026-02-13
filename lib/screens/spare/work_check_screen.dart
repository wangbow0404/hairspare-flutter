import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/notification_bell.dart';
import '../../providers/chat_provider.dart';
import '../../utils/icon_mapper.dart';
import '../../utils/navigation_helper.dart';
import '../../models/schedule.dart';
import '../../services/schedule_service.dart';
import '../../services/review_service.dart';
import '../../utils/error_handler.dart';
import '../../utils/app_exception.dart';
import 'home_screen.dart';
import 'messages_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

/// Next.js와 동일한 출근체크 화면
class WorkCheckScreen extends StatefulWidget {
  const WorkCheckScreen({super.key});

  @override
  State<WorkCheckScreen> createState() => _WorkCheckScreenState();
}

class _WorkCheckScreenState extends State<WorkCheckScreen> {
  int _currentNavIndex = 0;
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();
  final ScheduleService _scheduleService = ScheduleService();
  final ReviewService _reviewService = ReviewService();
  
  // 상태 변수
  List<Schedule> _schedules = [];
  int _consecutiveDays = 0;
  int _energyFromWork = 0;
  bool _isLoading = true;
  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  String? _selectedScheduleId;
  Set<String> _checkedDays = {};
  Set<String> _viewedDates = {}; // 확인한 날짜들 (신규 뱃지 제거용)
  Map<String, String> _pendingApprovals = {}; // 날짜 -> 매장명
  
  // 모달 상태
  bool _showRatingModal = false;
  String? _ratedShopName;
  String? _ratedJobId;
  bool _showTimeWarningModal = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await Future.wait([
        _loadSchedules(),
        _loadWorkCheckStats(),
      ]);
    } catch (e) {
      if (mounted) {
        final appException = ErrorHandler.handleException(e);
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

  Future<void> _loadSchedules() async {
    try {
      final schedules = await _scheduleService.getSchedules();
      setState(() {
        _schedules = schedules;
        
        // 완료된 스케줄 날짜 추출
        final completedDates = <String>{};
        for (final schedule in schedules) {
          if (schedule.status == 'completed' && schedule.checkInTime != null) {
            completedDates.add(schedule.date);
          }
        }
        _checkedDays = completedDates;
      });
    } catch (e) {
      // 에러 처리
      print('스케줄 로드 오류: $e');
    }
  }

  Future<void> _loadWorkCheckStats() async {
    try {
      final stats = await _scheduleService.getWorkCheckStats();
      setState(() {
        _consecutiveDays = stats['consecutiveDays'] as int? ?? 0;
        _energyFromWork = stats['energyFromWork'] as int? ?? 0;
      });
    } catch (e) {
      // 에러 발생 시 기본값 사용
      print('근무 통계 로드 오류: $e');
      setState(() {
        _consecutiveDays = 0;
        _energyFromWork = 0;
      });
    }
  }

  // 연속 근무일수에 따른 제목과 내용
  Map<String, dynamic> _getWorkCheckTitle(int days) {
    if (days == 0) {
      return {
        'title': '근무체크 시작하기',
        'subtitle': '2026년 에너지를 채우기 시작해보세요!',
        'emoji': '🚀',
      };
    } else if (days == 1) {
      return {
        'title': '스페어 비기너!',
        'subtitle': '2026년 에너지를 채우기 시작했어요! 부릉!',
        'emoji': '🌱',
      };
    } else if (days < 3) {
      return {
        'title': '시작이 반!',
        'subtitle': '$days일 연속 근무 중이에요!',
        'emoji': '🌱',
      };
    } else if (days < 5) {
      return {
        'title': '열심히 하는 중!',
        'subtitle': '$days일 연속 근무 중이에요!',
        'emoji': '💪',
      };
    } else if (days < 7) {
      return {
        'title': '꾸준함의 힘!',
        'subtitle': '$days일 연속 근무 중이에요!',
        'emoji': '🔥',
      };
    } else if (days < 10) {
      return {
        'title': '프로 스페어!',
        'subtitle': '$days일 연속 근무 중이에요!',
        'emoji': '⭐',
      };
    } else if (days == 10) {
      return {
        'title': '에너지 획득!',
        'subtitle': '$days일 연속 근무로 에너지 1개를 받았어요!',
        'emoji': '⚡',
      };
    } else {
      return {
        'title': '에너지 마스터!',
        'subtitle': '$days일 연속 근무 중이에요!',
        'emoji': '⚡',
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
    
    // 첫 주의 시작일까지 빈 칸 추가
    final startDayOfWeek = firstDay.weekday % 7; // 일요일 = 0
    for (int i = 0; i < startDayOfWeek; i++) {
      days.add(DateTime(year, monthValue, -i));
    }
    
    // 해당 월의 모든 날짜
    for (int day = 1; day <= lastDay.day; day++) {
      days.add(DateTime(year, monthValue, day));
    }
    
    return days;
  }

  // 특정 날짜에 근무가 있는지 확인
  bool _hasScheduledWork(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return _schedules.any((s) => 
      s.date == dateStr && 
      (s.status == 'scheduled' || s.status == 'completed')
    );
  }

  // 특정 날짜의 근무 정보 가져오기
  Schedule? _getWorkInfo(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    try {
      return _schedules.firstWhere(
        (s) => s.date == dateStr,
      );
    } catch (e) {
      // 스케줄이 없으면 null 반환
      return null;
    }
  }

  // 날짜가 체크되었는지 확인
  bool _isChecked(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return _checkedDays.contains(dateStr);
  }

  // 선택된 날짜의 근무 예정 목록 가져오기
  List<Schedule> _getSchedulesForDate(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return _schedules.where((s) => 
      s.date == dateStr && s.status == 'scheduled'
    ).toList();
  }

  // 근무체크하기
  Future<void> _handleCheckIn() async {
    if (_selectedScheduleId == null) return;
    
    try {
      final selectedSchedule = _schedules.firstWhere(
        (s) => s.id == _selectedScheduleId,
      );
      
      // 시간 검증: 근무 종료 시간이 지났는지 확인
      final now = DateTime.now();
      DateTime? workEndTime;
      
      if (selectedSchedule.endTime != null) {
        final timeParts = selectedSchedule.endTime!.split(':');
        final endHour = int.parse(timeParts[0]);
        final endMinute = int.parse(timeParts[1]);
        final scheduleDate = DateTime.parse(selectedSchedule.date);
        workEndTime = DateTime(
          scheduleDate.year,
          scheduleDate.month,
          scheduleDate.day,
          endHour,
          endMinute,
        );
      }
      
      // 근무 종료 시간이 지나지 않았으면 경고 모달 표시
      if (workEndTime != null && now.isBefore(workEndTime)) {
        setState(() {
          _showTimeWarningModal = true;
        });
        return;
      }
      
      // 따봉 모달 먼저 표시
      final shopName = selectedSchedule.job?.shopName ?? '매장';
      final jobId = selectedSchedule.jobId;
      setState(() {
        _ratedShopName = shopName;
        _ratedJobId = jobId;
        _showRatingModal = true;
      });
    } catch (e) {
      // 스케줄을 찾을 수 없을 때 에러 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('근무 정보를 찾을 수 없습니다.'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  // 따봉 클릭
  Future<void> _handleThumbsUp() async {
    if (_ratedJobId == null || _selectedScheduleId == null) {
      setState(() {
        _showRatingModal = false;
        _ratedShopName = null;
        _ratedJobId = null;
      });
      return;
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final shopName = _ratedShopName ?? '매장';
    
    // 승인 대기 상태로 변경
    setState(() {
      _pendingApprovals[dateStr] = shopName;
    });

    try {
      // 체크인 API 호출
      final updatedSchedule = await _scheduleService.checkInSchedule(_selectedScheduleId!);
      
      // 따봉 데이터 전송
      if (_ratedJobId != null) {
        try {
          await _reviewService.sendThumbsUp(
            jobId: _ratedJobId!,
          );
        } catch (e) {
          // 따봉 전송 실패해도 체크인은 완료된 것으로 처리
          print('따봉 데이터 전송 실패: $e');
        }
      }
      
      // 로컬 상태 업데이트
      setState(() {
        _schedules = _schedules.map((s) {
          if (s.id == _selectedScheduleId) {
            return updatedSchedule;
          }
          return s;
        }).toList();
        _checkedDays.add(dateStr);
        _pendingApprovals.remove(dateStr);
        _showRatingModal = false;
        _ratedShopName = null;
        _ratedJobId = null;
        _selectedScheduleId = null;
      });
      
      // 통계 다시 로드
      _loadWorkCheckStats();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('근무체크가 완료되었습니다!'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    } catch (e) {
      setState(() {
        _pendingApprovals.remove(dateStr);
        _showRatingModal = false;
        _ratedShopName = null;
        _ratedJobId = null;
      });
      final appException = ErrorHandler.handleException(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHandler.getUserFriendlyMessage(appException)),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }

  // 모달 닫기 (따봉 안 누르고 닫기)
  Future<void> _handleCloseRatingModal() async {
    if (_selectedScheduleId == null) {
      setState(() {
        _showRatingModal = false;
        _ratedShopName = null;
        _ratedJobId = null;
      });
      return;
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    try {
      final selectedSchedule = _schedules.firstWhere(
        (s) => s.id == _selectedScheduleId,
      );
      final shopName = selectedSchedule.job?.shopName ?? '매장';
      
      // 승인 대기 상태로 변경
      setState(() {
        _pendingApprovals[dateStr] = shopName;
      });

      // 체크인 API 호출 (미용실 승인 데이터 전송) - 따봉 데이터는 전송 안 함
      final updatedSchedule = await _scheduleService.checkInSchedule(_selectedScheduleId!);
      
      // 로컬 상태 업데이트
      setState(() {
        _schedules = _schedules.map((s) {
          if (s.id == _selectedScheduleId) {
            return updatedSchedule;
          }
          return s;
        }).toList();
        _checkedDays.add(dateStr);
        _pendingApprovals.remove(dateStr);
        _showRatingModal = false;
        _ratedShopName = null;
        _ratedJobId = null;
        _selectedScheduleId = null;
      });
      
      // 통계 다시 로드
      _loadWorkCheckStats();
    } catch (e) {
      setState(() {
        _pendingApprovals.remove(dateStr);
        _showRatingModal = false;
        _ratedShopName = null;
        _ratedJobId = null;
      });
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

    final titleInfo = _getWorkCheckTitle(_consecutiveDays);
    final displayDays = _consecutiveDays % 10; // 10일이 되면 0일로 표시
    final daysInMonth = _getDaysInMonth(_currentMonth);
    final selectedDateSchedules = _getSchedulesForDate(_selectedDate);
    final isDateChecked = _isChecked(_selectedDate);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final hasNewSchedule = _hasScheduledWork(_selectedDate) && 
        !_viewedDates.contains(dateStr) && 
        !isDateChecked;

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
            leading: null,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.borderGray,
                    width: 1,
                  ),
                ),
              ),
              padding: AppTheme.spacingSymmetric(
                horizontal: AppTheme.spacing4,
                vertical: AppTheme.spacing3,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      NavigationHelper.navigateToHomeFromLogo(context);
                    },
                    child: Text(
                      'HairSpare',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_isSearchOpen) ...[
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: '검색어를 입력하세요',
                          border: OutlineInputBorder(
                            borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryBlue,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryBlue,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryBlue,
                              width: 2,
                            ),
                          ),
                          contentPadding: AppTheme.spacingSymmetric(
                            horizontal: AppTheme.spacing4,
                            vertical: AppTheme.spacing2,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    SizedBox(width: AppTheme.spacing2),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isSearchOpen = false;
                            _searchController.clear();
                          });
                        },
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                        child: Container(
                          padding: EdgeInsets.all(AppTheme.spacing2),
                          child: IconMapper.icon('x', size: 24, color: AppTheme.textSecondary) ??
                              const Icon(Icons.close, size: 24, color: AppTheme.textSecondary),
                        ),
                      ),
                    ),
                  ] else ...[
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isSearchOpen = true;
                          });
                        },
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                        child: Container(
                          padding: EdgeInsets.all(AppTheme.spacing2),
                          child: IconMapper.icon('search', size: 24, color: AppTheme.textSecondary) ??
                              const Icon(Icons.search, size: 24, color: AppTheme.textSecondary),
                        ),
                      ),
                    ),
                    SizedBox(width: AppTheme.spacing3),
                    // 메시지 버튼
                    Consumer<ChatProvider>(
                      builder: (context, chatProvider, _) {
                        final unreadCount = chatProvider.totalUnreadCount;
                        return Stack(
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const MessagesScreen()),
                                  );
                                },
                                borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                child: Container(
                                  padding: EdgeInsets.all(AppTheme.spacing2),
                                  child: IconMapper.icon('messagecircle', size: 24, color: AppTheme.textSecondary) ??
                                      const Icon(Icons.message_outlined, size: 24, color: AppTheme.textSecondary),
                                ),
                              ),
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppTheme.urgentRed,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    SizedBox(width: AppTheme.spacing3),
                    // 알림 버튼
                    NotificationBell(
                      role: 'spare',
                    ),
                  ],
                ],
              ),
            ),
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
                      // 배경 장식
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
                                      '현재 연속 근무',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: AppTheme.spacing2),
                                    Text(
                                      '$displayDays일',
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

                // 근무 보상 섹션 - 에너지 게이지
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
                        '근무 보상',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing2),
                      Text(
                        '노쇼 없이 10일 연속 근무하면 에너지 1개를 받아요!',
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
                                  '에너지 진행률',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textGray700,
                                  ),
                                ),
                                Text(
                                  '$displayDays / 10일',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppTheme.spacing4),
                            // 에너지 게이지
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
                                      // 틱 마크 (9개 구분선 - 10등분)
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
                                // 채워진 진행률 (그라데이션)
                                if (displayDays > 0)
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    child: Container(
                                      width: (displayDays / 10) * MediaQuery.of(context).size.width * 0.9,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppTheme.primaryBlue,
                                            AppTheme.primaryPurple500,
                                          ],
                                        ),
                                        borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                      ),
                                    ),
                                  ),
                                // 원형 배지 (번개 아이콘)
                                if (displayDays > 0)
                                  Positioned(
                                    left: (displayDays / 10) * MediaQuery.of(context).size.width * 0.9 - 32,
                                    top: 0,
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppTheme.primaryBlue,
                                            AppTheme.primaryPurple500,
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
                                      child: const Center(
                                        child: Text(
                                          '⚡',
                                          style: TextStyle(fontSize: 24),
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
                                  '획득한 에너지:',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 14,
                                    color: AppTheme.textGray700,
                                  ),
                                ),
                                SizedBox(width: AppTheme.spacing2),
                                if (_energyFromWork > 0)
                                  Row(
                                    children: List.generate(_energyFromWork, (index) {
                                      return Container(
                                        width: 32,
                                        height: 32,
                                        margin: EdgeInsets.only(right: AppTheme.spacing1),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppTheme.blue200,
                                              AppTheme.primaryPurple500,
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Text(
                                            '⚡',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      );
                                    }),
                                  )
                                else
                                  Text(
                                    '아직 없음',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 14,
                                      color: AppTheme.primaryBlue,
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

                // 근무 현황 - 달력
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
                        '근무 현황',
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
                          final isWorkChecked = isCurrentMonth && _isChecked(date);
                          // hasWork가 true일 때만 workInfo 가져오기 (에러 방지)
                          final workInfo = (isCurrentMonth && hasWork) ? _getWorkInfo(date) : null;
                          final isSelectedDate = DateFormat('yyyy-MM-dd').format(date) == 
                              DateFormat('yyyy-MM-dd').format(_selectedDate);
                          final dateStr = DateFormat('yyyy-MM-dd').format(date);
                          final hasNewSchedule = hasWork && 
                              !_viewedDates.contains(dateStr) && 
                              !isWorkChecked;
                          
                          // 요일 확인 (일요일 = 0, 토요일 = 6)
                          final weekday = date.weekday % 7; // 일요일 = 0, 월요일 = 1, ..., 토요일 = 6
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
                                  if (hasWork) {
                                    _viewedDates.add(dateStr);
                                  }
                                  _selectedScheduleId = null;
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
                                        if (hasNewSchedule)
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: AppTheme.urgentRed,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (hasWork)
                                      Padding(
                                        padding: EdgeInsets.only(top: AppTheme.spacing1),
                                        child: isWorkChecked
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
                                '근무 예정',
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
                                '근무 완료',
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

                // 선택된 날짜 근무 정보 카드
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
                                ? '${schedule.startTime}~${_calculateEndTime(schedule.startTime)}'
                                : '';
                        final isSelected = _selectedScheduleId == schedule.id;
                        final isScheduleChecked = schedule.status == 'completed';
                        final scheduleDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
                        final hasNewSchedule = !_viewedDates.contains(scheduleDateStr) && 
                            !isScheduleChecked;

                        return Container(
                          margin: EdgeInsets.only(bottom: AppTheme.spacing3),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isScheduleChecked
                                  ? null
                                  : () {
                                      setState(() {
                                        _selectedScheduleId = schedule.id;
                                        _viewedDates.add(scheduleDateStr);
                                      });
                                    },
                              borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                              child: Container(
                                padding: AppTheme.spacing(AppTheme.spacing4),
                                decoration: BoxDecoration(
                                  color: isSelected && !isScheduleChecked
                                      ? AppTheme.primaryBlue.withOpacity(0.1)
                                      : AppTheme.backgroundWhite,
                                  border: Border.all(
                                    color: isSelected && !isScheduleChecked
                                        ? AppTheme.primaryBlue
                                        : AppTheme.borderGray,
                                    width: isSelected && !isScheduleChecked ? 2 : 1,
                                  ),
                                  borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                                ),
                                child: Stack(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                schedule.job?.shopName ?? '매장',
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
                                                '${schedule.job?.shopName ?? '매장'} 근무',
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  fontSize: 12,
                                                  color: AppTheme.textTertiary,
                                                ),
                                              ),
                                              if (isScheduleChecked && schedule.checkInTime != null) ...[
                                                SizedBox(height: AppTheme.spacing3),
                                                Container(
                                                  padding: EdgeInsets.only(top: AppTheme.spacing3),
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      top: BorderSide(
                                                        color: AppTheme.borderGray,
                                                        width: 1,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    '체크인: ${DateFormat('yyyy-MM-dd HH:mm').format(schedule.checkInTime!)}',
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      fontSize: 12,
                                                      color: AppTheme.textTertiary,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        if (isScheduleChecked)
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
                                              '근무 예정',
                                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: AppTheme.purple700,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (hasNewSchedule && !isScheduleChecked)
                                      Positioned(
                                        top: AppTheme.spacing3,
                                        right: AppTheme.spacing3,
                                        child: Container(
                                          padding: AppTheme.spacingSymmetric(
                                            horizontal: AppTheme.spacing2,
                                            vertical: AppTheme.spacing1 / 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.urgentRed,
                                            borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                          ),
                                          child: Text(
                                            '신규',
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
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

                // 근무체크 버튼
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
                      // 승인 대기 상태
                      if (_pendingApprovals.containsKey(DateFormat('yyyy-MM-dd').format(_selectedDate)))
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: AppTheme.spacing4),
                          padding: AppTheme.spacing(AppTheme.spacing3),
                          decoration: BoxDecoration(
                            color: AppTheme.yellow50,
                            border: Border.all(
                              color: AppTheme.yellow600,
                              width: 1,
                            ),
                            borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                          ),
                          child: Text(
                            '${_pendingApprovals[DateFormat('yyyy-MM-dd').format(_selectedDate)]}에서 승인 대기 중입니다...',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 14,
                              color: AppTheme.yellow800,
                            ),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_selectedScheduleId == null ||
                                  _isChecked(_selectedDate) ||
                                  _pendingApprovals.containsKey(DateFormat('yyyy-MM-dd').format(_selectedDate)))
                              ? null
                              : _handleCheckIn,
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
                                '근무체크하기',
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

                // 근무 보너스 팁
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
                                    '근무 보너스 팁',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: AppTheme.spacing1),
                                  Text(
                                    '매일 출석하면 최대 에너지 3개를 받을 수 있어요!',
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
                              const Text('💰', style: TextStyle(fontSize: 24)),
                              SizedBox(width: AppTheme.spacing3),
                              Expanded(
                                child: Text(
                                  _consecutiveDays >= 30
                                      ? '$_consecutiveDays일을 연속 출근하면 에너지 3개! 최대 3만원을 아낄 수 있어요!'
                                      : _consecutiveDays >= 20
                                          ? '$_consecutiveDays일을 연속 출근하면 에너지 2개! 최대 2만원을 아낄 수 있어요!'
                                          : _consecutiveDays >= 10
                                              ? '$_consecutiveDays일을 연속 출근하면 에너지 1개! 최대 1만원을 아낄 수 있어요!'
                                              : '30일을 연속 출근하면 에너지 3개! 최대 3만원을 아낄 수 있어요!',
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

                // 근무체크 안내사항
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
                        '근무체크 안내사항',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing4),
                      _buildInfoItem('근무체크는 승인받은 근무 일정에만 가능합니다. 당일 근무를 마치고 체크해주세요.'),
                      SizedBox(height: AppTheme.spacing3),
                      _buildInfoItem('노쇼 없이 10일 연속 근무하면 에너지 1개를 받을 수 있습니다.'),
                      SizedBox(height: AppTheme.spacing3),
                      _buildInfoItem('연속 근무가 끊기면 에너지 게이지는 초기화됩니다.'),
                      SizedBox(height: AppTheme.spacing3),
                      _buildInfoItem('연속 근무는 달이 넘어가도 이어집니다.'),
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
          // 평가 모달
          if (_showRatingModal && _ratedShopName != null)
            _buildRatingModal(),
          // 시간 경고 모달
          if (_showTimeWarningModal)
            _buildTimeWarningModal(),
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

  String _calculateEndTime(String startTime) {
    try {
      final parts = startTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      final endHour = (hour + 4) % 24;
      return '${endHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return startTime;
    }
  }

  Widget _buildRatingModal() {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: EdgeInsets.all(AppTheme.spacing4),
          padding: AppTheme.spacing(AppTheme.spacing6),
          decoration: BoxDecoration(
            color: AppTheme.backgroundWhite,
            borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _handleCloseRatingModal,
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                      child: Container(
                        padding: EdgeInsets.all(AppTheme.spacing1),
                        child: IconMapper.icon('x', size: 20, color: AppTheme.textSecondary) ??
                            const Icon(Icons.close, size: 20, color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.spacing2),
              Text(
                '${_ratedShopName}의 근무는 괜찮으셨나요? 😊',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppTheme.spacing4),
              Text(
                '만족스러우셨다면 따봉을 눌러주세요!',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppTheme.spacing6),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _handleThumbsUp,
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '👍',
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeWarningModal() {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: EdgeInsets.all(AppTheme.spacing4),
          padding: AppTheme.spacing(AppTheme.spacing6),
          decoration: BoxDecoration(
            color: AppTheme.backgroundWhite,
            borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
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
              const Text(
                '⏰',
                style: TextStyle(fontSize: 48),
              ),
              SizedBox(height: AppTheme.spacing4),
              Text(
                '앗, 아직 근무가 끝나지 않았어요!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppTheme.spacing2),
              Text(
                '근무 종료 시간이 지난 후에 체크할 수 있습니다.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppTheme.spacing6),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showTimeWarningModal = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: AppTheme.spacingSymmetric(
                      horizontal: AppTheme.spacing4,
                      vertical: AppTheme.spacing3,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                    ),
                  ),
                  child: Text(
                    '확인',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
