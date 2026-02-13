import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/spare_profile.dart';
import '../../services/spare_service.dart';
import '../../utils/error_handler.dart';
import '../../utils/region_helper.dart';
import 'messages_screen.dart';

class ShopSpareDetailScreen extends StatefulWidget {
  final String spareId;

  const ShopSpareDetailScreen({
    super.key,
    required this.spareId,
  });

  @override
  State<ShopSpareDetailScreen> createState() => _ShopSpareDetailScreenState();
}

class _ShopSpareDetailScreenState extends State<ShopSpareDetailScreen> {
  final SpareService _spareService = SpareService();
  SpareProfile? _spare;
  bool _isLoading = true;
  String? _error;
  bool _hasThumbsUp = false;
  bool _isTogglingThumbsUp = false;

  @override
  void initState() {
    super.initState();
    _loadSpare();
    _checkThumbsUpStatus();
  }

  Future<void> _checkThumbsUpStatus() async {
    try {
      final hasThumbsUp = await _spareService.hasThumbsUpForSpare(widget.spareId);
      if (mounted) {
        setState(() {
          _hasThumbsUp = hasThumbsUp;
        });
      }
    } catch (e) {
      // 에러 발생 시 무시 (기본값 false 유지)
    }
  }

  Future<void> _toggleThumbsUp() async {
    if (_isTogglingThumbsUp || _spare == null) return;

    setState(() {
      _isTogglingThumbsUp = true;
    });

    final previousState = _hasThumbsUp;
    final previousCount = _spare!.thumbsUpCount;

    // 낙관적 업데이트
    setState(() {
      _hasThumbsUp = !_hasThumbsUp;
      _spare = SpareProfile(
        id: _spare!.id,
        name: _spare!.name,
        role: _spare!.role,
        profileImage: _spare!.profileImage,
        images: _spare!.images,
        regionId: _spare!.regionId,
        experience: _spare!.experience,
        rating: _spare!.rating,
        reviewCount: _spare!.reviewCount,
        thumbsUpCount: _hasThumbsUp ? previousCount + 1 : previousCount - 1,
        specialties: _spare!.specialties,
        availableTimes: _spare!.availableTimes,
        hourlyRate: _spare!.hourlyRate,
        isVerified: _spare!.isVerified,
        isLicenseVerified: _spare!.isLicenseVerified,
        noShowCount: _spare!.noShowCount,
        completedJobs: _spare!.completedJobs,
        createdAt: _spare!.createdAt,
        lastActiveAt: _spare!.lastActiveAt,
      );
    });

    try {
      if (_hasThumbsUp) {
        await _spareService.giveThumbsUpToSpare(widget.spareId);
      } else {
        await _spareService.removeThumbsUpFromSpare(widget.spareId);
      }
    } catch (e) {
      // 실패 시 롤백
      if (mounted) {
        setState(() {
          _hasThumbsUp = previousState;
          _spare = SpareProfile(
            id: _spare!.id,
            name: _spare!.name,
            role: _spare!.role,
            profileImage: _spare!.profileImage,
            images: _spare!.images,
            regionId: _spare!.regionId,
            experience: _spare!.experience,
            rating: _spare!.rating,
            reviewCount: _spare!.reviewCount,
            thumbsUpCount: previousCount,
            specialties: _spare!.specialties,
            availableTimes: _spare!.availableTimes,
            hourlyRate: _spare!.hourlyRate,
            isVerified: _spare!.isVerified,
            isLicenseVerified: _spare!.isLicenseVerified,
            noShowCount: _spare!.noShowCount,
            completedJobs: _spare!.completedJobs,
            createdAt: _spare!.createdAt,
            lastActiveAt: _spare!.lastActiveAt,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingThumbsUp = false;
        });
      }
    }
  }

  Future<void> _loadSpare() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final spare = await _spareService.getSpareById(widget.spareId);
      setState(() {
        _spare = spare;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('스페어 상세'),
          backgroundColor: AppTheme.primaryPurple,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null || _spare == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('스페어 상세'),
          backgroundColor: AppTheme.primaryPurple,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.textSecondary),
              SizedBox(height: AppTheme.spacing4),
              Text(
                _error ?? '스페어 정보를 불러올 수 없습니다',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              SizedBox(height: AppTheme.spacing4),
              ElevatedButton(
                onPressed: _loadSpare,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    final spare = _spare!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('스페어 상세'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.spacing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 헤더
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryBlue,
                        AppTheme.primaryPurple,
                      ],
                    ),
                  ),
                  child: spare.profileImage != null
                      ? ClipOval(
                          child: Image.network(
                            spare.profileImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Text(
                                  spare.name.isNotEmpty ? spare.name[0] : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Text(
                            spare.name.isNotEmpty ? spare.name[0] : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
                SizedBox(width: AppTheme.spacing4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              spare.name,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          if (spare.isLicenseVerified)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppTheme.spacing2,
                                vertical: AppTheme.spacing1,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.purple100,
                                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                              ),
                              child: Text(
                                '면허인증',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppTheme.purple700,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: AppTheme.spacing2),
                      Text(
                        '${spare.role == 'designer' ? '디자이너' : '스텝'} • 경력 ${spare.experience}년',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      SizedBox(height: AppTheme.spacing1),
                      Row(
                        children: [
                          Icon(
                            _hasThumbsUp ? Icons.thumb_up : Icons.thumb_up_outlined,
                            size: 16,
                            color: _hasThumbsUp ? AppTheme.primaryPurple : AppTheme.textSecondary,
                          ),
                          SizedBox(width: AppTheme.spacing1),
                          Text(
                            '따봉 ${spare.thumbsUpCount}개',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.primaryPurple,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          SizedBox(width: AppTheme.spacing2),
                          Text(
                            '•',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                          SizedBox(width: AppTheme.spacing2),
                          Text(
                            '완료 ${spare.completedJobs}건',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: AppTheme.spacing6),
            
            // 지역 정보
            _buildInfoSection(
              title: '지역',
              content: Text(RegionHelper.getRegionName(spare.regionId)),
            ),
            
            SizedBox(height: AppTheme.spacing4),
            
            // 전문 분야
            if (spare.specialties.isNotEmpty)
              _buildInfoSection(
                title: '전문 분야',
                content: Wrap(
                  spacing: AppTheme.spacing2,
                  runSpacing: AppTheme.spacing2,
                  children: spare.specialties.map((specialty) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing3,
                        vertical: AppTheme.spacing2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.purple100,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Text(
                        specialty,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.purple700,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            
            SizedBox(height: AppTheme.spacing6),
            
            // 따봉 버튼
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isTogglingThumbsUp ? null : _toggleThumbsUp,
                icon: Icon(
                  _hasThumbsUp ? Icons.thumb_up : Icons.thumb_up_outlined,
                  color: _hasThumbsUp ? AppTheme.primaryPurple : AppTheme.textSecondary,
                ),
                label: Text(
                  _hasThumbsUp ? '따봉 취소' : '따봉 주기',
                  style: TextStyle(
                    color: _hasThumbsUp ? AppTheme.primaryPurple : AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _hasThumbsUp ? AppTheme.primaryPurple : AppTheme.textSecondary,
                  side: BorderSide(
                    color: _hasThumbsUp ? AppTheme.primaryPurple : AppTheme.borderGray,
                    width: _hasThumbsUp ? 2 : 1,
                  ),
                  padding: EdgeInsets.symmetric(vertical: AppTheme.spacing4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: AppTheme.spacing3),
            
            // 하단 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShopMessagesScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: AppTheme.spacing4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
                child: const Text('채팅하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required Widget content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: AppTheme.spacing2),
        content,
      ],
    );
  }
}
