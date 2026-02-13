import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/notification_bell.dart';
import '../../models/job.dart';
import '../../theme/app_theme.dart';
import '../../widgets/banner_carousel.dart';
import '../../widgets/category_grid.dart';
import '../../widgets/urgent_job_section.dart';
import '../../widgets/normal_jobs_section.dart';
import '../../widgets/popular_jobs_section.dart';
import '../../widgets/new_jobs_section.dart';
import '../../widgets/upcoming_shops_section.dart';
import '../../widgets/category_jobs_section.dart';
import '../../widgets/bottom_nav_bar.dart'; // BottomNavBar import
import '../../widgets/customer_service_section.dart'; // CustomerServiceSection import
import '../../utils/navigation_helper.dart'; // NavigationHelper import
import '../spare/job_detail_screen.dart';
import '../spare/payment_screen.dart';
import '../spare/favorites_screen.dart';
import '../spare/profile_screen.dart';
import '../spare/points_screen.dart';
import '../spare/messages_screen.dart';
import '../spare/work_check_screen.dart';
import '../spare/schedule_screen.dart';
import '../spare/region_select_screen.dart';
import '../spare/education_screen.dart';
import '../spare/challenge_screen.dart';
import '../spare/jobs_list_screen.dart';
import '../spare/energy_screen.dart';
import '../spare/store_screen.dart';
import '../spare/connect_screen.dart';
import '../../utils/icon_mapper.dart'; // IconMapper import

class SpareHomeScreen extends StatefulWidget {
  const SpareHomeScreen({super.key});

  @override
  State<SpareHomeScreen> createState() => _SpareHomeScreenState();
}

class _SpareHomeScreenState extends State<SpareHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();
  int _currentNavIndex = 0; // 현재 네비게이션 인덱스

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false).loadJobs();
      Provider.of<FavoriteProvider>(context, listen: false).loadFavorites();
      Provider.of<NotificationProvider>(context, listen: false).loadNotifications();
      Provider.of<ChatProvider>(context, listen: false).loadChats();
      
      // 실시간 알림 갱신 (10초마다)
      _startNotificationRefresh();
      
      // 실시간 채팅 목록 갱신 (10초마다)
      _startChatRefresh();
    });
  }

  void _startNotificationRefresh() {
    // 10초마다 알림 갱신
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        Provider.of<NotificationProvider>(context, listen: false).refreshNotifications();
        _startNotificationRefresh(); // 재귀적으로 계속 실행
      }
    });
  }

  void _startChatRefresh() {
    // 10초마다 채팅 목록 갱신
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        Provider.of<ChatProvider>(context, listen: false).refreshChats();
        _startChatRefresh(); // 재귀적으로 계속 실행
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleFavoriteToggle(String jobId, bool isFavorite) async {
    final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
    final success = await favoriteProvider.toggleFavorite(jobId);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(favoriteProvider.error ?? '찜 상태 업데이트에 실패했습니다.'),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }

  void _handleJobTap(Job job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDetailScreen(jobId: job.id),
      ),
    );
  }

  void _handleBannerTap(int index) {
    switch (index) {
      case 0:
        // 배너 1: 스페어 급구 매칭 - 급구 공고 필터 (JobsListScreen으로 이동, filter='urgent')
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const JobsListScreen(filter: 'urgent'),
          ),
        );
        break;
      case 1:
        // 배너 2: 미용실 인력 확보 - 스페어는 해당 없음 (무시)
        break;
      case 2:
        // 배너 3: 에너지 시스템 - 에너지 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EnergyScreen(),
          ),
        );
        break;
      case 3:
        // 배너 4: 챌린지 & 교육 - 교육 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EducationScreen(),
          ),
        );
        break;
      default:
        break;
    }
  }

  void _handleNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });
    
    // 네비게이션 처리
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PaymentScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FavoritesScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 네비게이션에 따라 다른 화면 표시
    if (_currentNavIndex == 0) {
      return _buildHomeScreen();
    } else {
      // 다른 화면은 Navigator로 처리되므로 여기서는 홈만 표시
      return _buildHomeScreen();
    }
  }

  Widget _buildHomeScreen() {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray, // bg-gray-50
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Sticky 헤더
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.backgroundWhite, // bg-white
            elevation: 0,
            leading: null,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.borderGray, // border-gray-200
                    width: 1,
                  ),
                ),
              ),
              padding: AppTheme.spacingSymmetric(
                horizontal: AppTheme.spacing4, // px-4
                vertical: AppTheme.spacing3, // py-3
              ),
              child: Row(
                children: [
                  // 로고
                  GestureDetector(
                    onTap: () {
                      // 홈으로 스크롤
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                    child: Text(
                      'HairSpare',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 20, // text-xl
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue, // text-blue-600
                      ),
                    ),
                  ),
                  const Spacer(),
                  // 검색/메시지/알림 버튼들
                  if (_isSearchOpen) ...[
                    // 검색 입력 필드
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
                              width: 2, // border-2 border-blue-500
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
                    // 검색 닫기 버튼
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
                          padding: EdgeInsets.all(AppTheme.spacing2), // p-2
                          child: IconMapper.icon('x', size: 24, color: AppTheme.textSecondary) ?? const Icon(Icons.close, size: 24, color: AppTheme.textSecondary),
                        ),
                      ),
                    ),
                  ] else ...[
                    // 검색 버튼
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
                          padding: EdgeInsets.all(AppTheme.spacing2), // p-2
                          child: IconMapper.icon('search', size: 24, color: AppTheme.textSecondary) ?? const Icon(Icons.search, size: 24, color: AppTheme.textSecondary),
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
                                  padding: EdgeInsets.all(AppTheme.spacing2), // p-2
                                  child: IconMapper.icon('messagecircle', size: 24, color: AppTheme.textSecondary) ?? const Icon(Icons.message_outlined, size: 24, color: AppTheme.textSecondary),
                                ),
                              ),
                            ),
                            // 읽지 않은 메시지 배지
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
                    // 알림 버튼 (NotificationBell 위젯 사용)
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
            child: Consumer<JobProvider>(
              builder: (context, jobProvider, _) {
                if (jobProvider.isLoading) {
                  return const SizedBox(
                    height: 400,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (jobProvider.error != null) {
                  return SizedBox(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '오류가 발생했습니다',
                            style: TextStyle(color: AppTheme.urgentRed),
                          ),
                          SizedBox(height: AppTheme.spacing4),
                          ElevatedButton(
                            onPressed: () => jobProvider.refreshJobs(),
                            child: const Text('다시 시도'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // 배너 이미지 URL 리스트
                // Flutter 웹에서는 assets 폴더의 이미지를 사용하거나, 실제 배너 이미지 URL 사용
                final bannerImages = [
                  'assets/images/banners/banner1.jpg',
                  'assets/images/banners/banner2.jpg',
                  'assets/images/banners/banner3.jpg',
                  'assets/images/banners/banner4.jpg',
                ];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 배너 캐러셀
                    BannerCarousel(
                      bannerImages: bannerImages,
                      onBannerTap: _handleBannerTap,
                    ),

                    // 카테고리 그리드
                    CategoryGrid(
                      categories: [
                            CategoryItem(
                              emoji: '📋',
                              label: '공고별',
                              has3DEffect: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => JobsListScreen()),
                                );
                              },
                            ),
                        CategoryItem(
                          emoji: '📅',
                          label: '스케줄표',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const WorkCheckScreen()),
                            );
                          },
                        ),
                        CategoryItem(
                          emoji: '🏪',
                          label: '스토어',
                          has3DEffect: true,
                          onTap: () {
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
                              MaterialPageRoute(
                                builder: (context) => const PointsScreen(),
                              ),
                            );
                          },
                        ),
                            CategoryItem(
                              emoji: '🗺️',
                              label: '공간대여',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const RegionSelectScreen()),
                                );
                              },
                            ),
                            CategoryItem(
                              emoji: '📚',
                              label: '교육',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const EducationScreen()),
                                );
                              },
                            ),
                        CategoryItem(
                          emoji: '🎯',
                          label: '챌린지참여',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ChallengeScreen()),
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

                    // 카테고리별 인기 공고 섹션
                    Consumer<JobProvider>(
                      builder: (context, jobProvider, _) {
                        return Consumer<FavoriteProvider>(
                          builder: (context, favoriteProvider, _) {
                            final favoriteMap = favoriteProvider.favoriteJobIds
                                .fold<Map<String, bool>>(
                                  {},
                                  (map, jobId) => map..[jobId] = true,
                                );
                            return CategoryJobsSection(
                              allJobs: jobProvider.jobs,
                              selectedRegionId: jobProvider.selectedRegionId,
                              favoriteMap: favoriteMap,
                              onJobTap: _handleJobTap,
                              onFavoriteToggle: _handleFavoriteToggle,
                            );
                          },
                        );
                      },
                    ),

                    // 급구 공고 섹션
                    Consumer<FavoriteProvider>(
                      builder: (context, favoriteProvider, _) {
                        final favoriteMap = favoriteProvider.favoriteJobIds
                            .fold<Map<String, bool>>(
                              {},
                              (map, jobId) => map..[jobId] = true,
                            );
                        return UrgentJobSection(
                          urgentJobs: jobProvider.urgentJobs,
                          favoriteMap: favoriteMap,
                          onJobTap: _handleJobTap,
                          onFavoriteToggle: _handleFavoriteToggle,
                        );
                      },
                    ),

                    // 인기 공고 섹션
                    Consumer<FavoriteProvider>(
                      builder: (context, favoriteProvider, _) {
                        final favoriteMap = favoriteProvider.favoriteJobIds
                            .fold<Map<String, bool>>(
                              {},
                              (map, jobId) => map..[jobId] = true,
                            );
                        // 인기 공고: 신청자 수가 많은 공고 상위 10개
                        final allJobs = [...jobProvider.urgentJobs, ...jobProvider.normalJobs];
                        final popularJobs = List<Job>.from(allJobs)
                          ..sort((a, b) => (b.requiredCount ?? 0).compareTo(a.requiredCount ?? 0));
                        final topPopularJobs = popularJobs.take(10).toList();
                        
                        return PopularJobsSection(
                          jobs: topPopularJobs,
                          favoriteMap: favoriteMap,
                          onJobTap: _handleJobTap,
                          onFavoriteToggle: _handleFavoriteToggle,
                        );
                      },
                    ),

                    // 신규 공고 섹션
                    Consumer<FavoriteProvider>(
                      builder: (context, favoriteProvider, _) {
                        final favoriteMap = favoriteProvider.favoriteJobIds
                            .fold<Map<String, bool>>(
                              {},
                              (map, jobId) => map..[jobId] = true,
                            );
                        // 신규 공고: 최근 등록된 공고 상위 10개
                        final allJobs = [...jobProvider.urgentJobs, ...jobProvider.normalJobs];
                        final newJobs = List<Job>.from(allJobs)
                          ..sort((a, b) {
                            final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
                            final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
                            return bTime.compareTo(aTime);
                          });
                        final topNewJobs = newJobs.take(10).toList();
                        
                        return NewJobsSection(
                          jobs: topNewJobs,
                          favoriteMap: favoriteMap,
                          onJobTap: _handleJobTap,
                          onFavoriteToggle: _handleFavoriteToggle,
                        );
                      },
                    ),

                    // 오픈 예정 매장 섹션
                    Consumer<JobProvider>(
                      builder: (context, jobProvider, _) {
                        return Consumer<FavoriteProvider>(
                          builder: (context, favoriteProvider, _) {
                            final favoriteMap = favoriteProvider.favoriteJobIds
                                .fold<Map<String, bool>>(
                                  {},
                                  (map, jobId) => map..[jobId] = true,
                                );
                            // 오픈 예정 공고: 모든 공고 중 최근 생성된 공고 최대 4개
                            // Next.js와 동일하게 normalJobs만 사용하되, 비어있으면 urgentJobs도 포함
                            final allJobsForUpcoming = jobProvider.normalJobs.isNotEmpty
                                ? jobProvider.normalJobs
                                : jobProvider.urgentJobs;
                            final upcomingJobs = List<Job>.from(allJobsForUpcoming)
                              ..sort((a, b) {
                                final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
                                final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
                                return bTime.compareTo(aTime);
                              });
                            final topUpcomingJobs = upcomingJobs.take(4).toList();
                            
                            return UpcomingShopsSection(
                              jobs: topUpcomingJobs,
                              favoriteMap: favoriteMap,
                              onJobTap: _handleJobTap,
                              onFavoriteToggle: _handleFavoriteToggle,
                            );
                          },
                        );
                      },
                    ),

                    // 일반 공고 섹션 (페이지네이션 포함)
                    Consumer<FavoriteProvider>(
                      builder: (context, favoriteProvider, _) {
                        final favoriteMap = favoriteProvider.favoriteJobIds
                            .fold<Map<String, bool>>(
                              {},
                              (map, jobId) => map..[jobId] = true,
                            );
                        return NormalJobsSection(
                          jobs: jobProvider.normalJobs,
                          favoriteMap: favoriteMap,
                          onJobTap: _handleJobTap,
                          onFavoriteToggle: _handleFavoriteToggle,
                        );
                      },
                    ),

                    // 고객센터 섹션
                    const CustomerServiceSection(),
                    
                    // 하단 여백 (하단 네비게이션 바 공간)
                    SizedBox(height: 80),
                  ],
                );
              },
            ),
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
              // 홈은 현재 화면이므로 스크롤만 맨 위로
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
              break;
            case 1:
              // 결제로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PaymentScreen()),
              );
              break;
            case 2:
              // 찜으로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
              break;
            case 3:
              // 마이로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
              break;
          }
        },
      ),
    );
  }
}
