import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../models/challenge_profile.dart';
import '../../models/user.dart';
import '../../services/challenge_service.dart';
import '../../utils/error_handler.dart';
import 'challenge_profile_edit_screen.dart';
import 'challenge_screen.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

/// 챌린지 프로필 화면 (탭 구조)
class ChallengeProfileScreen extends StatefulWidget {
  final String? userId; // 특정 사용자의 프로필을 보기 위한 userId (null이면 현재 사용자)

  const ChallengeProfileScreen({super.key, this.userId});

  @override
  State<ChallengeProfileScreen> createState() => _ChallengeProfileScreenState();
}

class _ChallengeProfileScreenState extends State<ChallengeProfileScreen>
    with SingleTickerProviderStateMixin {
  int _currentNavIndex = 3;
  late TabController _tabController;
  final ChallengeService _challengeService = ChallengeService();
  ChallengeProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // userId가 제공되면 해당 사용자의 프로필, 아니면 현재 사용자의 프로필 조회
      String? targetUserId = widget.userId;
      
      if (targetUserId == null) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = authProvider.currentUser;
        
        if (user == null) {
          // 로그인하지 않은 경우 기본 프로필 생성
          setState(() {
            _profile = ChallengeProfile(
              userId: 'guest',
              challengeNickname: '게스트',
              challengeBio: '로그인이 필요합니다',
              isPublic: false,
              videoCount: 0,
              totalLikes: 0,
              totalViews: 0,
              subscriberCount: 0,
            );
            _isLoading = false;
          });
          return;
        }
        targetUserId = user.id;
      }

      try {
        // API 호출하여 챌린지 프로필 정보 가져오기
        final profile = await _challengeService.getChallengeProfile(targetUserId);
        setState(() {
          _profile = profile;
        });
      } catch (e) {
        // API 실패 시 기본 프로필 생성 (mock)
        final appException = ErrorHandler.handleException(e);
        print('프로필 로드 오류: ${appException.toString()}');
        
        // Mock 프로필 생성
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = authProvider.currentUser;
        
        setState(() {
          _profile = ChallengeProfile(
            userId: targetUserId!,
            challengeNickname: user?.name ?? user?.username ?? '크리에이터',
            challengeBio: '챌린지 프로필 소개를 작성해주세요',
            challengeProfileImage: user?.profileImage,
            isPublic: true,
            videoCount: 0,
            totalLikes: 0,
            totalViews: 0,
            subscriberCount: 0,
          );
        });
      }
    } catch (e) {
      print('프로필 로드 오류: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          '챌린지 프로필',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryPurple,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryPurple,
          tabs: const [
            Tab(text: '프로필'),
            Tab(text: '내 영상'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _ProfileTab(
                  profile: _profile,
                  onProfileUpdated: _loadProfile,
                ),
                _MyVideosTab(),
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
                MaterialPageRoute(builder: (context) => SpareHomeScreen()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PaymentScreen()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FavoritesScreen()),
              );
              break;
            case 3:
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

/// 프로필 탭
class _ProfileTab extends StatelessWidget {
  final ChallengeProfile? profile;
  final VoidCallback onProfileUpdated;

  const _ProfileTab({
    required this.profile,
    required this.onProfileUpdated,
  });

  @override
  Widget build(BuildContext context) {
    if (profile == null) {
      return const Center(
        child: Text('프로필을 불러올 수 없습니다'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // 프로필 정보 섹션
          Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundWhite,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.borderGray,
                  width: 1,
                ),
              ),
            ),
            padding: AppTheme.spacing(AppTheme.spacing6),
            child: Column(
              children: [
                // 프로필 사진
                Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryPurple,
                            AppTheme.primaryBlue,
                          ],
                        ),
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                        boxShadow: AppTheme.shadowLg,
                      ),
                      child: profile!.challengeProfileImage != null
                          ? ClipRRect(
                              borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                              child: Image.network(
                                profile!.challengeProfileImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: IconMapper.icon('user', size: 60, color: Colors.white) ??
                                  const Icon(Icons.person, size: 60, color: Colors.white),
                            ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.spacing4),
                // 닉네임
                Text(
                  profile!.challengeNickname ?? '닉네임 없음',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: AppTheme.spacing2),
                // 바이오
                Text(
                  profile!.challengeBio ?? '소개를 작성해주세요',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppTheme.spacing4),
                // 프로필 편집 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChallengeProfileEditScreen(
                            profile: profile!,
                          ),
                        ),
                      );
                      if (result == true) {
                        onProfileUpdated();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: AppTheme.spacingSymmetric(
                        horizontal: AppTheme.spacing4,
                        vertical: AppTheme.spacing3,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      ),
                    ),
                    child: const Text(
                      '프로필 편집',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 통계 섹션
          Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundWhite,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.borderGray,
                  width: 1,
                ),
              ),
            ),
            padding: AppTheme.spacing(AppTheme.spacing4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        profile!.videoCount.toString(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryPurple,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing1),
                      Text(
                        '내 영상',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppTheme.borderGray,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        profile!.subscriberCount.toString(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.urgentRed,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing1),
                      Text(
                        '구독자',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppTheme.borderGray,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        profile!.totalLikes.toString(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing1),
                      Text(
                        '총 좋아요',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppTheme.borderGray,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        profile!.totalViews.toString(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing1),
                      Text(
                        '총 조회수',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
        ],
      ),
    );
  }
}

/// 내 영상 탭
class _MyVideosTab extends StatefulWidget {
  @override
  State<_MyVideosTab> createState() => _MyVideosTabState();
}

class _MyVideosTabState extends State<_MyVideosTab> {
  final ChallengeService _challengeService = ChallengeService();
  List<MyChallenge> _videos = [];
  bool _isLoading = true;
  String _filter = 'all'; // 'all', 'public', 'private'
  String _sortBy = 'latest'; // 'latest', 'popular', 'views'

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // API 호출하여 내 영상 목록 가져오기
      final videos = await _challengeService.getMyChallenges(
        filter: _filter != 'all' ? _filter : null,
        sortBy: _sortBy,
      );
      setState(() {
        _videos = videos;
      });
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      print('영상 로드 오류: ${appException.toString()}');
      // API 실패 시 빈 리스트 유지
      setState(() {
        _videos = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onFilterOrSortChanged() {
    _loadVideos();
  }

  List<MyChallenge> get _filteredVideos {
    var filtered = List<MyChallenge>.from(_videos);

    // 필터 적용
    if (_filter == 'public') {
      filtered = filtered.where((v) => v.isPublic).toList();
    } else if (_filter == 'private') {
      filtered = filtered.where((v) => !v.isPublic).toList();
    }

    // 정렬 적용
    switch (_sortBy) {
      case 'popular':
        filtered.sort((a, b) => b.likes.compareTo(a.likes));
        break;
      case 'views':
        filtered.sort((a, b) => b.views.compareTo(a.views));
        break;
      case 'latest':
      default:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 필터/정렬 바
        Container(
          color: AppTheme.backgroundWhite,
          padding: EdgeInsets.all(AppTheme.spacing3),
          child: Row(
            children: [
              // 필터
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing2),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filter,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('전체')),
                        DropdownMenuItem(value: 'public', child: Text('공개')),
                        DropdownMenuItem(value: 'private', child: Text('비공개')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filter = value ?? 'all';
                        });
                        _onFilterOrSortChanged();
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppTheme.spacing2),
              // 정렬
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing2),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sortBy,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'latest', child: Text('최신순')),
                        DropdownMenuItem(value: 'popular', child: Text('인기순')),
                        DropdownMenuItem(value: 'views', child: Text('조회수순')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _sortBy = value ?? 'latest';
                        });
                        _onFilterOrSortChanged();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 영상 그리드
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredVideos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconMapper.icon('video', size: 64, color: AppTheme.textTertiary) ??
                              const Icon(Icons.video_library, size: 64, color: AppTheme.textTertiary),
                          SizedBox(height: AppTheme.spacing4),
                          Text(
                            '업로드한 영상이 없습니다',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          SizedBox(height: AppTheme.spacing2),
                          Text(
                            '첫 번째 챌린지 영상을 업로드해보세요!',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(AppTheme.spacing3),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: _filteredVideos.length,
                      itemBuilder: (context, index) {
                        final video = _filteredVideos[index];
                        return _VideoGridItem(
                          video: video,
                          onTap: () {
                            // ChallengeScreen으로 이동하여 해당 영상 재생
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChallengeScreen(),
                                settings: RouteSettings(
                                  arguments: {'challengeId': video.id},
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

/// 영상 그리드 아이템
class _VideoGridItem extends StatelessWidget {
  final MyChallenge video;
  final VoidCallback onTap;

  const _VideoGridItem({
    required this.video,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 썸네일
            video.thumbnailUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      video.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.video_library,
                            color: Colors.white54,
                            size: 32,
                          ),
                        );
                      },
                    ),
                  )
                : Container(
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.video_library,
                      color: Colors.white54,
                      size: 32,
                    ),
                  ),
            // 재생 아이콘 오버레이
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            // 하단 정보
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          _formatNumber(video.likes),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (!video.isPublic)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Text(
                          '비공개',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int num) {
    if (num >= 10000) {
      return '${(num / 10000).toStringAsFixed(1)}만';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}천';
    }
    return num.toString();
  }
}
