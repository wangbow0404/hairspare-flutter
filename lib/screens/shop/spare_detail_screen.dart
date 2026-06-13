import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/shared_app_bar.dart';
import '../../models/spare_profile.dart';
import '../../services/spare_service.dart';
import '../../utils/error_handler.dart';
import '../../utils/region_helper.dart';
import 'messages_screen.dart';

// 디자인: 다운로드 폴더 "스페어 상세 화면 디자인" 구조 반영 (프로필·포트폴리오·전문기술·근무정보·매칭정보·연락하기)

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
  @override
  void initState() {
    super.initState();
    _loadSpare();
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
      return const Scaffold(
        appBar: SharedAppBar(title: '스페어 상세'),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null || _spare == null) {
      return Scaffold(
        appBar: const SharedAppBar(title: '스페어 상세'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.textSecondary),
              const SizedBox(height: AppTheme.spacing4),
              Text(
                _error ?? '스페어 정보를 불러올 수 없습니다',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing4),
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
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SharedAppBar(title: '스페어 상세'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: AppTheme.spacing4,
                right: AppTheme.spacing4,
                top: 0,
                bottom: AppTheme.spacing6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileSection(context, spare),
                  _buildPortfolioSection(context, spare),
                  _buildSkillsSection(context, spare),
                  _buildWorkInfoSection(context, spare),
                  _buildMatchingInfoSection(context, spare),
                ],
              ),
            ),
          ),
          _buildBottomCta(context),
        ],
      ),
    );
  }

  Widget _buildSectionCard({String? title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppTheme.spacing2),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing6,
      ),
      color: AppTheme.backgroundWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null && title.isNotEmpty) ...[
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spacing4),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, SpareProfile spare) {
    final initials = spare.name.length >= 2
        ? spare.name.substring(0, 2)
        : (spare.name.isNotEmpty ? spare.name[0] : '?');
    return _buildSectionCard(
      title: null, // 프로필은 제목 없음
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: spare.profileImage != null
                ? Image.network(
                    spare.profileImage!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _avatarPlaceholder(initials),
                  )
                : _avatarPlaceholder(initials),
          ),
          const SizedBox(width: AppTheme.spacing4),
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
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    if (spare.isLicenseVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing2,
                          vertical: AppTheme.spacing1,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.purple100,
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, size: 12, color: AppTheme.purple700),
                            const SizedBox(width: 4),
                            Text(
                              '면허인증',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppTheme.purple700,
                                    fontSize: 12,
                                  ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing1),
                Text(
                  '${spare.role == 'designer' ? '디자이너' : '스텝'} • 경력 ${spare.experience}년',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: AppTheme.spacing1),
                Text(
                  '완료 ${spare.completedJobs}건',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarPlaceholder(String initials) {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPortfolioSection(BuildContext context, SpareProfile spare) {
    final images = spare.images ?? [];
    return _buildSectionCard(
      title: '포트폴리오',
      child: images.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
                child: Text(
                  '등록된 포트폴리오가 없습니다',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                ),
              ),
            )
          : SizedBox(
              height: 128,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppTheme.spacing3),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    child: Image.network(
                      images[index],
                      width: 128,
                      height: 128,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 128,
                        height: 128,
                        color: AppTheme.borderGray,
                        child: const Icon(Icons.broken_image_outlined, color: AppTheme.textTertiary),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildSkillsSection(BuildContext context, SpareProfile spare) {
    return _buildSectionCard(
      title: '전문 기술',
      child: spare.specialties.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing4),
                child: Text(
                  '등록된 전문 기술이 없습니다',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                ),
              ),
            )
          : Wrap(
              spacing: AppTheme.spacing2,
              runSpacing: AppTheme.spacing2,
              children: spare.specialties.map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing4,
                    vertical: AppTheme.spacing2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.purple100,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    s,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.purple700,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  /// 요일형(주말, 평일, 월·화 등)은 가능 요일만, 시간형(09:00~18:00 등)은 가능 시간만 표시. 가능 시간에 '주말' 등이 뜨지 않도록 함.
  static ({String days, String hours}) _splitAvailableDaysAndHours(List<String> availableTimes) {
    if (availableTimes.isEmpty) return (days: '—', hours: '—');
    const dayOnlyKeywords = ['주말', '평일', '월', '화', '수', '목', '금', '토', '일', '요일'];
    final dayList = <String>[];
    final timeList = <String>[];
    for (final s in availableTimes) {
      final t = s.trim();
      if (t.isEmpty) continue;
      final looksLikeTime = t.contains(':') || t.contains('~') || t.contains('시') && !t.contains('요일');
      final looksLikeDayOnly = dayOnlyKeywords.any((k) => t == k || t.startsWith(k) || t.contains(k));
      if (looksLikeTime && !looksLikeDayOnly) {
        timeList.add(t);
      } else {
        dayList.add(t);
      }
    }
    return (
      days: dayList.isEmpty ? '—' : dayList.join(', '),
      hours: timeList.isEmpty ? '—' : timeList.join(', '),
    );
  }

  Widget _buildWorkInfoSection(BuildContext context, SpareProfile spare) {
    final region = RegionHelper.getRegionName(spare.regionId);
    final split = _splitAvailableDaysAndHours(spare.availableTimes);
    return _buildSectionCard(
      title: '근무 정보',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _workInfoRow(Icons.location_on_outlined, '가능 지역', region),
          const SizedBox(height: AppTheme.spacing4),
          _workInfoRow(Icons.calendar_today_outlined, '가능 요일', split.days),
          const SizedBox(height: AppTheme.spacing4),
          _workInfoRow(Icons.access_time_outlined, '가능 시간', split.hours),
        ],
      ),
    );
  }

  Widget _workInfoRow(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: AppTheme.spacing2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing2),
        Padding(
          padding: const EdgeInsets.only(left: 24.0), // ml-6 in design
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchingInfoSection(BuildContext context, SpareProfile spare) {
    final hasNoShow = spare.noShowCount > 0;
    final noShowRate = spare.completedJobs > 0
        ? (spare.noShowCount / spare.completedJobs * 100).round()
        : 0;
    const responseSpeed = '평균 1시간 이내';
    const averageWorkHours = 4.0;

    return _buildSectionCard(
      title: '매칭 정보',
      child: Column(
        children: [
          _matchingRow(
            icon: hasNoShow ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            iconColor: hasNoShow ? AppTheme.urgentRed : AppTheme.primaryGreen,
            label: '노쇼 이력',
            value: hasNoShow ? '${spare.noShowCount}회' : '없음',
            valueColor: hasNoShow ? AppTheme.urgentRed : AppTheme.primaryGreen,
          ),
          _divider(),
          _matchingRow(
            label: '노쇼율',
            value: '$noShowRate%',
            valueColor: hasNoShow ? AppTheme.urgentRed : AppTheme.primaryGreen,
          ),
          _divider(),
          _matchingRow(
            icon: Icons.chat_bubble_outline,
            label: '응답 속도',
            value: responseSpeed,
          ),
          _divider(),
          _matchingRow(
            icon: Icons.schedule_outlined,
            label: '평균 근무 시간',
            value: '${averageWorkHours.toStringAsFixed(1)}시간',
          ),
        ],
      ),
    );
  }

  Widget _matchingRow({
    IconData? icon,
    Color? iconColor,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: iconColor ?? AppTheme.textSecondary),
                const SizedBox(width: AppTheme.spacing2),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: valueColor ?? AppTheme.textPrimary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, color: AppTheme.borderGray);
  }

  Widget _buildBottomCta(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: Border(top: BorderSide(color: AppTheme.borderGray)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShopMessagesScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
              elevation: 0,
            ),
            child: const Text('연락하기'),
          ),
        ),
      ),
    );
  }
}
