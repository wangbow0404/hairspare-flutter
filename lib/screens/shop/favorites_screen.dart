import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../services/spare_service.dart';
import '../../models/spare_profile.dart';
import '../../utils/error_handler.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import 'profile_screen.dart';
import 'spares_list_screen.dart';

/// Shop 찜 화면 (스페어 찜 목록)
class ShopFavoritesScreen extends StatefulWidget {
  const ShopFavoritesScreen({super.key});

  @override
  State<ShopFavoritesScreen> createState() => _ShopFavoritesScreenState();
}

class _ShopFavoritesScreenState extends State<ShopFavoritesScreen> {
  int _currentNavIndex = 2; // 찜 탭
  List<SpareProfile> _favoriteSpares = [];
  bool _isLoading = true;
  final SpareService _spareService = SpareService();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 찜한 스페어 목록 API 호출
      // final favorites = await _spareService.getFavoriteSpares();
      
      // Mock 데이터 - 실제로는 API에서 가져와야 함
      final allSpares = await _spareService.getSpares();
      setState(() {
        _favoriteSpares = allSpares.take(3).toList(); // 임시로 처음 3개만 표시
        _isLoading = false;
      });
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('찜 목록을 불러오는 중 오류가 발생했습니다: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRemoveFavorite(String spareId) async {
    try {
      // TODO: 찜 해제 API 호출
      // await _spareService.removeFavoriteSpare(spareId);
      
      setState(() {
        _favoriteSpares.removeWhere((spare) => spare.id == spareId);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('찜이 삭제되었습니다.')),
        );
      }
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('찜 삭제 중 오류가 발생했습니다: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
          ),
        );
      }
    }
  }

  void _handleSpareTap(SpareProfile spare) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShopSparesListScreen(), // TODO: 스페어 상세 화면으로 이동
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
            '찜한 스페어',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          centerTitle: false,
        ),
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
          '찜한 스페어',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: _favoriteSpares.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundGray,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: IconMapper.icon('heart', size: 32, color: AppTheme.textTertiary) ??
                        const Icon(Icons.favorite_border, size: 32, color: AppTheme.textTertiary),
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  Text(
                    '찜한 스페어가 없습니다',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing2),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ShopSparesListScreen(),
                        ),
                      );
                    },
                    child: Text(
                      '스페어 둘러보기 →',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(AppTheme.spacing4),
              itemCount: _favoriteSpares.length,
              itemBuilder: (context, index) {
                final spare = _favoriteSpares[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: AppTheme.spacing4),
                  child: GestureDetector(
                    onTap: () => _handleSpareTap(spare),
                    child: Container(
                      padding: EdgeInsets.all(AppTheme.spacing4),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundWhite,
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
                      child: Stack(
                        children: [
                          // 찜 버튼 - 우측 상단
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _handleRemoveFavorite(spare.id),
                                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                child: Container(
                                  padding: EdgeInsets.all(AppTheme.spacing2),
                                  child: IconMapper.icon(
                                    'heart',
                                    size: 20,
                                    color: AppTheme.urgentRed,
                                  ) ??
                                      const Icon(
                                        Icons.favorite,
                                        size: 20,
                                        color: AppTheme.urgentRed,
                                      ),
                                ),
                              ),
                            ),
                          ),
                          // 메인 콘텐츠
                          Padding(
                            padding: EdgeInsets.only(right: 48), // 찜 버튼 공간
                            child: Row(
                              children: [
                                // 프로필 이미지
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.primaryBlue,
                                        AppTheme.primaryPurple,
                                      ],
                                    ),
                                  ),
                                  child: spare.profileImage != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                          child: Image.network(
                                            spare.profileImage!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            spare.name.isNotEmpty ? spare.name[0] : '?',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                ),
                                SizedBox(width: AppTheme.spacing4),
                                // 정보
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        spare.name,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: AppTheme.spacing1),
                                      Text(
                                        '경력 ${spare.experience}년 • 완료 ${spare.completedJobs}건',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontSize: 14,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                      SizedBox(height: AppTheme.spacing2),
                                      Wrap(
                                        spacing: AppTheme.spacing1,
                                        runSpacing: AppTheme.spacing1,
                                        children: spare.specialties.take(3).map((specialty) {
                                          return Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: AppTheme.spacing2,
                                              vertical: AppTheme.spacing1 / 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryPurple.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                            ),
                                            child: Text(
                                              specialty,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppTheme.primaryPurple,
                                                fontWeight: FontWeight.w500,
                                              ),
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
                        ],
                      ),
                    ),
                  ),
                );
              },
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
              // 현재 화면
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
}
