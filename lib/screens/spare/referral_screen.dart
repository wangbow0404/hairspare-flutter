import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../services/auth_service.dart';
import '../../utils/error_handler.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

/// Next.js와 동일한 추천 화면
class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  int _currentNavIndex = 0;
  final AuthService _authService = AuthService();
  List<_ReferralHistory> _referralHistory = [];
  String? _referralCode;
  String? _userEmail;
  bool _isLoading = true;
  String? _copiedType; // 'link' or 'code'

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // API 호출하여 사용자 정보 및 추천 코드 가져오기
      final user = await _authService.getCurrentUser();
      
      if (user != null) {
        // 추천 코드는 사용자 ID의 앞 8자를 대문자로 변환하여 사용
        final referralCode = user.id.length >= 8 
            ? user.id.substring(0, 8).toUpperCase()
            : user.id.toUpperCase();
        final userEmail = user.email ?? user.username;
        
        // 추천 이력 조회
        List<_ReferralHistory> referralHistory = [];
        try {
          final historyData = await _authService.getReferralHistory();
          referralHistory = historyData.map((item) {
            return _ReferralHistory(
              id: item['id']?.toString() ?? '',
              friendName: item['friendName']?.toString() ?? item['friend']?['name']?.toString() ?? '친구',
              joinedDate: item['joinedDate']?.toString() ?? item['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
              rewardGiven: item['rewardGiven'] as bool? ?? item['reward_given'] as bool? ?? false,
            );
          }).toList();
        } catch (e) {
          // 추천 이력 조회 실패 시 빈 리스트 유지
          print('추천 이력 조회 오류: $e');
        }
        
        setState(() {
          _referralCode = referralCode;
          _userEmail = userEmail;
          _referralHistory = referralHistory;
        });
      }
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getUserFriendlyMessage(appException)),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String get _referralLink {
    if (_userEmail == null) return '';
    return 'https://www.hairspare.co.kr/spare/signup?ref=$_userEmail';
  }

  Future<void> _copyLink() async {
    if (_referralLink.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _referralLink));
    setState(() {
      _copiedType = 'link';
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copiedType = null;
        });
      }
    });
  }

  Future<void> _copyCode() async {
    if (_referralCode == null || _referralCode!.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _referralCode!));
    setState(() {
      _copiedType = 'code';
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copiedType = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
          '추천하기',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: AppTheme.spacing(AppTheme.spacing6),
        child: Column(
          children: [
            // 추천 링크/코드
            Container(
              padding: AppTheme.spacing(AppTheme.spacing6),
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                border: Border.all(color: AppTheme.borderGray),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPink.withOpacity(0.1),
                          borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                        ),
                        child: IconMapper.icon('users', size: 24, color: AppTheme.primaryPink) ??
                            const Icon(Icons.people, size: 24, color: AppTheme.primaryPink),
                      ),
                      SizedBox(width: AppTheme.spacing3),
                      Text(
                        '추천 링크',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  // 추천 링크
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '추천 링크',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing2),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: AppTheme.spacing(AppTheme.spacing3),
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundGray,
                                borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                                border: Border.all(color: AppTheme.borderGray),
                              ),
                              child: Text(
                                _referralLink.isEmpty ? '로딩 중...' : _referralLink,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  color: _referralLink.isEmpty
                                      ? AppTheme.textTertiary
                                      : AppTheme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(width: AppTheme.spacing2),
                          ElevatedButton(
                            onPressed: _referralLink.isEmpty ? null : _copyLink,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryPink,
                              foregroundColor: Colors.white,
                              padding: AppTheme.spacing(AppTheme.spacing3),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconMapper.icon(
                                  _copiedType == 'link' ? 'checkcircle' : 'copy',
                                  size: 16,
                                  color: Colors.white,
                                ) ??
                                    Icon(
                                      _copiedType == 'link'
                                          ? Icons.check_circle
                                          : Icons.copy,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                SizedBox(width: AppTheme.spacing1),
                                Text(
                                  _copiedType == 'link' ? '복사됨' : '복사',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_userEmail == null && !_isLoading)
                        Padding(
                          padding: EdgeInsets.only(top: AppTheme.spacing1),
                          child: Text(
                            '⚠️ 사용자 이메일을 불러올 수 없습니다',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 12,
                              color: AppTheme.urgentRed,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  // 추천 코드
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '추천 코드',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing2),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: AppTheme.spacing(AppTheme.spacing3),
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundGray,
                                borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                                border: Border.all(color: AppTheme.borderGray),
                              ),
                              child: Text(
                                _referralCode ?? '코드 생성 중...',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 14,
                                  fontFamily: 'monospace',
                                  color: _referralCode == null
                                      ? AppTheme.textTertiary
                                      : AppTheme.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(width: AppTheme.spacing2),
                          ElevatedButton(
                            onPressed: (_referralCode == null || _referralCode!.isEmpty)
                                ? null
                                : _copyCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryPink,
                              foregroundColor: Colors.white,
                              padding: AppTheme.spacing(AppTheme.spacing3),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconMapper.icon(
                                  _copiedType == 'code' ? 'checkcircle' : 'copy',
                                  size: 16,
                                  color: Colors.white,
                                ) ??
                                    Icon(
                                      _copiedType == 'code'
                                          ? Icons.check_circle
                                          : Icons.copy,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                SizedBox(width: AppTheme.spacing1),
                                Text(
                                  _copiedType == 'code' ? '복사됨' : '복사',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_referralCode == null && !_isLoading)
                        Padding(
                          padding: EdgeInsets.only(top: AppTheme.spacing1),
                          child: Text(
                            '⚠️ 추천 코드를 생성할 수 없습니다',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 12,
                              color: AppTheme.urgentRed,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: AppTheme.spacing6),
            // 리워드 안내
            Container(
              padding: AppTheme.spacing(AppTheme.spacing6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryPinkLight, AppTheme.primaryPurpleLight],
                ),
                borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                border: Border.all(color: AppTheme.primaryPink.withOpacity(0.2), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '리워드 안내',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryPinkDarker,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing2),
                  Text(
                    '친구가 가입하면 예약금(에너지) +1개가 지급됩니다.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 14,
                      color: AppTheme.primaryPinkDarker.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppTheme.spacing6),
            // 추천 내역
            Container(
              padding: AppTheme.spacing(AppTheme.spacing6),
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                border: Border.all(color: AppTheme.borderGray),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '추천 내역',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  _referralHistory.isEmpty
                      ? Padding(
                          padding: AppTheme.spacing(AppTheme.spacing8),
                          child: Column(
                            children: [
                              IconMapper.icon('users', size: 48, color: AppTheme.textTertiary) ??
                                  const Icon(Icons.people, size: 48, color: AppTheme.textTertiary),
                              SizedBox(height: AppTheme.spacing4),
                              Text(
                                '추천한 친구가 없습니다.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: _referralHistory.map((ref) {
                            return Container(
                              margin: EdgeInsets.only(bottom: AppTheme.spacing3),
                              padding: AppTheme.spacing(AppTheme.spacing4),
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundGray,
                                borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ref.friendName,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: AppTheme.spacing1 / 2),
                                      Text(
                                        '가입일: ${DateFormat('yyyy년 M월 d일', 'ko_KR').format(DateTime.parse(ref.joinedDate))}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: AppTheme.spacingSymmetric(
                                      horizontal: AppTheme.spacing3,
                                      vertical: AppTheme.spacing1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.green100,
                                      borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                    ),
                                    child: Text(
                                      '에너지 +1 지급됨',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryGreen,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
          ],
        ),
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

class _ReferralHistory {
  final String id;
  final String friendName;
  final String joinedDate;
  final bool rewardGiven;

  _ReferralHistory({
    required this.id,
    required this.friendName,
    required this.joinedDate,
    required this.rewardGiven,
  });
}
