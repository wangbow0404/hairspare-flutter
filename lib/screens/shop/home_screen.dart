import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/notification_bell.dart';
import '../../widgets/category_grid.dart';
import '../../models/job.dart';
import '../../models/spare_profile.dart';
import '../../theme/app_theme.dart';
import '../../widgets/banner_carousel.dart';
import '../../widgets/spare_card.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../services/spare_service.dart';
import '../../services/job_service.dart';
import '../../utils/error_handler.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/icon_mapper.dart';
import 'job_detail_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'messages_screen.dart';
import 'my_spaces_screen.dart';
import 'work_check_screen.dart';
import 'spares_list_screen.dart';
import 'jobs_list_screen.dart';
// import 'region_select_screen.dart'; // 지역별 카테고리 제거로 인해 주석 처리
import 'schedule_screen.dart';
import 'education_screen.dart';
import 'challenge_screen.dart';
import 'points_screen.dart';
import 'job_new_screen.dart';
import 'store_screen.dart';
import 'connect_screen.dart';
import 'applicants_screen.dart';
import 'vip_status_screen.dart';

/// Shop 홈 화면
class ShopHomeScreen extends StatefulWidget {
  const ShopHomeScreen({super.key});

  @override
  State<ShopHomeScreen> createState() => _ShopHomeScreenState();
}

class _ShopHomeScreenState extends State<ShopHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();
  int _currentNavIndex = 0;
  
  final SpareService _spareService = SpareService();
  final JobService _jobService = JobService();
  
  List<SpareProfile> _popularSpares = [];
  List<SpareProfile> _newSpares = [];
  List<SpareProfile> _regularSpares = [];
  List<Job> _urgentJobs = [];
  List<Job> _normalJobs = [];
  bool _isLoading = true;
  int _pendingApplicantsCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      Provider.of<FavoriteProvider>(context, listen: false).loadFavorites();
      // loadNotifications는 _loadData 내부에서 호출됨
      Provider.of<ChatProvider>(context, listen: false).loadChats();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // 알림 먼저 로드 (대기 중인 지원자 수 계산을 위해)
      await Provider.of<NotificationProvider>(context, listen: false).loadNotifications();
      
      // 자신이 등록한 공고 가져오기
      final jobs = await _jobService.getMyJobs();
      
      // 급구와 일반 공고 분리
      final urgent = jobs.where((job) => job.isUrgent).toList();
      final normal = jobs.where((job) => !job.isUrgent).toList();
      
      // 인기 스페어 가져오기 (평점 높고 완료 건수 많은 순)
      final popularSpares = await _spareService.getSpares(
        sortBy: 'popular',
        limit: 10,
      );
      
      // 신규 스페어 가져오기 (최근 가입한 순)
      final newSpares = await _spareService.getSpares(
        sortBy: 'newest',
        limit: 10,
      );
      
      // 일반 스페어 가져오기
      final regularSpares = await _spareService.getSpares(
        limit: 10,
      );
      
      // 대기 중인 지원자 수 계산 (알림에서 spare_application 타입 카운트)
      if (mounted) {
        final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
        final pendingApplicants = notificationProvider.notifications
            .where((n) => n.type == 'spare_application' && !n.isRead)
            .length;

        setState(() {
          _urgentJobs = urgent;
          _normalJobs = normal;
          _popularSpares = popularSpares;
          _newSpares = newSpares;
          _regularSpares = regularSpares;
          _pendingApplicantsCount = pendingApplicants;
          _isLoading = false;
        });
      }
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('데이터 로드 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleJobTap(Job job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShopJobDetailScreen(jobId: job.id),
      ),
    );
  }

  void _handleSpareTap(SpareProfile spare) {
    // 스페어 상세 화면으로 이동 (구현 예정)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShopSparesListScreen(),
      ),
    );
  }

  Widget _buildHomeScreen() {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              controller: _scrollController,
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
                        // 로고
                        GestureDetector(
                          onTap: () {
                            _scrollController.animateTo(
                              0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          },
                          child: Text(
                            'HairSpare',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryPurple,
                                ),
                          ),
                        ),
                        const Spacer(),
                        // 검색/메시지/알림 버튼들
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
                                    color: AppTheme.primaryPurple,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                                  borderSide: const BorderSide(
                                    color: AppTheme.primaryPurple,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                                  borderSide: const BorderSide(
                                    color: AppTheme.primaryPurple,
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
                                          MaterialPageRoute(builder: (context) => const ShopMessagesScreen()),
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
                                      right: 8,
                                      top: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: AppTheme.urgentRed,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Text(
                                          unreadCount > 99 ? '99+' : '$unreadCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          SizedBox(width: AppTheme.spacing3),
                          const NotificationBell(role: 'shop'),
                        ],
                      ],
                    ),
                  ),
                ),
                
                // 배너 캐러셀
                SliverToBoxAdapter(
                  child: BannerCarousel(
                    bannerImages: const [
                      'assets/images/banners/banner1.jpg',
                      'assets/images/banners/banner2.jpg',
                      'assets/images/banners/banner3.jpg',
                      'assets/images/banners/banner4.jpg',
                    ],
                    onBannerTap: (index) {
                      // 배너 클릭 처리
                    },
                  ),
                ),
                
                // 카테고리 그리드 (스페어 화면과 동일한 순서와 이모티콘)
                SliverToBoxAdapter(
                  child: CategoryGrid(
                    categories: [
                      CategoryItem(
                        emoji: '👥',
                        label: '인력별',
                        has3DEffect: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ShopSparesListScreen()),
                          );
                        },
                      ),
                      CategoryItem(
                        emoji: '📅',
                        label: '스케줄표',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ShopScheduleScreen()),
                          );
                        },
                      ),
                      CategoryItem(
                        emoji: '🏪',
                        label: '스토어',
                        has3DEffect: true,
                        onTap: () {
                          // 스토어 화면 구성이 아직 안 되어 있으므로 모달만 표시
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('준비 중'),
                              content: const Text('스토어 기능은 준비 중입니다.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('확인'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      CategoryItem(
                        emoji: '💰',
                        label: '+포인트',
                        has3DEffect: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ShopPointsScreen()),
                          );
                        },
                      ),
                      CategoryItem(
                        emoji: '🗺️',
                        label: '공간대여',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ShopMySpacesScreen()),
                          );
                        },
                      ),
                      CategoryItem(
                        emoji: '📚',
                        label: '교육',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ShopEducationScreen()),
                          );
                        },
                      ),
                      CategoryItem(
                        emoji: '🎯',
                        label: '챌린지참여',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ShopChallengeScreen()),
                          );
                        },
                      ),
                      CategoryItem(
                        emoji: '💡',
                        label: '커넥트',
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radius2xl),
                              ),
                              title: const Text('준비 중'),
                              content: const Text('커넥트 기능은 준비 중입니다.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('확인'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                // 대시보드 카드 섹션
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.all(AppTheme.spacing4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildDashboardCard(
                            value: '${_urgentJobs.length + _normalJobs.length}',
                            label: '활성 공고',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF9333EA), Color(0xFFEC4899)],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ShopJobsListScreen()),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: AppTheme.spacing4),
                        Expanded(
                          child: _buildDashboardCard(
                            value: '$_pendingApplicantsCount',
                            label: '대기 지원자',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                            ),
                            onTap: () {
                              // 지원자 관리 화면으로 이동 (나중에 구현)
                            },
                          ),
                        ),
                        SizedBox(width: AppTheme.spacing4),
                        Expanded(
                          child: _buildDashboardCard(
                            value: '-',
                            label: '오늘 일정',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ShopScheduleScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 빠른 액션 섹션
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing4,
                      vertical: AppTheme.spacing4,
                    ),
                    color: AppTheme.backgroundGray,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '빠른 액션',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                        ),
                        SizedBox(height: AppTheme.spacing3),
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickActionCard(
                                icon: Icons.add,
                                title: '공고 올리기',
                                subtitle: '새로운 공고 등록',
                                color: AppTheme.primaryPurple,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ShopJobNewScreen()),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: AppTheme.spacing3),
                            Expanded(
                              child: _buildQuickActionCard(
                                icon: Icons.assignment,
                                title: '내 공고 확인',
                                subtitle: '등록한 공고 관리',
                                color: Colors.orange,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ShopJobsListScreen()),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppTheme.spacing3),
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickActionCard(
                                icon: Icons.people,
                                title: '지원자 확인',
                                subtitle: '공고별 지원자 관리',
                                color: Colors.blue,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ShopApplicantsScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: AppTheme.spacing3),
                            Expanded(
                              child: _buildQuickActionCard(
                                icon: Icons.star,
                                title: 'VIP 현황',
                                subtitle: '완료 작업 및 등급',
                                color: Colors.amber,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ShopVipStatusScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 급구 공고 섹션
                if (_urgentJobs.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppTheme.spacing4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '급구 공고',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ShopJobsListScreen()),
                              );
                            },
                            child: const Text('더보기'),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_urgentJobs.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
                        itemCount: _urgentJobs.length,
                        itemBuilder: (context, index) {
                          final job = _urgentJobs[index];
                          return Container(
                            width: 300,
                            margin: EdgeInsets.only(right: AppTheme.spacing3),
                            child: Card(
                              child: ListTile(
                                title: Text(job.title),
                                subtitle: Text('${job.shopName} | ${job.date} ${job.time}'),
                                trailing: Text('${job.amount}원'),
                                onTap: () => _handleJobTap(job),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                
                // 인기 스페어 섹션
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppTheme.spacing4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '인기 지원자',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                            ),
                            SizedBox(width: AppTheme.spacing2),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppTheme.spacing2,
                                vertical: AppTheme.spacing1,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF9333EA), Color(0xFFEC4899)],
                                ),
                                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                              ),
                              child: const Text(
                                'HOT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ShopSparesListScreen()),
                            );
                          },
                          child: const Text('더보기'),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
                      itemCount: _popularSpares.length,
                      itemBuilder: (context, index) {
                        final spare = _popularSpares[index];
                        return Container(
                          width: 200,
                          margin: EdgeInsets.only(right: AppTheme.spacing3),
                          child: SpareCard(
                            spare: spare,
                            onTap: () => _handleSpareTap(spare),
                            compact: true,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // 신규 스페어 섹션
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppTheme.spacing4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '신규 지원자',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ShopSparesListScreen()),
                            );
                          },
                          child: const Text('더보기'),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
                      itemCount: _newSpares.length,
                      itemBuilder: (context, index) {
                        final spare = _newSpares[index];
                        return Container(
                          width: 200,
                          margin: EdgeInsets.only(right: AppTheme.spacing3),
                          child: SpareCard(
                            spare: spare,
                            onTap: () => _handleSpareTap(spare),
                            compact: true,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // 일반 지원자 섹션
                if (_regularSpares.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppTheme.spacing4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '일반 지원자',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ShopSparesListScreen()),
                              );
                            },
                            child: const Text('더보기'),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_regularSpares.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final spare = _regularSpares[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing4,
                            vertical: AppTheme.spacing2,
                          ),
                          child: SpareCard(
                            spare: spare,
                            onTap: () => _handleSpareTap(spare),
                          ),
                        );
                      },
                      childCount: _regularSpares.length,
                    ),
                  ),
                
                // 일반 공고 섹션
                if (_normalJobs.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppTheme.spacing4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '일반 공고',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ShopJobsListScreen()),
                              );
                            },
                            child: const Text('더보기'),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_normalJobs.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final job = _normalJobs[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing4,
                            vertical: AppTheme.spacing2,
                          ),
                          child: Card(
                            child: ListTile(
                              title: Text(job.title),
                              subtitle: Text('${job.shopName} | ${job.date} ${job.time}'),
                              trailing: Text('${job.amount}원'),
                              onTap: () => _handleJobTap(job),
                            ),
                          ),
                        );
                      },
                      childCount: _normalJobs.length,
                    ),
                  ),
                
                // 하단 여백
                SliverToBoxAdapter(
                  child: SizedBox(height: 80),
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
              // 홈은 현재 화면이므로 스크롤만 맨 위로
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
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

  Widget _buildDashboardCard({
    required String value,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppTheme.spacing4),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: AppTheme.spacing1),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppTheme.spacing4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.borderGray),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: AppTheme.spacing3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing1),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildHomeScreen();
  }
}
